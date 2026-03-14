-- Location: supabase/migrations/20251229071203_data_migration_module.sql
-- Schema Analysis: Existing DBC ERP schema with invoices, vendors, marketplace_products, gst_returns
-- Integration Type: New module for ERP data migration functionality
-- Dependencies: user_profiles (for user ownership)

-- 1. Types
CREATE TYPE public.migration_source_type AS ENUM ('quickbooks', 'tally', 'sap', 'excel', 'zoho', 'freshbooks', 'custom');
CREATE TYPE public.migration_status AS ENUM ('draft', 'validating', 'validated', 'importing', 'completed', 'failed', 'paused');
CREATE TYPE public.field_mapping_type AS ENUM ('direct', 'transformed', 'calculated', 'default');
CREATE TYPE public.validation_severity AS ENUM ('error', 'warning', 'info');

-- 2. Core Tables
CREATE TABLE public.migration_projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    project_name TEXT NOT NULL,
    source_type public.migration_source_type NOT NULL,
    source_config JSONB,
    target_modules TEXT[],
    status public.migration_status DEFAULT 'draft'::public.migration_status,
    total_records INTEGER DEFAULT 0,
    processed_records INTEGER DEFAULT 0,
    failed_records INTEGER DEFAULT 0,
    validation_errors JSONB DEFAULT '[]'::JSONB,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.field_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    migration_project_id UUID REFERENCES public.migration_projects(id) ON DELETE CASCADE,
    source_field TEXT NOT NULL,
    target_field TEXT NOT NULL,
    target_table TEXT NOT NULL,
    mapping_type public.field_mapping_type DEFAULT 'direct'::public.field_mapping_type,
    transformation_rule JSONB,
    is_required BOOLEAN DEFAULT false,
    default_value TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.migration_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    template_name TEXT NOT NULL,
    source_type public.migration_source_type NOT NULL,
    target_modules TEXT[],
    field_mappings JSONB NOT NULL,
    is_public BOOLEAN DEFAULT false,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.migration_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    migration_project_id UUID REFERENCES public.migration_projects(id) ON DELETE CASCADE,
    log_type TEXT NOT NULL,
    severity public.validation_severity DEFAULT 'info'::public.validation_severity,
    message TEXT NOT NULL,
    record_identifier TEXT,
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.migration_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    migration_project_id UUID REFERENCES public.migration_projects(id) ON DELETE CASCADE,
    batch_number INTEGER NOT NULL,
    source_data JSONB NOT NULL,
    transformed_data JSONB,
    status public.migration_status DEFAULT 'draft'::public.migration_status,
    records_count INTEGER DEFAULT 0,
    processed_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes
CREATE INDEX idx_migration_projects_user_id ON public.migration_projects(user_id);
CREATE INDEX idx_migration_projects_status ON public.migration_projects(status);
CREATE INDEX idx_field_mappings_project_id ON public.field_mappings(migration_project_id);
CREATE INDEX idx_migration_templates_user_id ON public.migration_templates(user_id);
CREATE INDEX idx_migration_templates_source_type ON public.migration_templates(source_type);
CREATE INDEX idx_migration_logs_project_id ON public.migration_logs(migration_project_id);
CREATE INDEX idx_migration_logs_severity ON public.migration_logs(severity);
CREATE INDEX idx_migration_batches_project_id ON public.migration_batches(migration_project_id);

-- 4. Functions
CREATE OR REPLACE FUNCTION public.update_migration_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

CREATE OR REPLACE FUNCTION public.calculate_migration_progress(project_uuid UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    result JSONB;
    project_record RECORD;
BEGIN
    SELECT 
        total_records,
        processed_records,
        failed_records,
        status
    INTO project_record
    FROM public.migration_projects
    WHERE id = project_uuid;
    
    IF project_record IS NULL THEN
        RETURN '{"error": "Project not found"}'::JSONB;
    END IF;
    
    result := jsonb_build_object(
        'total', project_record.total_records,
        'processed', project_record.processed_records,
        'failed', project_record.failed_records,
        'remaining', project_record.total_records - project_record.processed_records,
        'progress_percent', 
            CASE 
                WHEN project_record.total_records > 0 
                THEN ROUND((project_record.processed_records::NUMERIC / project_record.total_records::NUMERIC) * 100, 2)
                ELSE 0 
            END,
        'status', project_record.status
    );
    
    RETURN result;
END;
$func$;

CREATE OR REPLACE FUNCTION public.validate_migration_data(project_uuid UUID)
RETURNS TABLE(
    validation_status TEXT,
    error_count INTEGER,
    warning_count INTEGER,
    errors JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    error_logs_count INTEGER;
    warning_logs_count INTEGER;
    validation_errors JSONB;
BEGIN
    SELECT COUNT(*) INTO error_logs_count
    FROM public.migration_logs
    WHERE migration_project_id = project_uuid 
    AND severity = 'error'::public.validation_severity;
    
    SELECT COUNT(*) INTO warning_logs_count
    FROM public.migration_logs
    WHERE migration_project_id = project_uuid 
    AND severity = 'warning'::public.validation_severity;
    
    SELECT jsonb_agg(jsonb_build_object(
        'severity', ml.severity,
        'message', ml.message,
        'record', ml.record_identifier
    ))
    INTO validation_errors
    FROM public.migration_logs ml
    WHERE ml.migration_project_id = project_uuid
    AND ml.severity IN ('error'::public.validation_severity, 'warning'::public.validation_severity)
    ORDER BY ml.created_at DESC
    LIMIT 100;
    
    RETURN QUERY SELECT
        CASE 
            WHEN error_logs_count > 0 THEN 'failed'::TEXT
            WHEN warning_logs_count > 0 THEN 'warning'::TEXT
            ELSE 'passed'::TEXT
        END,
        error_logs_count,
        warning_logs_count,
        COALESCE(validation_errors, '[]'::JSONB);
END;
$func$;

-- 5. Enable RLS
ALTER TABLE public.migration_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.field_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.migration_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.migration_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.migration_batches ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (Pattern 2: Simple User Ownership)
CREATE POLICY "users_manage_own_migration_projects"
ON public.migration_projects
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_field_mappings"
ON public.field_mappings
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.migration_projects mp
        WHERE mp.id = field_mappings.migration_project_id
        AND mp.user_id = auth.uid()
    )
);

CREATE POLICY "users_view_public_templates"
ON public.migration_templates
FOR SELECT
TO authenticated
USING (user_id = auth.uid() OR is_public = true);

CREATE POLICY "users_manage_own_templates"
ON public.migration_templates
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_view_migration_logs"
ON public.migration_logs
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.migration_projects mp
        WHERE mp.id = migration_logs.migration_project_id
        AND mp.user_id = auth.uid()
    )
);

CREATE POLICY "users_manage_migration_batches"
ON public.migration_batches
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.migration_projects mp
        WHERE mp.id = migration_batches.migration_project_id
        AND mp.user_id = auth.uid()
    )
);

-- 7. Triggers
CREATE TRIGGER update_migration_projects_updated_at
    BEFORE UPDATE ON public.migration_projects
    FOR EACH ROW
    EXECUTE FUNCTION public.update_migration_updated_at();

CREATE TRIGGER update_field_mappings_updated_at
    BEFORE UPDATE ON public.field_mappings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_migration_updated_at();

CREATE TRIGGER update_migration_templates_updated_at
    BEFORE UPDATE ON public.migration_templates
    FOR EACH ROW
    EXECUTE FUNCTION public.update_migration_updated_at();

-- 8. Mock Data (References existing users)
DO $$
DECLARE
    existing_user_id UUID;
    demo_project_id UUID := gen_random_uuid();
    template_id UUID := gen_random_uuid();
BEGIN
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        INSERT INTO public.migration_projects (
            id, user_id, project_name, source_type, target_modules, 
            status, total_records, processed_records
        ) VALUES
            (demo_project_id, existing_user_id, 'QuickBooks Import 2025', 
             'quickbooks'::public.migration_source_type, 
             ARRAY['invoices', 'customers', 'products'], 
             'validating'::public.migration_status, 1250, 320);
        
        INSERT INTO public.field_mappings (
            migration_project_id, source_field, target_field, 
            target_table, mapping_type, is_required
        ) VALUES
            (demo_project_id, 'CustomerName', 'customer_name', 'invoices', 
             'direct'::public.field_mapping_type, true),
            (demo_project_id, 'InvoiceDate', 'issue_date', 'invoices', 
             'transformed'::public.field_mapping_type, true),
            (demo_project_id, 'TotalAmount', 'total_amount', 'invoices', 
             'direct'::public.field_mapping_type, true);
        
        INSERT INTO public.migration_templates (
            id, user_id, template_name, source_type, target_modules, 
            field_mappings, is_public
        ) VALUES
            (template_id, existing_user_id, 'Standard QuickBooks Import', 
             'quickbooks'::public.migration_source_type, 
             ARRAY['invoices', 'customers'], 
             '{"invoice_mappings": [{"source": "CustomerName", "target": "customer_name"}]}'::JSONB, 
             true);
        
        INSERT INTO public.migration_logs (
            migration_project_id, log_type, severity, message, record_identifier
        ) VALUES
            (demo_project_id, 'validation', 'warning'::public.validation_severity, 
             'Missing customer email in record', 'INV-2025-001'),
            (demo_project_id, 'validation', 'error'::public.validation_severity, 
             'Invalid date format in invoice date field', 'INV-2025-045');
    END IF;
END $$;
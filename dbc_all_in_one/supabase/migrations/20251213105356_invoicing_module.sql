-- Location: supabase/migrations/20251213105356_invoicing_module.sql
-- Schema Analysis: Existing tables include user_profiles, marketplace, security, hiring modules
-- Integration Type: NEW_MODULE (Invoicing functionality)
-- Dependencies: user_profiles (for created_by reference)

-- 1. Types - Invoice-specific enums
CREATE TYPE public.invoice_status AS ENUM ('draft', 'sent', 'paid', 'overdue', 'cancelled');
CREATE TYPE public.invoice_template_category AS ENUM ('restaurant', 'retail', 'services', 'general');

-- 2. Core Tables

-- Invoice templates table
CREATE TABLE public.invoice_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_name TEXT NOT NULL,
    category public.invoice_template_category NOT NULL,
    description TEXT,
    template_data JSONB NOT NULL,
    preview_image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Invoices table
CREATE TABLE public.invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number TEXT NOT NULL UNIQUE,
    template_id UUID REFERENCES public.invoice_templates(id) ON DELETE SET NULL,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    customer_name TEXT NOT NULL,
    customer_email TEXT,
    customer_phone TEXT,
    customer_address TEXT,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status public.invoice_status DEFAULT 'draft'::public.invoice_status,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Invoice items table
CREATE TABLE public.invoice_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID REFERENCES public.invoices(id) ON DELETE CASCADE,
    item_name TEXT NOT NULL,
    description TEXT,
    quantity DECIMAL(10,2) NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes
CREATE INDEX idx_invoice_templates_category ON public.invoice_templates(category);
CREATE INDEX idx_invoice_templates_is_active ON public.invoice_templates(is_active);
CREATE INDEX idx_invoices_created_by ON public.invoices(created_by);
CREATE INDEX idx_invoices_status ON public.invoices(status);
CREATE INDEX idx_invoices_issue_date ON public.invoices(issue_date);
CREATE INDEX idx_invoices_due_date ON public.invoices(due_date);
CREATE INDEX idx_invoice_items_invoice_id ON public.invoice_items(invoice_id);

-- 4. Functions
CREATE OR REPLACE FUNCTION public.generate_invoice_number()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    next_number INTEGER;
    invoice_num TEXT;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(invoice_number FROM 5) AS INTEGER)), 0) + 1
    INTO next_number
    FROM public.invoices
    WHERE invoice_number LIKE 'INV-%';
    
    invoice_num := 'INV-' || LPAD(next_number::TEXT, 6, '0');
    RETURN invoice_num;
END;
$func$;

CREATE OR REPLACE FUNCTION public.update_updated_at_invoice()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

-- 5. Enable RLS
ALTER TABLE public.invoice_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies

-- Invoice templates - Public read, authenticated create
CREATE POLICY "public_can_read_templates"
ON public.invoice_templates
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "authenticated_manage_templates"
ON public.invoice_templates
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Invoices - User ownership
CREATE POLICY "users_manage_own_invoices"
ON public.invoices
FOR ALL
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

-- Invoice items - Through invoice ownership
CREATE OR REPLACE FUNCTION public.owns_invoice_for_item(item_invoice_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT EXISTS (
    SELECT 1 FROM public.invoices i
    WHERE i.id = item_invoice_id
    AND i.created_by = auth.uid()
)
$func$;

CREATE POLICY "users_manage_own_invoice_items"
ON public.invoice_items
FOR ALL
TO authenticated
USING (public.owns_invoice_for_item(invoice_id))
WITH CHECK (public.owns_invoice_for_item(invoice_id));

-- 7. Triggers
CREATE TRIGGER update_invoice_templates_timestamp
    BEFORE UPDATE ON public.invoice_templates
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_invoice();

CREATE TRIGGER update_invoices_timestamp
    BEFORE UPDATE ON public.invoices
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_invoice();

-- 8. Mock Data
DO $$
DECLARE
    existing_user_id UUID;
    template1_id UUID := gen_random_uuid();
    template2_id UUID := gen_random_uuid();
    template3_id UUID := gen_random_uuid();
    template4_id UUID := gen_random_uuid();
    invoice1_id UUID := gen_random_uuid();
    invoice2_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user ID
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NULL THEN
        RAISE NOTICE 'No existing users found. Create user profiles first.';
        RETURN;
    END IF;
    
    -- Insert demo invoice templates
    INSERT INTO public.invoice_templates (id, template_name, category, description, template_data, preview_image_url, is_active)
    VALUES
        (template1_id, 'Classic Restaurant Bill', 'restaurant'::public.invoice_template_category,
         'Traditional restaurant billing format with table service details',
         '{"style": "classic", "colors": {"primary": "#2C3E50", "secondary": "#E74C3C"}, "sections": ["header", "items", "subtotal", "tax", "total", "footer"]}'::jsonb,
         'https://images.pexels.com/photos/958545/pexels-photo-958545.jpeg?auto=compress&cs=tinysrgb&w=800',
         true),
        (template2_id, 'Modern Retail Invoice', 'retail'::public.invoice_template_category,
         'Clean modern design for retail transactions with product catalog',
         '{"style": "modern", "colors": {"primary": "#3498DB", "secondary": "#2ECC71"}, "sections": ["header", "customer_info", "items", "pricing", "payment_terms"]}'::jsonb,
         'https://images.pexels.com/photos/4386431/pexels-photo-4386431.jpeg?auto=compress&cs=tinysrgb&w=800',
         true),
        (template3_id, 'Professional Services Invoice', 'services'::public.invoice_template_category,
         'Professional billing format for consulting and service businesses',
         '{"style": "professional", "colors": {"primary": "#34495E", "secondary": "#16A085"}, "sections": ["company_info", "client_info", "services", "hours", "rates", "summary"]}'::jsonb,
         'https://images.pexels.com/photos/7887816/pexels-photo-7887816.jpeg?auto=compress&cs=tinysrgb&w=800',
         true),
        (template4_id, 'Minimalist General Invoice', 'general'::public.invoice_template_category,
         'Simple clean design suitable for any business type',
         '{"style": "minimalist", "colors": {"primary": "#95A5A6", "secondary": "#7F8C8D"}, "sections": ["basic_info", "line_items", "total"]}'::jsonb,
         'https://images.pexels.com/photos/6694543/pexels-photo-6694543.jpeg?auto=compress&cs=tinysrgb&w=800',
         true);
    
    -- Insert sample invoices
    INSERT INTO public.invoices (id, invoice_number, template_id, created_by, customer_name, customer_email, customer_phone, customer_address, issue_date, due_date, subtotal, tax_amount, discount_amount, total_amount, status, notes)
    VALUES
        (invoice1_id, 'INV-000001', template1_id, existing_user_id, 'John Doe', 'john@example.com', '+1234567890',
         '123 Main Street, City, State 12345', CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days',
         850.00, 68.00, 0.00, 918.00, 'draft'::public.invoice_status, 'Table 12 - Lunch Service'),
        (invoice2_id, 'INV-000002', template2_id, existing_user_id, 'Jane Smith', 'jane@example.com', '+1234567891',
         '456 Oak Avenue, City, State 12345', CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '25 days',
         1250.00, 100.00, 50.00, 1300.00, 'sent'::public.invoice_status, 'Bulk order discount applied');
    
    -- Insert invoice items for invoice 1
    INSERT INTO public.invoice_items (invoice_id, item_name, description, quantity, unit_price, total_price)
    VALUES
        (invoice1_id, 'Grilled Salmon', 'Fresh Atlantic salmon with herbs', 2, 35.00, 70.00),
        (invoice1_id, 'Caesar Salad', 'Classic Caesar with homemade dressing', 2, 15.00, 30.00),
        (invoice1_id, 'Ribeye Steak', '12oz premium cut with sides', 1, 45.00, 45.00),
        (invoice1_id, 'Chocolate Lava Cake', 'Warm chocolate cake with ice cream', 3, 12.00, 36.00),
        (invoice1_id, 'Wine - Cabernet Sauvignon', 'House selection bottle', 1, 65.00, 65.00);
    
    -- Insert invoice items for invoice 2
    INSERT INTO public.invoice_items (invoice_id, item_name, description, quantity, unit_price, total_price)
    VALUES
        (invoice2_id, 'Wireless Mouse', 'Ergonomic design with USB receiver', 10, 25.00, 250.00),
        (invoice2_id, 'Keyboard - Mechanical', 'RGB backlit gaming keyboard', 5, 80.00, 400.00),
        (invoice2_id, 'USB-C Hub', '7-port multi-function hub', 8, 35.00, 280.00),
        (invoice2_id, 'Laptop Stand', 'Adjustable aluminum stand', 6, 45.00, 270.00),
        (invoice2_id, 'External SSD 1TB', 'Portable storage drive', 2, 125.00, 250.00);
END $$;
-- Location: supabase/migrations/20251211122800_security_alerts_module.sql
-- Schema Analysis: Existing user_profiles table with role-based access
-- Integration Type: NEW_MODULE - Security alert system for cash theft incidents
-- Dependencies: user_profiles (for user relationships)

-- 1. Create ENUM types for alert system
CREATE TYPE public.alert_severity AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE public.alert_status AS ENUM ('active', 'investigating', 'resolved', 'false_alarm');

-- 2. Create security_alerts table
CREATE TABLE public.security_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_type TEXT NOT NULL,
    severity public.alert_severity NOT NULL DEFAULT 'medium'::public.alert_severity,
    status public.alert_status NOT NULL DEFAULT 'active'::public.alert_status,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    location TEXT,
    amount_stolen DECIMAL(10,2),
    reported_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    assigned_to UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    incident_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create indexes for performance
CREATE INDEX idx_security_alerts_reported_by ON public.security_alerts(reported_by);
CREATE INDEX idx_security_alerts_assigned_to ON public.security_alerts(assigned_to);
CREATE INDEX idx_security_alerts_status ON public.security_alerts(status);
CREATE INDEX idx_security_alerts_severity ON public.security_alerts(severity);
CREATE INDEX idx_security_alerts_incident_time ON public.security_alerts(incident_time);

-- 4. Enable RLS
ALTER TABLE public.security_alerts ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS policies (Pattern 4: Public Read, Private Write for security team)
CREATE POLICY "all_users_can_view_security_alerts"
ON public.security_alerts
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "users_can_create_security_alerts"
ON public.security_alerts
FOR INSERT
TO authenticated
WITH CHECK (reported_by = auth.uid());

CREATE POLICY "assigned_users_can_update_security_alerts"
ON public.security_alerts
FOR UPDATE
TO authenticated
USING (assigned_to = auth.uid() OR reported_by = auth.uid());

-- 6. Create trigger for updated_at
CREATE TRIGGER update_security_alerts_updated_at
    BEFORE UPDATE ON public.security_alerts
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 7. Create helper function to get active alerts count
CREATE OR REPLACE FUNCTION public.get_active_security_alerts_count()
RETURNS BIGINT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT COUNT(*)
    FROM public.security_alerts
    WHERE status IN ('active', 'investigating');
$$;

-- 8. Mock data for demonstration
DO $$
DECLARE
    existing_user_id UUID;
    alert1_id UUID := gen_random_uuid();
    alert2_id UUID := gen_random_uuid();
    alert3_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user ID from user_profiles
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Create sample security alerts
        INSERT INTO public.security_alerts (
            id, alert_type, severity, status, title, description, 
            location, amount_stolen, reported_by, assigned_to, incident_time
        ) VALUES
            (
                alert1_id,
                'CASH_THEFT',
                'critical'::public.alert_severity,
                'active'::public.alert_status,
                'Cash Missing from Counter #3',
                'Approximately $500 missing from the main sales counter during evening shift. Detected during routine cash reconciliation.',
                'Counter #3 - Main Floor',
                500.00,
                existing_user_id,
                existing_user_id,
                CURRENT_TIMESTAMP - INTERVAL '2 hours'
            ),
            (
                alert2_id,
                'CASH_THEFT',
                'high'::public.alert_severity,
                'investigating'::public.alert_status,
                'Unaccounted Cash Shortage',
                'Daily cash count reveals $250 discrepancy. Security footage being reviewed.',
                'Counter #1 - North Wing',
                250.00,
                existing_user_id,
                existing_user_id,
                CURRENT_TIMESTAMP - INTERVAL '1 day'
            ),
            (
                alert3_id,
                'CASH_THEFT',
                'medium'::public.alert_severity,
                'resolved'::public.alert_status,
                'Minor Cash Discrepancy Resolved',
                'Initial report of $50 missing was resolved - determined to be counting error.',
                'Counter #2 - East Wing',
                50.00,
                existing_user_id,
                existing_user_id,
                CURRENT_TIMESTAMP - INTERVAL '3 days'
            );
    ELSE
        RAISE NOTICE 'No existing users found. Create user profiles first.';
    END IF;
END $$;
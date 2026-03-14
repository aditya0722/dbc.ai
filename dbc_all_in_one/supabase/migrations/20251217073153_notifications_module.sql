-- Location: supabase/migrations/20251217073153_notifications_module.sql
-- Schema Analysis: Existing schema with user_profiles, security_alerts, job_positions, invoices, etc.
-- Integration Type: NEW_MODULE - Adding comprehensive notification system
-- Dependencies: user_profiles (for user relationships)

-- 1. Create notification types enum
CREATE TYPE public.notification_type AS ENUM (
    'security',
    'inventory',
    'staff',
    'orders',
    'system',
    'gst',
    'payroll',
    'hiring',
    'marketplace'
);

-- 2. Create notification priority enum
CREATE TYPE public.notification_priority AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);

-- 3. Create notifications table
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    notification_type public.notification_type NOT NULL,
    priority public.notification_priority DEFAULT 'medium'::public.notification_priority,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    action_url TEXT,
    action_data JSONB,
    is_read BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    related_entity_id UUID,
    related_entity_type TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMPTZ,
    archived_at TIMESTAMPTZ
);

-- 4. Create indexes for performance
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_type ON public.notifications(notification_type);
CREATE INDEX idx_notifications_priority ON public.notifications(priority);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_notifications_is_archived ON public.notifications(is_archived);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX idx_notifications_user_unread ON public.notifications(user_id, is_read) WHERE is_read = false;

-- 5. Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS policies using Pattern 2 (Simple User Ownership)
CREATE POLICY "users_manage_own_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. Create function to get unread notification count
CREATE OR REPLACE FUNCTION public.get_unread_notification_count(target_user_id UUID)
RETURNS BIGINT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT COUNT(*)
    FROM public.notifications n
    WHERE n.user_id = target_user_id
    AND n.is_read = false
    AND n.is_archived = false
$$;

-- 8. Create function to mark notifications as read
CREATE OR REPLACE FUNCTION public.mark_notifications_as_read(notification_ids UUID[])
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.notifications
    SET is_read = true,
        read_at = CURRENT_TIMESTAMP
    WHERE id = ANY(notification_ids)
    AND user_id = auth.uid();
END;
$$;

-- 9. Create function to archive notifications
CREATE OR REPLACE FUNCTION public.archive_notifications(notification_ids UUID[])
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.notifications
    SET is_archived = true,
        archived_at = CURRENT_TIMESTAMP
    WHERE id = ANY(notification_ids)
    AND user_id = auth.uid();
END;
$$;

-- 10. Create trigger to automatically generate notifications from other modules
CREATE OR REPLACE FUNCTION public.create_notification_on_security_alert()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.notifications (
        user_id,
        notification_type,
        priority,
        title,
        message,
        action_url,
        related_entity_id,
        related_entity_type
    )
    SELECT 
        up.id,
        'security'::public.notification_type,
        CASE 
            WHEN NEW.severity = 'critical' THEN 'critical'::public.notification_priority
            WHEN NEW.severity = 'high' THEN 'high'::public.notification_priority
            ELSE 'medium'::public.notification_priority
        END,
        'New Security Alert: ' || NEW.title,
        NEW.description,
        '/security-alerts-dashboard',
        NEW.id,
        'security_alert'
    FROM public.user_profiles up
    WHERE up.role IN ('admin', 'manager', 'security');
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_security_alert_notification
AFTER INSERT ON public.security_alerts
FOR EACH ROW
EXECUTE FUNCTION public.create_notification_on_security_alert();

-- 11. Mock data for testing
DO $$
DECLARE
    user1_id UUID;
    user2_id UUID;
BEGIN
    -- Get existing user IDs
    SELECT id INTO user1_id FROM public.user_profiles WHERE email = 'hr@dbc.com' LIMIT 1;
    SELECT id INTO user2_id FROM public.user_profiles WHERE email = 'manager@dbc.com' LIMIT 1;

    -- Create sample notifications
    INSERT INTO public.notifications (user_id, notification_type, priority, title, message, action_url, related_entity_type)
    VALUES
        (user1_id, 'security'::public.notification_type, 'critical'::public.notification_priority, 
         'Critical: Unauthorized Access Detected', 
         'Multiple failed login attempts detected from IP 192.168.1.100', 
         '/live-camera-view', 'security_alert'),
        (user1_id, 'inventory'::public.notification_type, 'high'::public.notification_priority,
         'Low Stock Alert: Raw Materials', 
         'Flour stock is running low (15 kg remaining). Reorder recommended.',
         '/inventory-management', 'inventory_item'),
        (user2_id, 'staff'::public.notification_type, 'medium'::public.notification_priority,
         'Leave Request Pending', 
         'John Doe has submitted a leave request for approval.',
         '/staff-management', 'leave_request'),
        (user2_id, 'orders'::public.notification_type, 'high'::public.notification_priority,
         'New Order Received: #ORD-2547', 
         'Large catering order for 200 people. Preparation required by tomorrow.',
         '/order-management-hub', 'order'),
        (user1_id, 'system'::public.notification_type, 'low'::public.notification_priority,
         'System Backup Completed', 
         'Daily system backup completed successfully at 2:00 AM.',
         '/business-dashboard', 'system_backup'),
        (user2_id, 'gst'::public.notification_type, 'high'::public.notification_priority,
         'GST Filing Deadline Approaching', 
         'GST return for Q3 2025 is due in 5 days. Please file before deadline.',
         '/gst-filing-center', 'gst_filing'),
        (user1_id, 'payroll'::public.notification_type, 'medium'::public.notification_priority,
         'Payroll Processing Due', 
         'Monthly payroll processing is scheduled for December 25, 2025.',
         '/payroll-processing', 'payroll_run'),
        (user2_id, 'hiring'::public.notification_type, 'medium'::public.notification_priority,
         'New Job Application Received', 
         '3 new applications received for Kitchen Manager position.',
         '/hiring-marketplace', 'job_application');

    -- Mark some as read
    UPDATE public.notifications 
    SET is_read = true, read_at = CURRENT_TIMESTAMP 
    WHERE user_id = user1_id AND notification_type IN ('system'::public.notification_type);

END $$;
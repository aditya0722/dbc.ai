-- Location: supabase/migrations/20251217074036_notification_preferences.sql
-- Schema Analysis: Existing notifications table, user_profiles, notification_type and notification_priority enums
-- Integration Type: Extension - Adding notification preferences functionality
-- Dependencies: notifications, user_profiles tables

-- Create delivery method enum
CREATE TYPE public.delivery_method AS ENUM ('push', 'email', 'sms', 'all');

-- Create notification preferences table
CREATE TABLE public.notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE NOT NULL,
    
    -- Quiet hours configuration
    quiet_hours_enabled BOOLEAN DEFAULT false,
    quiet_hours_start TIME DEFAULT '22:00:00',
    quiet_hours_end TIME DEFAULT '07:00:00',
    
    -- Alert priorities preferences (which priorities to receive)
    enable_low_priority BOOLEAN DEFAULT true,
    enable_medium_priority BOOLEAN DEFAULT true,
    enable_high_priority BOOLEAN DEFAULT true,
    enable_critical_priority BOOLEAN DEFAULT true,
    
    -- Delivery methods per notification type
    security_delivery public.delivery_method DEFAULT 'all'::public.delivery_method,
    inventory_delivery public.delivery_method DEFAULT 'push'::public.delivery_method,
    staff_delivery public.delivery_method DEFAULT 'push'::public.delivery_method,
    orders_delivery public.delivery_method DEFAULT 'all'::public.delivery_method,
    system_delivery public.delivery_method DEFAULT 'push'::public.delivery_method,
    gst_delivery public.delivery_method DEFAULT 'email'::public.delivery_method,
    payroll_delivery public.delivery_method DEFAULT 'email'::public.delivery_method,
    hiring_delivery public.delivery_method DEFAULT 'email'::public.delivery_method,
    marketplace_delivery public.delivery_method DEFAULT 'push'::public.delivery_method,
    
    -- History management
    auto_archive_days INTEGER DEFAULT 30,
    auto_delete_archived_days INTEGER DEFAULT 90,
    
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure one preference record per user
    CONSTRAINT unique_user_preferences UNIQUE (user_id)
);

-- Create indexes for efficient querying
CREATE INDEX idx_notification_preferences_user_id ON public.notification_preferences(user_id);

-- Enable RLS
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users manage their own preferences
CREATE POLICY "users_manage_own_preferences"
ON public.notification_preferences
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Function to check if notification should be sent based on quiet hours
CREATE OR REPLACE FUNCTION public.is_within_quiet_hours(user_uuid UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    prefs RECORD;
    current_time_only TIME;
BEGIN
    SELECT quiet_hours_enabled, quiet_hours_start, quiet_hours_end
    INTO prefs
    FROM public.notification_preferences
    WHERE user_id = user_uuid;
    
    IF NOT FOUND OR NOT prefs.quiet_hours_enabled THEN
        RETURN false;
    END IF;
    
    current_time_only := CURRENT_TIME;
    
    -- Handle cases where quiet hours span midnight
    IF prefs.quiet_hours_start > prefs.quiet_hours_end THEN
        RETURN current_time_only >= prefs.quiet_hours_start OR current_time_only <= prefs.quiet_hours_end;
    ELSE
        RETURN current_time_only >= prefs.quiet_hours_start AND current_time_only <= prefs.quiet_hours_end;
    END IF;
END;
$$;

-- Function to auto-create default preferences for new users
CREATE OR REPLACE FUNCTION public.create_default_notification_preferences()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.notification_preferences (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;

-- Trigger to create preferences when user profile is created
CREATE TRIGGER create_notification_preferences_on_user
    AFTER INSERT ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.create_default_notification_preferences();

-- Function to auto-archive old notifications
CREATE OR REPLACE FUNCTION public.auto_archive_old_notifications()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.notifications n
    SET is_archived = true, archived_at = CURRENT_TIMESTAMP
    FROM public.notification_preferences np
    WHERE n.user_id = np.user_id
    AND n.is_archived = false
    AND n.created_at < CURRENT_TIMESTAMP - (np.auto_archive_days || ' days')::INTERVAL;
END;
$$;

-- Function to auto-delete old archived notifications
CREATE OR REPLACE FUNCTION public.auto_delete_archived_notifications()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    DELETE FROM public.notifications n
    USING public.notification_preferences np
    WHERE n.user_id = np.user_id
    AND n.is_archived = true
    AND n.archived_at < CURRENT_TIMESTAMP - (np.auto_delete_archived_days || ' days')::INTERVAL;
END;
$$;

-- Create update trigger for updated_at
CREATE OR REPLACE FUNCTION public.update_notification_preferences_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_notification_preferences_timestamp
    BEFORE UPDATE ON public.notification_preferences
    FOR EACH ROW
    EXECUTE FUNCTION public.update_notification_preferences_updated_at();

-- Mock data: Create preferences for existing users
DO $$
DECLARE
    existing_user_id UUID;
BEGIN
    -- Get existing user IDs and create default preferences
    FOR existing_user_id IN 
        SELECT id FROM public.user_profiles 
        WHERE id NOT IN (SELECT user_id FROM public.notification_preferences)
    LOOP
        INSERT INTO public.notification_preferences (
            user_id,
            quiet_hours_enabled,
            quiet_hours_start,
            quiet_hours_end,
            enable_low_priority,
            enable_medium_priority,
            enable_high_priority,
            enable_critical_priority,
            auto_archive_days,
            auto_delete_archived_days
        ) VALUES (
            existing_user_id,
            false,
            '22:00:00',
            '07:00:00',
            true,
            true,
            true,
            true,
            30,
            90
        );
    END LOOP;
END $$;
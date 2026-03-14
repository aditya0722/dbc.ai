-- Location: supabase/migrations/20251211105704_staff_hiring_module.sql
-- Schema Analysis: No existing Supabase integration found - Creating fresh hiring module schema
-- Integration Type: NEW_MODULE (Staff Hiring Management)
-- Dependencies: Will create user_profiles table as intermediary for PostgREST compatibility

-- 1. Create Custom Types
CREATE TYPE public.application_status AS ENUM ('pending', 'reviewing', 'shortlisted', 'rejected', 'hired');
CREATE TYPE public.employment_type AS ENUM ('full_time', 'part_time', 'contract', 'internship');
CREATE TYPE public.experience_level AS ENUM ('entry', 'mid', 'senior', 'lead');

-- 2. Core Tables
-- User profiles table (intermediary for PostgREST compatibility)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role TEXT DEFAULT 'staff',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Job positions table
CREATE TABLE public.job_positions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    department TEXT NOT NULL,
    employment_type public.employment_type DEFAULT 'full_time'::public.employment_type,
    experience_level public.experience_level DEFAULT 'mid'::public.experience_level,
    location TEXT NOT NULL,
    salary_range TEXT,
    description TEXT NOT NULL,
    requirements TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    posted_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Job applications table
CREATE TABLE public.job_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_position_id UUID REFERENCES public.job_positions(id) ON DELETE CASCADE,
    candidate_name TEXT NOT NULL,
    candidate_email TEXT NOT NULL,
    candidate_phone TEXT NOT NULL,
    resume_url TEXT,
    cover_letter TEXT,
    years_of_experience INTEGER NOT NULL DEFAULT 0,
    current_company TEXT,
    linkedin_url TEXT,
    portfolio_url TEXT,
    status public.application_status DEFAULT 'pending'::public.application_status,
    applied_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    reviewed_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Interview schedules table
CREATE TABLE public.interview_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES public.job_applications(id) ON DELETE CASCADE,
    interview_date TIMESTAMPTZ NOT NULL,
    interview_type TEXT NOT NULL,
    interviewer_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    location TEXT,
    meeting_link TEXT,
    notes TEXT,
    status TEXT DEFAULT 'scheduled',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes for Performance
CREATE INDEX idx_user_profiles_id ON public.user_profiles(id);
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_job_positions_department ON public.job_positions(department);
CREATE INDEX idx_job_positions_is_active ON public.job_positions(is_active);
CREATE INDEX idx_job_applications_job_position_id ON public.job_applications(job_position_id);
CREATE INDEX idx_job_applications_status ON public.job_applications(status);
CREATE INDEX idx_job_applications_candidate_email ON public.job_applications(candidate_email);
CREATE INDEX idx_interview_schedules_application_id ON public.interview_schedules(application_id);
CREATE INDEX idx_interview_schedules_interview_date ON public.interview_schedules(interview_date);

-- 4. Trigger Function for Automatic User Profile Creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, phone, avatar_url, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'phone', ''),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', ''),
        COALESCE(NEW.raw_user_meta_data->>'role', 'staff')
    );
    RETURN NEW;
END;
$$;

-- 5. Create Trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 6. Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interview_schedules ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies

-- User Profiles Policies (Pattern 1: Core User Table - Simple ownership)
CREATE POLICY "users_view_own_profile"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (id = auth.uid());

CREATE POLICY "users_update_own_profile"
ON public.user_profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Job Positions Policies (Pattern 4: Public Read, Private Write)
CREATE POLICY "anyone_can_view_active_positions"
ON public.job_positions
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "hr_can_manage_positions"
ON public.job_positions
FOR ALL
TO authenticated
USING (posted_by = auth.uid())
WITH CHECK (posted_by = auth.uid());

-- Job Applications Policies (Public can create, only HR can view all)
CREATE POLICY "anyone_can_apply"
ON public.job_applications
FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "hr_can_view_all_applications"
ON public.job_applications
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "hr_can_update_applications"
ON public.job_applications
FOR UPDATE
TO authenticated
USING (reviewed_by = auth.uid() OR reviewed_by IS NULL)
WITH CHECK (reviewed_by = auth.uid());

-- Interview Schedules Policies (Pattern 2: Simple User Ownership)
CREATE POLICY "users_manage_own_interviews"
ON public.interview_schedules
FOR ALL
TO authenticated
USING (interviewer_id = auth.uid())
WITH CHECK (interviewer_id = auth.uid());

-- 8. Mock Data for Testing
DO $$
DECLARE
    hr_user_id UUID := gen_random_uuid();
    manager_user_id UUID := gen_random_uuid();
    job1_id UUID := gen_random_uuid();
    job2_id UUID := gen_random_uuid();
    app1_id UUID := gen_random_uuid();
    app2_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (hr_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'hr@dbc.com', crypt('hr123456', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "HR Manager", "phone": "+1234567890", "role": "hr"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (manager_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'manager@dbc.com', crypt('manager123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Department Manager", "phone": "+1234567891", "role": "manager"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create job positions
    INSERT INTO public.job_positions (id, title, department, employment_type, experience_level, location, salary_range, description, requirements, is_active, posted_by)
    VALUES
        (job1_id, 'Senior Software Engineer', 'Engineering', 'full_time'::public.employment_type, 'senior'::public.experience_level,
         'Remote', '$100,000 - $140,000',
         'We are looking for an experienced software engineer to join our growing team. You will work on cutting-edge projects using modern technologies.',
         'Bachelor''s degree in Computer Science or related field. 5+ years of professional experience. Strong knowledge of Flutter, Dart, and mobile development. Experience with Supabase or similar backend services.',
         true, hr_user_id),
        (job2_id, 'Security Operations Manager', 'Security', 'full_time'::public.employment_type, 'lead'::public.experience_level,
         'New York, NY', '$90,000 - $120,000',
         'Lead our security operations team in managing CCTV systems and ensuring facility safety. You will oversee security staff and implement best practices.',
         'Bachelor''s degree in Security Management or related field. 8+ years in security operations. Experience with CCTV systems and security protocols. Leadership and team management skills.',
         true, hr_user_id);

    -- Create job applications
    INSERT INTO public.job_applications (id, job_position_id, candidate_name, candidate_email, candidate_phone, years_of_experience, current_company, linkedin_url, status)
    VALUES
        (app1_id, job1_id, 'John Smith', 'john.smith@email.com', '+1555123456', 6,
         'Tech Solutions Inc', 'https://linkedin.com/in/johnsmith', 'shortlisted'::public.application_status),
        (app2_id, job2_id, 'Sarah Johnson', 'sarah.j@email.com', '+1555987654', 10,
         'SecureGuard Corp', 'https://linkedin.com/in/sarahjohnson', 'reviewing'::public.application_status);

    -- Create interview schedules
    INSERT INTO public.interview_schedules (application_id, interview_date, interview_type, interviewer_id, location, status)
    VALUES
        (app1_id, now() + interval '3 days', 'Technical Interview', manager_user_id, 'Video Call', 'scheduled'),
        (app2_id, now() + interval '2 days', 'Initial Screening', hr_user_id, 'Office - Room 301', 'scheduled');
END $$;

-- 9. Helper Functions
CREATE OR REPLACE FUNCTION public.get_application_count_by_status()
RETURNS TABLE(status public.application_status, count BIGINT)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT status, COUNT(*)::BIGINT
    FROM public.job_applications
    GROUP BY status
    ORDER BY status;
$$;

CREATE OR REPLACE FUNCTION public.get_active_positions_count()
RETURNS BIGINT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT COUNT(*)::BIGINT
    FROM public.job_positions
    WHERE is_active = true;
$$;
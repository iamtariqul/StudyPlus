-- Location: supabase/migrations/20250110101533_auth_and_user_profiles.sql
-- StudyPlus Authentication and User Management Module

-- 1. Custom Types
CREATE TYPE public.user_role AS ENUM ('student', 'admin');
CREATE TYPE public.grade_level AS ENUM ('elementary', 'middle_school', 'high_school', 'college', 'graduate');
CREATE TYPE public.account_status AS ENUM ('active', 'inactive', 'suspended');

-- 2. User Profiles Table (Critical intermediary for PostgREST compatibility)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'student'::public.user_role,
    grade_level public.grade_level,
    account_status public.account_status DEFAULT 'active'::public.account_status,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMPTZ,
    profile_image_url TEXT,
    bio TEXT,
    study_goals TEXT[],
    timezone TEXT DEFAULT 'UTC'
);

-- 3. Study Sessions Table
CREATE TABLE public.study_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    subject TEXT NOT NULL,
    session_type TEXT DEFAULT 'study',
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,
    is_completed BOOLEAN DEFAULT false
);

-- 4. Study Subjects Table
CREATE TABLE public.study_subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color_code TEXT DEFAULT '#2196F3',
    target_daily_minutes INTEGER DEFAULT 60,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_study_sessions_user_id ON public.study_sessions(user_id);
CREATE INDEX idx_study_sessions_created_at ON public.study_sessions(created_at);
CREATE INDEX idx_study_subjects_user_id ON public.study_subjects(user_id);

-- 6. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_subjects ENABLE ROW LEVEL SECURITY;

-- 7. Helper Functions for RLS
CREATE OR REPLACE FUNCTION public.is_profile_owner(profile_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = profile_id AND up.id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_session_owner(session_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.study_sessions ss
    WHERE ss.id = session_id AND ss.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_subject_owner(subject_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.study_subjects ss
    WHERE ss.id = subject_id AND ss.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'::public.user_role
)
$$;

-- 8. Trigger Function for Profile Creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role, grade_level)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'student'::public.user_role),
        COALESCE((NEW.raw_user_meta_data->>'grade_level')::public.grade_level, 'high_school'::public.grade_level)
    );
    RETURN NEW;
END;
$$;

-- 9. Trigger for Auto Profile Creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 10. Update Trigger for user_profiles
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 11. RLS Policies
CREATE POLICY "users_own_profile" ON public.user_profiles
FOR ALL TO authenticated
USING (public.is_profile_owner(id))
WITH CHECK (public.is_profile_owner(id));

CREATE POLICY "admins_view_all_profiles" ON public.user_profiles
FOR SELECT TO authenticated
USING (public.is_admin_user());

CREATE POLICY "users_own_sessions" ON public.study_sessions
FOR ALL TO authenticated
USING (public.is_session_owner(id))
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_own_subjects" ON public.study_subjects
FOR ALL TO authenticated
USING (public.is_subject_owner(id))
WITH CHECK (user_id = auth.uid());

-- 12. Mock Data for Testing
DO $$
DECLARE
    student_uuid UUID := gen_random_uuid();
    admin_uuid UUID := gen_random_uuid();
    math_subject_id UUID := gen_random_uuid();
    science_subject_id UUID := gen_random_uuid();
BEGIN
    -- Create complete auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (student_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'student@studyplus.com', crypt('StudyPass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Alex Johnson", "grade_level": "high_school"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@studyplus.com', crypt('AdminPass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Study Admin", "role": "admin"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create study subjects
    INSERT INTO public.study_subjects (id, user_id, name, color_code, target_daily_minutes)
    VALUES
        (math_subject_id, student_uuid, 'Mathematics', '#FF5722', 90),
        (science_subject_id, student_uuid, 'Science', '#4CAF50', 60);

    -- Create study sessions
    INSERT INTO public.study_sessions (user_id, subject, session_type, duration_minutes, notes, is_completed, completed_at)
    VALUES
        (student_uuid, 'Mathematics', 'study', 45, 'Worked on algebra problems', true, now() - interval '1 hour'),
        (student_uuid, 'Science', 'review', 30, 'Reviewed chemistry notes', true, now() - interval '2 hours'),
        (student_uuid, 'Mathematics', 'homework', 60, 'Completed calculus homework', false, null);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 13. Cleanup Function for Testing
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs for test accounts
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@studyplus.com';

    -- Delete in dependency order (children first, then auth.users last)
    DELETE FROM public.study_sessions WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.study_subjects WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);

    -- Delete auth.users last (after all references are removed)
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;
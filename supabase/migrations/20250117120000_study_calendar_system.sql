-- Location: supabase/migrations/20250117120000_study_calendar_system.sql
-- Study Calendar System Module - Building upon existing StudyPlus schema

-- 1. Calendar Event Types
CREATE TYPE public.calendar_event_type AS ENUM (
    'study_session',
    'assignment',
    'exam',
    'break',
    'reminder',
    'deadline',
    'custom'
);

CREATE TYPE public.event_priority AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE public.recurrence_type AS ENUM ('none', 'daily', 'weekly', 'monthly');

-- 2. Calendar Events Table
CREATE TABLE public.calendar_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    event_type public.calendar_event_type DEFAULT 'custom'::public.calendar_event_type,
    subject_id UUID REFERENCES public.study_subjects(id) ON DELETE SET NULL,
    start_datetime TIMESTAMPTZ NOT NULL,
    end_datetime TIMESTAMPTZ NOT NULL,
    is_all_day BOOLEAN DEFAULT false,
    location TEXT,
    priority public.event_priority DEFAULT 'medium'::public.event_priority,
    color_code TEXT DEFAULT '#2196F3',
    is_completed BOOLEAN DEFAULT false,
    recurrence_type public.recurrence_type DEFAULT 'none'::public.recurrence_type,
    recurrence_end_date TIMESTAMPTZ,
    reminder_minutes INTEGER DEFAULT 30,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CHECK (end_datetime > start_datetime),
    CHECK (reminder_minutes >= 0),
    CHECK (recurrence_end_date IS NULL OR recurrence_end_date > start_datetime)
);

-- 3. Study Schedule Templates Table
CREATE TABLE public.study_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Study Schedule Blocks Table
CREATE TABLE public.study_schedule_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id UUID REFERENCES public.study_schedules(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES public.study_subjects(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    session_type TEXT DEFAULT 'study',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CHECK (end_time > start_time)
);

-- 5. Assignment Calendar Integration Table
CREATE TABLE public.assignment_calendar (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subject_id UUID REFERENCES public.study_subjects(id) ON DELETE SET NULL,
    due_date TIMESTAMPTZ NOT NULL,
    priority public.event_priority DEFAULT 'medium'::public.event_priority,
    estimated_duration_minutes INTEGER DEFAULT 60,
    is_completed BOOLEAN DEFAULT false,
    completion_date TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CHECK (estimated_duration_minutes > 0),
    CHECK (completion_date IS NULL OR completion_date <= due_date)
);

-- 6. Essential Indexes
CREATE INDEX idx_calendar_events_user_id ON public.calendar_events(user_id);
CREATE INDEX idx_calendar_events_start_datetime ON public.calendar_events(start_datetime);
CREATE INDEX idx_calendar_events_end_datetime ON public.calendar_events(end_datetime);
CREATE INDEX idx_calendar_events_event_type ON public.calendar_events(event_type);
CREATE INDEX idx_calendar_events_subject_id ON public.calendar_events(subject_id);
CREATE INDEX idx_calendar_events_priority ON public.calendar_events(priority);

CREATE INDEX idx_study_schedules_user_id ON public.study_schedules(user_id);
CREATE INDEX idx_study_schedules_is_active ON public.study_schedules(is_active);

CREATE INDEX idx_study_schedule_blocks_schedule_id ON public.study_schedule_blocks(schedule_id);
CREATE INDEX idx_study_schedule_blocks_subject_id ON public.study_schedule_blocks(subject_id);
CREATE INDEX idx_study_schedule_blocks_day_of_week ON public.study_schedule_blocks(day_of_week);

CREATE INDEX idx_assignment_calendar_user_id ON public.assignment_calendar(user_id);
CREATE INDEX idx_assignment_calendar_due_date ON public.assignment_calendar(due_date);
CREATE INDEX idx_assignment_calendar_subject_id ON public.assignment_calendar(subject_id);
CREATE INDEX idx_assignment_calendar_is_completed ON public.assignment_calendar(is_completed);

-- 7. Enable RLS
ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_schedule_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignment_calendar ENABLE ROW LEVEL SECURITY;

-- 8. Helper Functions for RLS
CREATE OR REPLACE FUNCTION public.is_calendar_event_owner(event_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.calendar_events ce
    WHERE ce.id = event_id AND ce.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_schedule_owner(schedule_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.study_schedules ss
    WHERE ss.id = schedule_id AND ss.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_schedule_block_owner(block_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.study_schedule_blocks ssb
    JOIN public.study_schedules ss ON ssb.schedule_id = ss.id
    WHERE ssb.id = block_id AND ss.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_assignment_owner(assignment_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.assignment_calendar ac
    WHERE ac.id = assignment_id AND ac.user_id = auth.uid()
)
$$;

-- 9. Update Triggers
CREATE TRIGGER update_calendar_events_updated_at
    BEFORE UPDATE ON public.calendar_events
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER update_study_schedules_updated_at
    BEFORE UPDATE ON public.study_schedules
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER update_assignment_calendar_updated_at
    BEFORE UPDATE ON public.assignment_calendar
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 10. RLS Policies
CREATE POLICY "users_own_calendar_events" ON public.calendar_events
FOR ALL TO authenticated
USING (public.is_calendar_event_owner(id))
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_own_study_schedules" ON public.study_schedules
FOR ALL TO authenticated
USING (public.is_schedule_owner(id))
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_own_schedule_blocks" ON public.study_schedule_blocks
FOR ALL TO authenticated
USING (public.is_schedule_block_owner(id))
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.study_schedules ss
        WHERE ss.id = schedule_id AND ss.user_id = auth.uid()
    )
);

CREATE POLICY "users_own_assignment_calendar" ON public.assignment_calendar
FOR ALL TO authenticated
USING (public.is_assignment_owner(id))
WITH CHECK (user_id = auth.uid());

-- 11. Calendar Event Statistics Function
CREATE OR REPLACE FUNCTION public.get_calendar_stats(user_uuid UUID, start_date DATE, end_date DATE)
RETURNS TABLE(
    total_events INTEGER,
    completed_events INTEGER,
    pending_events INTEGER,
    study_sessions INTEGER,
    assignments INTEGER,
    exams INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::INTEGER as total_events,
        COUNT(CASE WHEN ce.is_completed THEN 1 END)::INTEGER as completed_events,
        COUNT(CASE WHEN NOT ce.is_completed THEN 1 END)::INTEGER as pending_events,
        COUNT(CASE WHEN ce.event_type = 'study_session' THEN 1 END)::INTEGER as study_sessions,
        COUNT(CASE WHEN ce.event_type = 'assignment' THEN 1 END)::INTEGER as assignments,
        COUNT(CASE WHEN ce.event_type = 'exam' THEN 1 END)::INTEGER as exams
    FROM public.calendar_events ce
    WHERE ce.user_id = user_uuid
    AND ce.start_datetime::DATE BETWEEN start_date AND end_date;
END;
$$;

-- 12. Mock Data for Testing
DO $$
DECLARE
    student_id UUID;
    math_subject_id UUID;
    science_subject_id UUID;
    default_schedule_id UUID := gen_random_uuid();
    study_event_id UUID := gen_random_uuid();
    assignment_event_id UUID := gen_random_uuid();
    exam_event_id UUID := gen_random_uuid();
    assignment_id UUID := gen_random_uuid();
BEGIN
    -- Get existing student and subjects
    SELECT id INTO student_id FROM public.user_profiles WHERE email = 'student@studyplus.com' LIMIT 1;
    SELECT id INTO math_subject_id FROM public.study_subjects WHERE name = 'Mathematics' LIMIT 1;
    SELECT id INTO science_subject_id FROM public.study_subjects WHERE name = 'Science' LIMIT 1;

    -- Create default study schedule
    INSERT INTO public.study_schedules (id, user_id, name, description, is_active)
    VALUES (default_schedule_id, student_id, 'Default Study Schedule', 'Regular weekly study schedule', true);

    -- Create study schedule blocks
    INSERT INTO public.study_schedule_blocks (schedule_id, subject_id, day_of_week, start_time, end_time, session_type)
    VALUES
        (default_schedule_id, math_subject_id, 1, '09:00:00', '10:30:00', 'study'),  -- Monday Math
        (default_schedule_id, science_subject_id, 1, '14:00:00', '15:30:00', 'study'), -- Monday Science
        (default_schedule_id, math_subject_id, 3, '09:00:00', '10:30:00', 'study'),  -- Wednesday Math
        (default_schedule_id, science_subject_id, 3, '14:00:00', '15:30:00', 'study'), -- Wednesday Science
        (default_schedule_id, math_subject_id, 5, '09:00:00', '10:30:00', 'review'), -- Friday Math Review
        (default_schedule_id, science_subject_id, 5, '14:00:00', '15:30:00', 'review'); -- Friday Science Review

    -- Create calendar events
    INSERT INTO public.calendar_events (
        id, user_id, title, description, event_type, subject_id, 
        start_datetime, end_datetime, priority, color_code, is_completed
    ) VALUES
        (study_event_id, student_id, 'Mathematics Study Session', 'Algebra and calculus practice', 
         'study_session', math_subject_id, 
         CURRENT_TIMESTAMP + INTERVAL '1 day', CURRENT_TIMESTAMP + INTERVAL '1 day 1 hour 30 minutes',
         'medium', '#FF5722', false),
        (assignment_event_id, student_id, 'Science Assignment Due', 'Chemistry lab report submission', 
         'assignment', science_subject_id, 
         CURRENT_TIMESTAMP + INTERVAL '3 days', CURRENT_TIMESTAMP + INTERVAL '3 days 1 hour',
         'high', '#F44336', false),
        (exam_event_id, student_id, 'Mathematics Exam', 'Midterm examination on calculus', 
         'exam', math_subject_id, 
         CURRENT_TIMESTAMP + INTERVAL '1 week', CURRENT_TIMESTAMP + INTERVAL '1 week 2 hours',
         'urgent', '#9C27B0', false);

    -- Create assignment calendar entries
    INSERT INTO public.assignment_calendar (
        id, user_id, title, subject_id, due_date, priority, 
        estimated_duration_minutes, is_completed, notes
    ) VALUES
        (assignment_id, student_id, 'Chemistry Lab Report', science_subject_id, 
         CURRENT_TIMESTAMP + INTERVAL '3 days', 'high', 120, false,
         'Complete analysis of chemical reactions experiment');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error in calendar mock data: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error in calendar mock data: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error in calendar mock data: %', SQLERRM;
END $$;

-- 13. Calendar Data Cleanup Function
CREATE OR REPLACE FUNCTION public.cleanup_calendar_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    student_id UUID;
BEGIN
    -- Get student ID
    SELECT id INTO student_id FROM public.user_profiles WHERE email = 'student@studyplus.com' LIMIT 1;

    -- Delete in dependency order (children first)
    DELETE FROM public.study_schedule_blocks WHERE schedule_id IN (
        SELECT id FROM public.study_schedules WHERE user_id = student_id
    );
    DELETE FROM public.study_schedules WHERE user_id = student_id;
    DELETE FROM public.calendar_events WHERE user_id = student_id;
    DELETE FROM public.assignment_calendar WHERE user_id = student_id;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents calendar cleanup: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Calendar cleanup failed: %', SQLERRM;
END;
$$;
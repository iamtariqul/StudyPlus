-- Location: supabase/migrations/20250117084233_subject_assignment_management.sql
-- StudyPlus Subject Management and Assignment Tracker Module

-- 1. Custom Types for Subject and Assignment Management
CREATE TYPE public.subject_status AS ENUM ('active', 'archived', 'completed');
CREATE TYPE public.assignment_status AS ENUM ('pending', 'in_progress', 'completed', 'overdue');
CREATE TYPE public.assignment_priority AS ENUM ('low', 'medium', 'high', 'urgent');

-- 2. Enhanced Subjects Table (Building on existing study_subjects)
ALTER TABLE public.study_subjects 
ADD COLUMN IF NOT EXISTS instructor TEXT,
ADD COLUMN IF NOT EXISTS credit_hours INTEGER DEFAULT 3,
ADD COLUMN IF NOT EXISTS current_grade TEXT,
ADD COLUMN IF NOT EXISTS grade_goal TEXT,
ADD COLUMN IF NOT EXISTS semester TEXT,
ADD COLUMN IF NOT EXISTS status public.subject_status DEFAULT 'active'::public.subject_status,
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

-- 3. Assignments Table
CREATE TABLE public.assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES public.study_subjects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ NOT NULL,
    priority public.assignment_priority DEFAULT 'medium'::public.assignment_priority,
    status public.assignment_status DEFAULT 'pending'::public.assignment_status,
    completion_percentage INTEGER DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    grade_received TEXT,
    points_possible INTEGER,
    points_earned INTEGER,
    submission_url TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ
);

-- 4. Assignment Attachments Table
CREATE TABLE public.assignment_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID REFERENCES public.assignments(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_type TEXT,
    file_size INTEGER,
    uploaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Subject Progress Table
CREATE TABLE public.subject_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID REFERENCES public.study_subjects(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    total_assignments INTEGER DEFAULT 0,
    completed_assignments INTEGER DEFAULT 0,
    average_grade DECIMAL(5,2),
    total_study_time_minutes INTEGER DEFAULT 0,
    last_activity TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(subject_id, user_id)
);

-- 6. Essential Indexes
CREATE INDEX idx_assignments_user_id ON public.assignments(user_id);
CREATE INDEX idx_assignments_subject_id ON public.assignments(subject_id);
CREATE INDEX idx_assignments_due_date ON public.assignments(due_date);
CREATE INDEX idx_assignments_status ON public.assignments(status);
CREATE INDEX idx_assignments_priority ON public.assignments(priority);
CREATE INDEX idx_assignment_attachments_assignment_id ON public.assignment_attachments(assignment_id);
CREATE INDEX idx_subject_progress_subject_id ON public.subject_progress(subject_id);
CREATE INDEX idx_subject_progress_user_id ON public.subject_progress(user_id);
CREATE INDEX idx_study_subjects_status ON public.study_subjects(status);
CREATE INDEX idx_study_subjects_semester ON public.study_subjects(semester);

-- 7. RLS Setup for New Tables
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignment_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subject_progress ENABLE ROW LEVEL SECURITY;

-- 8. Helper Functions for RLS
CREATE OR REPLACE FUNCTION public.is_assignment_owner(assignment_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.assignments a
    WHERE a.id = assignment_id AND a.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_assignment_attachment(attachment_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.assignment_attachments aa
    JOIN public.assignments a ON aa.assignment_id = a.id
    WHERE aa.id = attachment_id AND a.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_subject_progress(progress_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.subject_progress sp
    WHERE sp.id = progress_id AND sp.user_id = auth.uid()
)
$$;

-- 9. Update Triggers for timestamp management
CREATE TRIGGER update_assignments_updated_at
    BEFORE UPDATE ON public.assignments
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER update_subject_progress_updated_at
    BEFORE UPDATE ON public.subject_progress
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER update_study_subjects_updated_at
    BEFORE UPDATE ON public.study_subjects
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 10. Assignment Status Update Function
CREATE OR REPLACE FUNCTION public.update_assignment_status()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Auto-update status based on completion percentage
    IF NEW.completion_percentage = 100 THEN
        NEW.status = 'completed'::public.assignment_status;
        NEW.completed_at = CURRENT_TIMESTAMP;
    ELSIF NEW.completion_percentage > 0 THEN
        NEW.status = 'in_progress'::public.assignment_status;
    END IF;

    -- Check for overdue assignments
    IF NEW.due_date < CURRENT_TIMESTAMP AND NEW.status != 'completed'::public.assignment_status THEN
        NEW.status = 'overdue'::public.assignment_status;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER assignment_status_update
    BEFORE UPDATE ON public.assignments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_assignment_status();

-- 11. Subject Progress Update Function
CREATE OR REPLACE FUNCTION public.update_subject_progress_stats()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    subject_uuid UUID;
    user_uuid UUID;
    total_count INTEGER;
    completed_count INTEGER;
    avg_grade DECIMAL(5,2);
BEGIN
    -- Get subject and user IDs
    IF TG_OP = 'DELETE' THEN
        subject_uuid := OLD.subject_id;
        user_uuid := OLD.user_id;
    ELSE
        subject_uuid := NEW.subject_id;
        user_uuid := NEW.user_id;
    END IF;

    -- Calculate statistics
    SELECT COUNT(*), 
           COUNT(CASE WHEN status = 'completed' THEN 1 END),
           AVG(CASE WHEN points_possible > 0 AND points_earned IS NOT NULL 
                   THEN (points_earned::DECIMAL / points_possible::DECIMAL) * 100 
                   END)
    INTO total_count, completed_count, avg_grade
    FROM public.assignments
    WHERE subject_id = subject_uuid AND user_id = user_uuid;

    -- Update or insert progress record
    INSERT INTO public.subject_progress (subject_id, user_id, total_assignments, completed_assignments, average_grade)
    VALUES (subject_uuid, user_uuid, total_count, completed_count, avg_grade)
    ON CONFLICT (subject_id, user_id)
    DO UPDATE SET
        total_assignments = EXCLUDED.total_assignments,
        completed_assignments = EXCLUDED.completed_assignments,
        average_grade = EXCLUDED.average_grade,
        last_activity = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP;

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER update_subject_progress_on_assignment_change
    AFTER INSERT OR UPDATE OR DELETE ON public.assignments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_subject_progress_stats();

-- 12. RLS Policies
CREATE POLICY "users_own_assignments" ON public.assignments
FOR ALL TO authenticated
USING (public.is_assignment_owner(id))
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_own_assignment_attachments" ON public.assignment_attachments
FOR ALL TO authenticated
USING (public.can_access_assignment_attachment(id))
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.assignments a
        WHERE a.id = assignment_id AND a.user_id = auth.uid()
    )
);

CREATE POLICY "users_own_subject_progress" ON public.subject_progress
FOR ALL TO authenticated
USING (public.can_access_subject_progress(id))
WITH CHECK (user_id = auth.uid());

-- 13. Mock Data for Testing
DO $$
DECLARE
    student_uuid UUID;
    math_subject_id UUID;
    science_subject_id UUID;
    assignment1_id UUID := gen_random_uuid();
    assignment2_id UUID := gen_random_uuid();
    assignment3_id UUID := gen_random_uuid();
BEGIN
    -- Get existing test user and subjects
    SELECT id INTO student_uuid FROM public.user_profiles WHERE email = 'student@studyplus.com';
    SELECT id INTO math_subject_id FROM public.study_subjects WHERE user_id = student_uuid AND name = 'Mathematics';
    SELECT id INTO science_subject_id FROM public.study_subjects WHERE user_id = student_uuid AND name = 'Science';

    -- Update existing subjects with enhanced data
    UPDATE public.study_subjects 
    SET 
        instructor = 'Dr. Sarah Johnson',
        credit_hours = 4,
        current_grade = 'A-',
        grade_goal = 'A+',
        semester = 'Fall 2024',
        description = 'Advanced Calculus and Linear Algebra'
    WHERE id = math_subject_id;

    UPDATE public.study_subjects 
    SET 
        instructor = 'Prof. Michael Chen',
        credit_hours = 3,
        current_grade = 'B+',
        grade_goal = 'A',
        semester = 'Fall 2024',
        description = 'Organic Chemistry and Lab'
    WHERE id = science_subject_id;

    -- Create sample assignments
    INSERT INTO public.assignments (id, user_id, subject_id, title, description, due_date, priority, status, completion_percentage, points_possible, points_earned)
    VALUES
        (assignment1_id, student_uuid, math_subject_id, 'Calculus Problem Set 5', 'Complete problems 1-20 from Chapter 8', 
         CURRENT_TIMESTAMP + INTERVAL '3 days', 'high'::public.assignment_priority, 'in_progress'::public.assignment_status, 
         60, 100, null),
        (assignment2_id, student_uuid, science_subject_id, 'Chemistry Lab Report', 'Write lab report on organic synthesis experiment', 
         CURRENT_TIMESTAMP + INTERVAL '5 days', 'medium'::public.assignment_priority, 'pending'::public.assignment_status, 
         0, 50, null),
        (assignment3_id, student_uuid, math_subject_id, 'Midterm Exam Preparation', 'Study for upcoming midterm exam', 
         CURRENT_TIMESTAMP + INTERVAL '1 week', 'urgent'::public.assignment_priority, 'pending'::public.assignment_status, 
         25, 200, null);

    -- Create sample assignment attachments
    INSERT INTO public.assignment_attachments (assignment_id, file_name, file_url, file_type, file_size)
    VALUES
        (assignment1_id, 'problem_set_5.pdf', 'https://example.com/files/problem_set_5.pdf', 'application/pdf', 1024000),
        (assignment2_id, 'lab_instructions.pdf', 'https://example.com/files/lab_instructions.pdf', 'application/pdf', 512000);

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data creation failed: %', SQLERRM;
END $$;

-- 14. Functions for Frontend Integration
CREATE OR REPLACE FUNCTION public.get_subject_stats(subject_uuid UUID)
RETURNS TABLE(
    total_assignments INTEGER,
    completed_assignments INTEGER,
    pending_assignments INTEGER,
    overdue_assignments INTEGER,
    completion_rate DECIMAL(5,2),
    average_grade DECIMAL(5,2)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::INTEGER,
        COUNT(CASE WHEN a.status = 'completed' THEN 1 END)::INTEGER,
        COUNT(CASE WHEN a.status = 'pending' THEN 1 END)::INTEGER,
        COUNT(CASE WHEN a.status = 'overdue' THEN 1 END)::INTEGER,
        CASE 
            WHEN COUNT(*) > 0 THEN 
                ROUND((COUNT(CASE WHEN a.status = 'completed' THEN 1 END)::DECIMAL / COUNT(*)::DECIMAL) * 100, 2)
            ELSE 0
        END,
        AVG(CASE WHEN a.points_possible > 0 AND a.points_earned IS NOT NULL 
                THEN (a.points_earned::DECIMAL / a.points_possible::DECIMAL) * 100 
                END)::DECIMAL(5,2)
    FROM public.assignments a
    WHERE a.subject_id = subject_uuid AND a.user_id = auth.uid();
END;
$$;

CREATE OR REPLACE FUNCTION public.get_upcoming_assignments(days_ahead INTEGER DEFAULT 7)
RETURNS TABLE(
    id UUID,
    title TEXT,
    subject_name TEXT,
    due_date TIMESTAMPTZ,
    priority TEXT,
    status TEXT,
    completion_percentage INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id,
        a.title,
        s.name,
        a.due_date,
        a.priority::TEXT,
        a.status::TEXT,
        a.completion_percentage
    FROM public.assignments a
    JOIN public.study_subjects s ON a.subject_id = s.id
    WHERE a.user_id = auth.uid()
    AND a.due_date BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '1 day' * days_ahead
    AND a.status != 'completed'
    ORDER BY a.due_date ASC, a.priority DESC;
END;
$$;
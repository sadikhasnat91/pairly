-- ========================================================
-- Pairly — Video Call Signaling Table Fix
-- Execute in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/muqjxewkuymkzyjvipzc/sql
-- ========================================================

-- 1. Drop foreign key constraints that were blocking calls
ALTER TABLE public.video_call_sessions DROP CONSTRAINT IF EXISTS video_call_sessions_caller_id_fkey;
ALTER TABLE public.video_call_sessions DROP CONSTRAINT IF EXISTS video_call_sessions_receiver_id_fkey;
ALTER TABLE public.video_call_sessions DROP CONSTRAINT IF EXISTS video_call_sessions_connection_id_fkey;

-- 2. Ensure table structure is completely permissive and fast
CREATE TABLE IF NOT EXISTS public.video_call_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    connection_id TEXT NOT NULL,
    caller_id TEXT NOT NULL,
    receiver_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ringing',
    sdp_offer JSONB,
    sdp_answer JSONB,
    caller_candidates JSONB DEFAULT '[]'::jsonb,
    receiver_candidates JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Indexes
CREATE INDEX IF NOT EXISTS idx_video_sessions_receiver ON public.video_call_sessions(receiver_id, status);
CREATE INDEX IF NOT EXISTS idx_video_sessions_caller ON public.video_call_sessions(caller_id, status);

-- 4. Enable Supabase Realtime
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'video_call_sessions'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.video_call_sessions;
    END IF;
END $$;

-- 5. Permissive Row Level Security
ALTER TABLE public.video_call_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all operations for video_call_sessions" ON public.video_call_sessions;
DROP POLICY IF EXISTS "Participants can manage their video call sessions" ON public.video_call_sessions;

CREATE POLICY "Allow all operations for video_call_sessions" 
    ON public.video_call_sessions 
    FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- ========================================================
-- Pairly — Safe Arrival Feature Database Migration
-- Execute this SQL in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/muqjxewkuymkzyjvipzc/sql
-- ========================================================

-- 1. Table: user_safe_arrival_settings
-- Stores user's home location coordinates, geofence radius, and enabled status
CREATE TABLE IF NOT EXISTS public.user_safe_arrival_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    home_latitude DOUBLE PRECISION NOT NULL,
    home_longitude DOUBLE PRECISION NOT NULL,
    home_address TEXT,
    geofence_radius_meters DOUBLE PRECISION NOT NULL DEFAULT 150.0,
    enabled BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_safe_arrival_settings UNIQUE (user_id)
);

-- 2. Table: safe_arrival_events
-- Records genuine arrival events with idempotency protection
CREATE TABLE IF NOT EXISTS public.safe_arrival_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    connection_id TEXT REFERENCES public.partner_connections(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL DEFAULT 'arrival', -- 'arrival', 'departure'
    event_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    idempotency_key TEXT UNIQUE NOT NULL,
    processing_status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'sent', 'failed', 'suppressed'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Table: user_push_tokens
-- Stores FCM / device push notification tokens for Android devices
CREATE TABLE IF NOT EXISTS public.user_push_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    platform TEXT NOT NULL DEFAULT 'android',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_device_token UNIQUE (user_id, device_token)
);

-- 4. Table: notification_delivery_logs
-- Audit trail of delivered push notifications
CREATE TABLE IF NOT EXISTS public.notification_delivery_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    arrival_event_id UUID REFERENCES public.safe_arrival_events(id) ON DELETE CASCADE,
    recipient_user_id TEXT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    notification_type TEXT NOT NULL DEFAULT 'safe_arrival',
    delivery_status TEXT NOT NULL, -- 'sent', 'failed', 'offline_buffered'
    error_code TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================================
-- Enable Supabase Realtime for arrival events
-- ========================================================
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'safe_arrival_events'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.safe_arrival_events;
    END IF;
END $$;

-- ========================================================
-- Row Level Security (RLS) Policies
-- ========================================================
ALTER TABLE public.user_safe_arrival_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.safe_arrival_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_push_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_delivery_logs ENABLE ROW LEVEL SECURITY;

-- user_safe_arrival_settings: User can only access their own settings
CREATE POLICY "Users can manage their own safe arrival settings"
    ON public.user_safe_arrival_settings
    FOR ALL
    USING (auth.uid()::text = user_id)
    WITH CHECK (auth.uid()::text = user_id);

-- safe_arrival_events: Insert allowed by creator, Read allowed by creator and their partner
CREATE POLICY "Users can insert their own safe arrival events"
    ON public.safe_arrival_events
    FOR INSERT
    WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users and partners can view safe arrival events"
    ON public.safe_arrival_events
    FOR SELECT
    USING (
        auth.uid()::text = user_id
        OR EXISTS (
            SELECT 1 FROM public.partner_connections pc
            WHERE pc.id = safe_arrival_events.connection_id
            AND pc.status = 'active'
            AND pc."memberUids" ? auth.uid()::text
        )
    );

-- user_push_tokens: User can manage their own device tokens
CREATE POLICY "Users can manage their own push tokens"
    ON public.user_push_tokens
    FOR ALL
    USING (auth.uid()::text = user_id)
    WITH CHECK (auth.uid()::text = user_id);

-- notification_delivery_logs: Recipient can view their logs
CREATE POLICY "Users can view their notification delivery logs"
    ON public.notification_delivery_logs
    FOR SELECT
    USING (auth.uid()::text = recipient_user_id);


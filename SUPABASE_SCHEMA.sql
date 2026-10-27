-- ========================================================
-- Pairly Supabase Database Schema
-- Copy and run this script in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/muqjxewkuymkzyjvipzc/sql
-- ========================================================

-- 1. Users / Profiles Table
CREATE TABLE IF NOT EXISTS public.users (
    id TEXT PRIMARY KEY,
    email TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "photoUrl" TEXT,
    "statusMessage" TEXT,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Locations Table (Real-time live location tracking)
CREATE TABLE IF NOT EXISTS public.locations (
    uid TEXT PRIMARY KEY,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    accuracy DOUBLE PRECISION DEFAULT 0.0,
    altitude DOUBLE PRECISION,
    speed DOUBLE PRECISION,
    heading DOUBLE PRECISION,
    "isSharing" BOOLEAN DEFAULT true,
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Partner Connections Table (Pairs two users together)
CREATE TABLE IF NOT EXISTS public.partner_connections (
    id TEXT PRIMARY KEY,
    "memberUids" JSONB NOT NULL DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'disconnected', 'blocked'
    "blockedByUid" TEXT,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "acceptedAt" TIMESTAMPTZ,
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Connection Invites Table (6-character invite codes)
CREATE TABLE IF NOT EXISTS public.connection_invites (
    id TEXT PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    "creatorUid" TEXT NOT NULL,
    "creatorName" TEXT NOT NULL,
    "expiresAt" TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'accepted', 'expired'
    "createdAt" TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================================
-- Enable Supabase Realtime for instant live syncing
-- ========================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.locations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.partner_connections;
ALTER PUBLICATION supabase_realtime ADD TABLE public.connection_invites;

-- ========================================================
-- Enable Row Level Security (RLS) with permissive access
-- ========================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.connection_invites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all operations for users" ON public.users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations for locations" ON public.locations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations for partner_connections" ON public.partner_connections FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all operations for connection_invites" ON public.connection_invites FOR ALL USING (true) WITH CHECK (true);


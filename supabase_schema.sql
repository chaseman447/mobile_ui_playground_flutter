-- Supabase Database Schema for Mobile UI Playground
-- Run this SQL in your Supabase SQL editor to create the required tables

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- Create user_layouts table
CREATE TABLE IF NOT EXISTS public.user_layouts (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    layout_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, name)
);

-- Enable Row Level Security on user_layouts
ALTER TABLE public.user_layouts ENABLE ROW LEVEL SECURITY;

-- Create policies for user_layouts
-- Users can only see their own layouts
CREATE POLICY "Users can view their own layouts" ON public.user_layouts
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own layouts
CREATE POLICY "Users can insert their own layouts" ON public.user_layouts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own layouts
CREATE POLICY "Users can update their own layouts" ON public.user_layouts
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own layouts
CREATE POLICY "Users can delete their own layouts" ON public.user_layouts
    FOR DELETE USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER handle_user_layouts_updated_at
    BEFORE UPDATE ON public.user_layouts
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_layouts_user_id ON public.user_layouts(user_id);
CREATE INDEX IF NOT EXISTS idx_user_layouts_name ON public.user_layouts(user_id, name);
CREATE INDEX IF NOT EXISTS idx_user_layouts_created_at ON public.user_layouts(created_at DESC);

-- Insert some sample data (optional - remove in production)
-- INSERT INTO public.user_layouts (user_id, name, layout_data) VALUES
-- ('00000000-0000-0000-0000-000000000000', 'Sample Layout', '{"widgets": [], "theme": "default"}');

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.user_layouts TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.user_layouts_id_seq TO authenticated;
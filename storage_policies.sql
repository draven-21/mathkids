-- ============================================================
-- STORAGE POLICIES FOR AVATARS BUCKET
-- Execute this script in Supabase SQL Editor after creating
-- the 'avatars' storage bucket
-- ============================================================

-- Enable RLS on storage.objects if not already enabled
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (for re-running script)
DROP POLICY IF EXISTS "Allow anonymous users to upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow anonymous users to update avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow anonymous users to delete avatars" ON storage.objects;
DROP POLICY IF EXISTS "Public avatar read access" ON storage.objects;

-- ============================================================
-- POLICY 1: Allow uploads to avatars bucket
-- ============================================================
CREATE POLICY "Allow anonymous users to upload avatars"
ON storage.objects
FOR INSERT
TO anon, authenticated
WITH CHECK (
  bucket_id = 'avatars'
);

-- ============================================================
-- POLICY 2: Allow updates to avatars bucket
-- ============================================================
CREATE POLICY "Allow anonymous users to update avatars"
ON storage.objects
FOR UPDATE
TO anon, authenticated
USING (
  bucket_id = 'avatars'
)
WITH CHECK (
  bucket_id = 'avatars'
);

-- ============================================================
-- POLICY 3: Allow deletes from avatars bucket
-- ============================================================
CREATE POLICY "Allow anonymous users to delete avatars"
ON storage.objects
FOR DELETE
TO anon, authenticated
USING (
  bucket_id = 'avatars'
);

-- ============================================================
-- POLICY 4: Allow public read access
-- ============================================================
CREATE POLICY "Public avatar read access"
ON storage.objects
FOR SELECT
TO public, anon, authenticated
USING (
  bucket_id = 'avatars'
);

-- ============================================================
-- VERIFICATION
-- ============================================================

-- Check that policies were created successfully
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
  AND policyname LIKE '%avatar%'
ORDER BY policyname;

-- ============================================================
-- NOTES FOR PRODUCTION
-- ============================================================

-- SECURITY WARNING:
-- These policies allow ANY user (anonymous or authenticated) to 
-- upload, update, and delete files in the avatars bucket.
--
-- This is appropriate for your current setup where users are
-- stored locally without Supabase Auth integration.
--
-- FOR PRODUCTION WITH AUTHENTICATION:
-- Replace 'true' conditions with more restrictive rules, e.g.:
--
-- For uploads (restrict to own folder):
-- WITH CHECK (
--   bucket_id = 'avatars' AND
--   auth.uid()::text = (storage.foldername(name))[1]
-- )
--
-- For updates/deletes (restrict to own files):
-- USING (
--   bucket_id = 'avatars' AND
--   auth.uid()::text = (storage.foldername(name))[1]
-- )

-- ============================================================
-- TROUBLESHOOTING
-- ============================================================

-- If uploads still fail after applying policies, check:
--
-- 1. Bucket exists and is named exactly 'avatars':
--    SELECT * FROM storage.buckets WHERE id = 'avatars';
--
-- 2. Bucket is public:
--    SELECT id, name, public FROM storage.buckets WHERE id = 'avatars';
--
-- 3. Policies are active:
--    SELECT policyname, cmd FROM pg_policies 
--    WHERE tablename = 'objects' AND policyname LIKE '%avatar%';
--
-- 4. Check if RLS is enabled:
--    SELECT tablename, rowsecurity FROM pg_tables 
--    WHERE schemaname = 'storage' AND tablename = 'objects';

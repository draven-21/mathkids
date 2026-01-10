-- ============================================================
-- BUCKET ONLY FIX - No Policy Changes
-- This creates the bucket without touching storage policies
-- ============================================================

-- Step 1: Create the avatars bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars', 
    'avatars', 
    true, 
    5242880, -- 5MB
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Add avatar columns to users table
ALTER TABLE users
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS avatar_uploaded_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS avatar_file_size INTEGER,
ADD COLUMN IF NOT EXISTS avatar_mime_type VARCHAR(100);

-- ============================================================
-- MANUAL POLICY SETUP REQUIRED
-- ============================================================

-- After running this SQL, you MUST create policies in Supabase Dashboard:

-- 1. Go to Supabase Dashboard → Storage
-- 2. Click on the "avatars" bucket (should now exist)
-- 3. Go to Policies tab
-- 4. Click "New Policy"
-- 5. Create these 4 policies:

-- Policy 1: "Allow avatar uploads"
-- - For: INSERT
-- - Roles: anon, authenticated  
-- - Policy definition: bucket_id = 'avatars'

-- Policy 2: "Allow avatar updates"
-- - For: UPDATE
-- - Roles: anon, authenticated
-- - Policy definition: bucket_id = 'avatars'

-- Policy 3: "Allow avatar deletions" 
-- - For: DELETE
-- - Roles: anon, authenticated
-- - Policy definition: bucket_id = 'avatars'

-- Policy 4: "Public avatar access"
-- - For: SELECT
-- - Roles: anon, authenticated, public
-- - Policy definition: bucket_id = 'avatars'

-- ============================================================
-- VERIFICATION
-- ============================================================

-- Check if bucket was created
SELECT id, name, public, file_size_limit FROM storage.buckets WHERE id = 'avatars';

-- Check if avatar columns were added
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'users' 
AND column_name IN ('avatar_url', 'avatar_uploaded_at', 'avatar_file_size', 'avatar_mime_type')
ORDER BY column_name;

-- ============================================================
-- NEXT STEPS
-- ============================================================

-- 1. Run this SQL file (creates bucket + database columns)
-- 2. Create the 4 policies manually in Supabase Dashboard (as above)
-- 3. Test avatar upload in your app
-- 4. The debug logs should show successful upload

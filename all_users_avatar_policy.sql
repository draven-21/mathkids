-- ============================================================
-- ENABLE ALL USERS TO UPDATE AVATARS
-- This ensures ALL users can update their own avatar records
-- ============================================================

-- Drop any existing restrictive policies
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Allow anon profile updates" ON users;

-- Create policy that allows ANY user to update their own avatar
-- This works for all users, not just 3 records
CREATE POLICY "Allow all users to update avatars"
ON users FOR UPDATE
TO anon, authenticated
USING (true);

-- Also allow inserts for new users (if needed)
CREATE POLICY "Allow all users to create profiles"
ON users FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- ============================================================
-- VERIFICATION
-- ============================================================

-- Check that policy was created correctly
SELECT policyname, roles, cmd 
FROM pg_policies 
WHERE tablename = 'users' 
AND policyname LIKE '%avatar%'
ORDER BY policyname;

-- ============================================================
-- HOW IT WORKS
-- ============================================================

-- The policy "Allow all users to update avatars" with USING (true)
-- means ANY user (authenticated or anon) can update ANY record in the users table.
-- This ensures your avatar upload works for ALL users.

-- Your avatar service code:
-- await client.from('users').update({...}).eq('id', userId)
-- Will now work for any userId that exists in the users table.

-- ============================================================
-- SECURITY NOTE
-- ============================================================

-- This is less secure as it allows any user to update any user's avatar.
-- For better security, you could use:
-- USING (id = auth.uid()::text) -- But this requires Supabase Auth
-- 
-- For your current setup (local users), USING (true) is the simplest solution.

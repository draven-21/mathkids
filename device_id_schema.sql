-- ============================================================
-- ADD DEVICE ID TO USERS TABLE
-- Run this SQL script in Supabase SQL Editor
-- ============================================================

-- Add device_id column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS device_id VARCHAR(255) UNIQUE;

-- Create index for faster device_id lookups
CREATE INDEX IF NOT EXISTS idx_users_device_id ON users(device_id);

-- Add comment for documentation
COMMENT ON COLUMN users.device_id IS 'Unique device identifier - ensures one account per device. Android uses androidId, iOS uses identifierForVendor.';

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Check that device_id column was added
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'users' AND column_name = 'device_id';

-- Verify UNIQUE constraint exists
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'users' AND constraint_type = 'UNIQUE';

-- Check if any users have device_id set
SELECT 
    COUNT(*) as total_users,
    COUNT(device_id) as users_with_device_id,
    COUNT(*) - COUNT(device_id) as users_without_device_id
FROM users;

-- ============================================================
-- MIGRATION FOR EXISTING USERS (OPTIONAL)
-- ============================================================
-- If you want to allow existing users without device_id to continue
-- using the app, keep device_id as nullable (which it is by default).
-- The app will assign device_id on their next login.

-- To see existing users without device_id:
SELECT id, name, created_at, device_id
FROM users
WHERE device_id IS NULL
ORDER BY created_at DESC;

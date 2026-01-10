-- ============================================================
-- Avatar Schema for MathKids App
-- Adds support for user-uploaded profile pictures
-- ============================================================

-- Add avatar_url column to users table
ALTER TABLE users
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS avatar_uploaded_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS avatar_file_size INTEGER,
ADD COLUMN IF NOT EXISTS avatar_mime_type VARCHAR(100);

-- Create index for faster avatar queries
CREATE INDEX IF NOT EXISTS idx_users_avatar_url ON users(avatar_url) WHERE avatar_url IS NOT NULL;

-- Add comments for documentation
COMMENT ON COLUMN users.avatar_url IS 'Public URL to user uploaded avatar image stored in Supabase Storage';
COMMENT ON COLUMN users.avatar_uploaded_at IS 'Timestamp when avatar was last uploaded or updated';
COMMENT ON COLUMN users.avatar_file_size IS 'Size of avatar file in bytes';
COMMENT ON COLUMN users.avatar_mime_type IS 'MIME type of avatar file (e.g., image/jpeg, image/png)';

-- ============================================================
-- TRIGGERS AND FUNCTIONS
-- ============================================================

-- Create function to auto-update avatar timestamp
CREATE OR REPLACE FUNCTION update_avatar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.avatar_url IS DISTINCT FROM OLD.avatar_url THEN
        NEW.avatar_uploaded_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-updating timestamp
DROP TRIGGER IF EXISTS trigger_update_avatar_timestamp ON users;
CREATE TRIGGER trigger_update_avatar_timestamp
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_avatar_timestamp();

-- ============================================================
-- AVATAR CLEANUP SYSTEM
-- ============================================================

-- Create cleanup queue table for tracking old avatars
CREATE TABLE IF NOT EXISTS avatar_cleanup_queue (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    old_avatar_url TEXT NOT NULL,
    queued_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed BOOLEAN DEFAULT FALSE,
    processed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, old_avatar_url)
);

-- Create index for cleanup queries
CREATE INDEX IF NOT EXISTS idx_avatar_cleanup_processed
ON avatar_cleanup_queue(processed, queued_at)
WHERE processed = FALSE;

-- Function to queue old avatars for cleanup
CREATE OR REPLACE FUNCTION cleanup_old_avatar()
RETURNS TRIGGER AS $$
BEGIN
    -- Queue old avatar URL for cleanup if it exists and is being changed
    IF OLD.avatar_url IS NOT NULL AND NEW.avatar_url IS DISTINCT FROM OLD.avatar_url THEN
        INSERT INTO avatar_cleanup_queue (user_id, old_avatar_url, queued_at)
        VALUES (OLD.id, OLD.avatar_url, NOW())
        ON CONFLICT (user_id, old_avatar_url) DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for cleanup queue
DROP TRIGGER IF EXISTS trigger_queue_avatar_cleanup ON users;
CREATE TRIGGER trigger_queue_avatar_cleanup
    AFTER UPDATE ON users
    FOR EACH ROW
    WHEN (OLD.avatar_url IS DISTINCT FROM NEW.avatar_url)
    EXECUTE FUNCTION cleanup_old_avatar();

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Function to get avatar URL with fallback to initials
CREATE OR REPLACE FUNCTION get_user_display_avatar(p_user_id UUID)
RETURNS TABLE (
    avatar_url TEXT,
    avatar_type VARCHAR(20),
    initials TEXT,
    background_color TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.avatar_url,
        CASE
            WHEN u.avatar_url IS NOT NULL THEN 'image'
            ELSE 'initials'
        END as avatar_type,
        CASE
            WHEN u.avatar_url IS NULL THEN u.avatar_initials
            ELSE NULL
        END as initials,
        CASE
            WHEN u.avatar_url IS NULL THEN u.avatar_color
            ELSE NULL
        END as background_color
    FROM users u
    WHERE u.id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- VIEWS
-- ============================================================

-- View for getting user profiles with avatar info
CREATE OR REPLACE VIEW user_profiles_with_avatars AS
SELECT
    u.id,
    u.name,
    u.avatar_initials,
    u.avatar_color,
    u.avatar_url,
    u.avatar_uploaded_at,
    u.total_points,
    u.current_level,
    u.current_streak,
    u.quizzes_completed,
    CASE
        WHEN u.total_questions_attempted > 0
        THEN ROUND((u.total_correct_answers::DECIMAL / u.total_questions_attempted) * 100)
        ELSE 0
    END AS average_score,
    CASE
        WHEN u.avatar_url IS NOT NULL THEN 'image'
        ELSE 'initials'
    END as avatar_type,
    u.created_at,
    u.last_activity_date
FROM users u;

-- Grant appropriate permissions
GRANT SELECT ON user_profiles_with_avatars TO authenticated, anon;

-- ============================================================
-- STORAGE BUCKET CONFIGURATION
-- ============================================================
-- Note: The following configuration should be applied in Supabase Dashboard -> Storage
--
-- Bucket Configuration:
-- - Bucket name: avatars
-- - Public: Yes (for displaying avatars)
-- - File size limit: 5MB
-- - Allowed MIME types: image/jpeg, image/jpg, image/png, image/webp, image/gif
--
-- Storage Policies (RLS):
--
-- 1. Allow authenticated users to upload their own avatar
--    Name: Users can upload their own avatar
--    Operation: INSERT
--    Target roles: authenticated
--    USING expression:
--    (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1])
--
-- 2. Allow authenticated users to update their own avatar
--    Name: Users can update their own avatar
--    Operation: UPDATE
--    Target roles: authenticated
--    USING expression:
--    (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1])
--
-- 3. Allow authenticated users to delete their own avatar
--    Name: Users can delete their own avatar
--    Operation: DELETE
--    Target roles: authenticated
--    USING expression:
--    (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1])
--
-- 4. Allow public read access to all avatars
--    Name: Public avatar access
--    Operation: SELECT
--    Target roles: public, authenticated, anon
--    USING expression:
--    bucket_id = 'avatars'
--
-- ============================================================

-- ============================================================
-- EXAMPLE USAGE QUERIES
-- ============================================================

-- Get user with avatar info:
-- SELECT * FROM user_profiles_with_avatars WHERE id = 'user-uuid';

-- Update user avatar:
-- UPDATE users
-- SET avatar_url = 'https://your-supabase-url.supabase.co/storage/v1/object/public/avatars/user-id/avatar.jpg',
--     avatar_file_size = 102400,
--     avatar_mime_type = 'image/jpeg'
-- WHERE id = 'user-uuid';

-- Remove user avatar (fallback to initials):
-- UPDATE users
-- SET avatar_url = NULL,
--     avatar_file_size = NULL,
--     avatar_mime_type = NULL
-- WHERE id = 'user-uuid';

-- Get leaderboard with avatars:
-- SELECT
--     u.id,
--     u.name,
--     u.total_points,
--     u.avatar_url,
--     CASE
--         WHEN u.avatar_url IS NOT NULL THEN 'image'
--         ELSE 'initials'
--     END as avatar_type,
--     u.avatar_initials,
--     u.avatar_color,
--     ROW_NUMBER() OVER (ORDER BY u.total_points DESC) AS rank
-- FROM users u
-- ORDER BY u.total_points DESC
-- LIMIT 100;

-- Get users needing avatar cleanup:
-- SELECT * FROM avatar_cleanup_queue WHERE processed = FALSE ORDER BY queued_at;

-- Mark cleanup as processed:
-- UPDATE avatar_cleanup_queue
-- SET processed = TRUE, processed_at = NOW()
-- WHERE id = 'cleanup-id';

-- ============================================================
-- END OF AVATAR SCHEMA
-- ============================================================

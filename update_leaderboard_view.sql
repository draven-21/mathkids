-- ============================================================
-- UPDATE LEADERBOARD VIEW TO INCLUDE AVATAR_URL
-- Run this SQL script in Supabase SQL Editor
-- ============================================================

-- Drop the existing view first (required when adding columns in different positions)
DROP VIEW IF EXISTS leaderboard;

-- Recreate the leaderboard view with avatar_url included
CREATE VIEW leaderboard AS
SELECT 
    id,
    name,
    avatar_initials,
    avatar_color,
    avatar_url,
    total_points,
    current_level,
    current_streak,
    quizzes_completed,
    CASE 
        WHEN total_questions_attempted > 0 
        THEN ROUND((total_correct_answers::DECIMAL / total_questions_attempted) * 100)
        ELSE 0 
    END AS average_score,
    ROW_NUMBER() OVER (ORDER BY total_points DESC) AS rank
FROM users
ORDER BY total_points DESC;

-- ============================================================
-- VERIFICATION
-- ============================================================

-- Verify the view includes avatar_url column
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'leaderboard'
ORDER BY ordinal_position;

-- Test query to see leaderboard data with avatars
SELECT id, name, avatar_url, rank, total_points 
FROM leaderboard 
LIMIT 10;

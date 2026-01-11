-- ============================================================
-- DATABASE CLEANUP SCRIPT (PRE-PUBLISH)
-- ============================================================
-- WARNING: This script will PERMANENTLY DELETE all user data.
-- Use this only when you want to reset the database for production.
-- ============================================================

-- Disable triggers temporarily to prevent side effects during cleanup
SET session_replication_role = 'replica';

-- 1. TRUNCATE USER DATA TABLES
-- We use TRUNCATE instead of DELETE because it's faster and resets sequences.
-- CASCADE is used to automatically clear dependent tables.

-- Verify tables exists before truncating to avoid errors
DO $$ 
BEGIN
    -- Truncate main users table (cascades to quiz_results, skill_progress, etc.)
    -- This handles: quiz_results, skill_progress, daily_activity, user_achievements (via foreign keys)
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
        TRUNCATE TABLE users CASCADE;
        RAISE NOTICE 'Truncated table: users (and cascaded dependencies)';
    END IF;

    -- Truncate avatar cleanup queue if it exists (not linked by FK usually)
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'avatar_cleanup_queue') THEN
        TRUNCATE TABLE avatar_cleanup_queue CASCADE;
        RAISE NOTICE 'Truncated table: avatar_cleanup_queue';
    END IF;
END $$;


-- ============================================================
-- TABLES PRESERVED (NOT TRUNCATED)
-- ============================================================
-- The following tables contain static game data and are NOT CLEARED:
-- - achievements (contains badge definitions)
-- - schema_migrations (if used)

-- The following are VIEWS and update automatically when data is cleared:
-- - weekly_scores
-- - leaderboard
-- - user_profiles_with_avatars

-- ============================================================
-- RE-ENABLE TRIGGERS
-- ============================================================
SET session_replication_role = 'origin';

-- ============================================================
-- OPTIONAL: RESET ACHIEVEMENTS SEED DATA
-- Uncomment below if you modified achievements and want to reset them to defaults
-- ============================================================
/*
TRUNCATE TABLE achievements CASCADE;
INSERT INTO achievements (name, description, icon_name, badge_color, requirement_type, requirement_value) VALUES
    ('Quick Learner', 'Complete 10 quizzes', 'flash_on', '#F39C12', 'quizzes_completed', 10),
    ('Math Master', 'Score 100% on 5 quizzes', 'emoji_events', '#27AE60', 'perfect_score', 5),
    ('Streak Hero', 'Maintain a 7-day streak', 'local_fire_department', '#E74C3C', 'streak', 7),
    ('Perfect Score', 'Get 100% on any quiz', 'star', '#9B59B6', 'perfect_score', 1),
    ('Century Club', 'Earn 100 total points', 'military_tech', '#4A90E2', 'points', 100),
    ('Math Wizard', 'Complete 50 quizzes', 'auto_awesome', '#E91E63', 'quizzes_completed', 50),
    ('Dedication', 'Maintain a 30-day streak', 'whatshot', '#FF5722', 'streak', 30),
    ('Addition Pro', 'Master addition (90% accuracy)', 'add_circle', '#4A90E2', 'skill_mastery', 90),
    ('Subtraction Pro', 'Master subtraction (90% accuracy)', 'remove_circle', '#F39C12', 'skill_mastery', 90),
    ('Multiplication Pro', 'Master multiplication (90% accuracy)', 'close', '#27AE60', 'skill_mastery', 90),
    ('Division Pro', 'Master division (90% accuracy)', 'horizontal_rule', '#9B59B6', 'skill_mastery', 90)
ON CONFLICT (name) DO NOTHING;
*/

-- Database cleanup completed successfully.

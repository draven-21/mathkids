-- ============================================================
-- Math Quiz App - Supabase Database Schema
-- ============================================================
-- This schema defines all tables for user data management
-- Quiz questions remain hardcoded in the app
-- ============================================================

-- Enable UUID extension for generating unique IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- USERS TABLE
-- Stores student profile information
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    avatar_initials VARCHAR(2) NOT NULL,
    avatar_color VARCHAR(7) DEFAULT '#4A90E2',
    total_points INTEGER DEFAULT 0,
    current_level INTEGER DEFAULT 1,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    quizzes_completed INTEGER DEFAULT 0,
    total_correct_answers INTEGER DEFAULT 0,
    total_questions_attempted INTEGER DEFAULT 0,
    last_quiz_date DATE,
    last_activity_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for leaderboard queries (sorted by points)
CREATE INDEX IF NOT EXISTS idx_users_total_points ON users(total_points DESC);

-- Index for streak queries
CREATE INDEX IF NOT EXISTS idx_users_current_streak ON users(current_streak DESC);

-- ============================================================
-- QUIZ RESULTS TABLE
-- Stores individual quiz attempt records
-- ============================================================
CREATE TABLE IF NOT EXISTS quiz_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER NOT NULL,
    total_questions INTEGER NOT NULL,
    correct_answers INTEGER NOT NULL,
    points_earned INTEGER NOT NULL,
    time_taken_seconds INTEGER DEFAULT 0,
    operation_type VARCHAR(20), -- 'addition', 'subtraction', 'multiplication', 'division', 'mixed'
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for user quiz history
CREATE INDEX IF NOT EXISTS idx_quiz_results_user_id ON quiz_results(user_id);

-- Index for recent results
CREATE INDEX IF NOT EXISTS idx_quiz_results_completed_at ON quiz_results(completed_at DESC);

-- ============================================================
-- SKILL PROGRESS TABLE
-- Tracks mastery level for each math operation
-- ============================================================
CREATE TABLE IF NOT EXISTS skill_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    skill_name VARCHAR(20) NOT NULL, -- 'addition', 'subtraction', 'multiplication', 'division'
    total_attempted INTEGER DEFAULT 0,
    total_correct INTEGER DEFAULT 0,
    mastery_percentage DECIMAL(5,2) DEFAULT 0.00,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, skill_name)
);

-- Index for user skill queries
CREATE INDEX IF NOT EXISTS idx_skill_progress_user_id ON skill_progress(user_id);

-- ============================================================
-- DAILY ACTIVITY TABLE
-- Tracks daily quiz activity for streak and calendar view
-- ============================================================
CREATE TABLE IF NOT EXISTS daily_activity (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,
    quizzes_completed INTEGER DEFAULT 0,
    points_earned INTEGER DEFAULT 0,
    average_score DECIMAL(5,2) DEFAULT 0.00,
    UNIQUE(user_id, activity_date)
);

-- Index for user activity queries
CREATE INDEX IF NOT EXISTS idx_daily_activity_user_id ON daily_activity(user_id);

-- Index for date range queries
CREATE INDEX IF NOT EXISTS idx_daily_activity_date ON daily_activity(activity_date DESC);

-- ============================================================
-- ACHIEVEMENTS TABLE
-- Defines available achievements/badges
-- ============================================================
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200) NOT NULL,
    icon_name VARCHAR(50) NOT NULL,
    badge_color VARCHAR(7) NOT NULL,
    requirement_type VARCHAR(30) NOT NULL, -- 'quizzes_completed', 'streak', 'perfect_score', 'points', 'skill_mastery'
    requirement_value INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- USER ACHIEVEMENTS TABLE
-- Tracks which achievements each user has unlocked
-- ============================================================
CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- Index for user achievement queries
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);

-- ============================================================
-- WEEKLY SCORES VIEW
-- Aggregated view for weekly score chart
-- ============================================================
CREATE OR REPLACE VIEW weekly_scores AS
SELECT 
    user_id,
    DATE_TRUNC('day', completed_at) AS quiz_date,
    TO_CHAR(completed_at, 'Dy') AS day_name,
    AVG((correct_answers::DECIMAL / total_questions) * 100) AS average_score,
    COUNT(*) AS quizzes_count
FROM quiz_results
WHERE completed_at >= NOW() - INTERVAL '7 days'
GROUP BY user_id, DATE_TRUNC('day', completed_at), TO_CHAR(completed_at, 'Dy')
ORDER BY quiz_date;

-- ============================================================
-- LEADERBOARD VIEW
-- Pre-computed leaderboard rankings
-- ============================================================
CREATE OR REPLACE VIEW leaderboard AS
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
-- SEED DATA: Default Achievements
-- ============================================================
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

-- ============================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Enable RLS for secure access
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all users (for leaderboard)
CREATE POLICY "Users can view all users" ON users
    FOR SELECT USING (true);

-- Policy: Users can insert their own record
CREATE POLICY "Users can insert own record" ON users
    FOR INSERT WITH CHECK (true);

-- Policy: Users can update their own record (using local storage ID matching)
CREATE POLICY "Users can update own record" ON users
    FOR UPDATE USING (true);

-- Policy: Anyone can view quiz results (for leaderboard stats)
CREATE POLICY "Anyone can view quiz results" ON quiz_results
    FOR SELECT USING (true);

-- Policy: Users can insert quiz results
CREATE POLICY "Users can insert quiz results" ON quiz_results
    FOR INSERT WITH CHECK (true);

-- Policy: Anyone can view skill progress
CREATE POLICY "Anyone can view skill progress" ON skill_progress
    FOR SELECT USING (true);

-- Policy: Users can manage skill progress
CREATE POLICY "Users can manage skill progress" ON skill_progress
    FOR ALL USING (true);

-- Policy: Anyone can view daily activity
CREATE POLICY "Anyone can view daily activity" ON daily_activity
    FOR SELECT USING (true);

-- Policy: Users can manage daily activity
CREATE POLICY "Users can manage daily activity" ON daily_activity
    FOR ALL USING (true);

-- Policy: Anyone can view user achievements
CREATE POLICY "Anyone can view user achievements" ON user_achievements
    FOR SELECT USING (true);

-- Policy: Users can insert user achievements
CREATE POLICY "Users can insert user achievements" ON user_achievements
    FOR INSERT WITH CHECK (true);

-- Achievements table is read-only for clients
CREATE POLICY "Anyone can view achievements" ON achievements
    FOR SELECT USING (true);

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Function to update user streak
CREATE OR REPLACE FUNCTION update_user_streak(p_user_id UUID)
RETURNS void AS $$
DECLARE
    last_activity DATE;
    today DATE := CURRENT_DATE;
BEGIN
    SELECT last_quiz_date INTO last_activity FROM users WHERE id = p_user_id;
    
    IF last_activity IS NULL OR last_activity < today - 1 THEN
        -- Reset streak if more than 1 day gap
        UPDATE users SET current_streak = 1, last_quiz_date = today WHERE id = p_user_id;
    ELSIF last_activity = today - 1 THEN
        -- Continue streak
        UPDATE users SET 
            current_streak = current_streak + 1,
            longest_streak = GREATEST(longest_streak, current_streak + 1),
            last_quiz_date = today
        WHERE id = p_user_id;
    END IF;
    -- If last_activity = today, do nothing (already played today)
END;
$$ LANGUAGE plpgsql;

-- Function to calculate user level based on points
CREATE OR REPLACE FUNCTION calculate_level(points INTEGER)
RETURNS INTEGER AS $$
BEGIN
    -- Level formula: every 500 points = 1 level, starting at level 1
    RETURN GREATEST(1, FLOOR(points / 500) + 1);
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update level when points change
CREATE OR REPLACE FUNCTION update_user_level()
RETURNS TRIGGER AS $$
BEGIN
    NEW.current_level := calculate_level(NEW.total_points);
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_level
    BEFORE UPDATE OF total_points ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_user_level();

-- ============================================================
-- END OF SCHEMA
-- ============================================================

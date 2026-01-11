# Debug Leaderboard Top 3 Sorting

## Test Query

Run this in Supabase SQL Editor to verify the leaderboard view is returning data correctly:

```sql
-- Check top 10 users with their ranks and points
SELECT 
    rank,
    name,
    total_points,
    avatar_url,
    quizzes_completed
FROM leaderboard
ORDER BY rank
LIMIT 10;
```

Expected results:
- rank 1 should have the HIGHEST total_points
- rank 2 should have the 2nd highest total_points
- rank 3 should have the 3rd highest total_points

## Verify User Data

Check if there are users with 0 points:

```sql
SELECT 
    name,
    total_points,
    quizzes_completed,
    created_at
FROM users
ORDER BY total_points DESC
LIMIT 10;
```

## Check for Ties

See if multiple users have the same points (which could cause ranking issues):

```sql
SELECT 
    total_points,
    COUNT(*) as user_count,
    STRING_AGG(name, ', ') as users
FROM users
GROUP BY total_points
HAVING COUNT(*) > 1
ORDER BY total_points DESC;
```

## Solution Applied

Added explicit sorting in the Flutter code to ensure the top 3 are always sorted by rank:

```dart
// Sort entries by rank (ascending) before displaying
final sortedEntries = entries..sort((a, b) => a.rank.compareTo(b.rank));
```

This guarantees that:
- Index 0 = Rank 1 (highest points)
- Index 1 = Rank 2 (2nd highest)
- Index 2 = Rank 3 (3rd highest)

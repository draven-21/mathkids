# Testing Supabase Connection

## Steps to Fix the Error:

1. **Run the SQL Schema First**
   - Go to your Supabase project dashboard
   - Navigate to SQL Editor
   - Copy and paste the contents of `supabase_schema.sql`
   - Click "Run" to create all tables and views

2. **Check Supabase Connection**
   - The app now reads credentials from `env.json`
   - Make sure `env.json` is in the root directory
   - The debug console will show if credentials are loaded

3. **Common Issues and Solutions**

### Error: "You must initialize the supabase instance"
- **Cause**: Supabase is not being initialized properly
- **Fix**: The app now reads from `env.json` automatically

### Error: "relation 'users' does not exist"
- **Cause**: SQL schema hasn't been executed
- **Fix**: Run the SQL schema in Supabase SQL Editor

### Error: "new row violates row-level security policy"
- **Cause**: RLS policies blocking operations
- **Fix**: The schema includes RLS policies, but they may need adjustment

## Debug Output
The app now logs:
- "Loaded Supabase credentials from env.json"
- "Supabase URL: Set/Not set"
- "Supabase Anon Key: Set/Not set"
- "Supabase initialized successfully"
- "Creating user: [name]"
- "User created successfully: [id]"

## Testing Steps
1. Run `flutter pub get`
2. Run the app with `flutter run`
3. Check debug console for initialization messages
4. Try entering a name in the app
5. Check for any error messages in debug console

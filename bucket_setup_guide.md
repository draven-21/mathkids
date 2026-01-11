# Supabase Storage Bucket Setup Guide

This guide will help you create the `avatars` storage bucket required for the avatar upload feature.

## Prerequisites

- Access to your Supabase Dashboard
- Project URL: `https://tbenbojiydqshxsygbvt.supabase.co`

## Step 1: Access Supabase Storage

1. Open your web browser and navigate to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Sign in with your Supabase account
3. Select your project (`tbenbojiydqshxsygbvt`)
4. Click on **Storage** in the left sidebar

## Step 2: Create the Avatars Bucket

1. Click the **New Bucket** button (usually in the top right)
2. Configure the bucket with these settings:
   - **Name**: `avatars` (must be exactly this name)
   - **Public bucket**: ✅ **Enable** (check this box)
   - **File size limit**: `5242880` (5MB in bytes)
   - **Allowed MIME types**: `image/jpeg,image/jpg,image/png,image/webp,image/gif`

3. Click **Create Bucket**

> [!IMPORTANT]
> The bucket name MUST be exactly `avatars` (lowercase, no spaces) as the app is hardcoded to use this name.

## Step 3: Configure Bucket Policies

After creating the bucket, you need to set up Row Level Security (RLS) policies:

1. In the Supabase Dashboard, go to **Storage** → **Policies**
2. Select the `avatars` bucket
3. Click **New Policy**

### Policy 1: Allow Anonymous Upload

- **Policy Name**: `Allow anonymous users to upload avatars`
- **Policy Command**: `INSERT`
- **Target Roles**: `anon`, `authenticated`
- **Policy Definition**:
  ```sql
  true
  ```

### Policy 2: Allow Anonymous Update

- **Policy Name**: `Allow anonymous users to update avatars`
- **Policy Command**: `UPDATE`
- **Target Roles**: `anon`, `authenticated`
- **Policy Definition**:
  ```sql
  true
  ```

### Policy 3: Allow Anonymous Delete

- **Policy Name**: `Allow anonymous users to delete avatars`
- **Policy Command**: `DELETE`
- **Target Roles**: `anon`, `authenticated`
- **Policy Definition**:
  ```sql
  true
  ```

### Policy 4: Allow Public Read

- **Policy Name**: `Public avatar read access`
- **Policy Command**: `SELECT`
- **Target Roles**: `public`, `anon`, `authenticated`
- **Policy Definition**:
  ```sql
  true
  ```

> [!NOTE]
> These policies allow all users to manage avatars because your app doesn't use Supabase Auth sessions. If you implement authentication later, you should update these policies to restrict access to `auth.uid()`.

## Alternative: Use SQL Script

Instead of creating policies manually, you can run the `storage_policies.sql` script:

1. Go to **SQL Editor** in Supabase Dashboard
2. Click **New Query**
3. Copy and paste the contents of `storage_policies.sql`
4. Click **Run**

## Step 4: Verify Setup

After completing the setup, verify everything is working:

1. Open the MathKids app
2. Navigate to the profile section
3. Tap on the avatar
4. Select "Choose from Gallery" or "Take a Photo"
5. Upload an image

If successful, you should see:
- ✅ "Avatar updated successfully!" message
- ✅ Your uploaded image displayed as the avatar
- ✅ File appears in Supabase Storage under `avatars/[user-id]/avatar_[timestamp].jpg`

## Troubleshooting

### Error: "Storage bucket 'avatars' not found"

**Solution**: Double-check that:
- The bucket name is exactly `avatars` (lowercase)
- The bucket was created successfully
- You're looking at the correct Supabase project

### Error: "Unauthorized" or "Permission Denied"

**Solution**: Verify that:
- Storage policies are configured correctly
- The bucket is marked as **Public**
- Policies target both `anon` and `authenticated` roles

### Error: "File too large"

**Solution**: 
- Ensure the file size limit is set to at least `5242880` bytes (5MB)
- Try uploading a smaller image
- The app automatically resizes images to 1024x1024 max

### Upload succeeds but image doesn't appear

**Solution**:
- Check that the bucket is set to **Public**
- Verify the `avatar_url` in the database points to a valid URL
- Clear the app cache and restart

## Need Help?

If you encounter issues not covered here:

1. Check the Flutter console logs for detailed error messages
2. Verify your Supabase project URL and anon key in `env.json`
3. Ensure the `users` table has the required avatar columns (see `avatar_schema.sql`)

## Security Considerations

> [!WARNING]
> The current setup allows any anonymous user to upload, update, or delete files. This is suitable for development but should be restricted in production.

**Recommended for Production**:
- Implement Supabase Auth for user authentication
- Update policies to use `auth.uid()` to restrict access to own avatars only
- Add server-side file validation
- Implement rate limiting to prevent abuse

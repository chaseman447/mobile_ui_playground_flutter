# Supabase Setup Guide

This guide will help you set up Supabase backend integration for your Mobile UI Playground Flutter app.

## Prerequisites

1. A Supabase account (sign up at [supabase.com](https://supabase.com))
2. Flutter development environment set up

## Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Choose your organization
4. Enter project name: `mobile-ui-playground`
5. Enter a secure database password
6. Choose your region
7. Click "Create new project"

## Step 2: Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (looks like: `https://your-project-id.supabase.co`)
   - **Anon public key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

## Step 3: Configure Your Flutter App

1. Open `lib/services/supabase_service.dart`
2. Replace the placeholder values:

```dart
// Replace these with your actual Supabase credentials
static const String supabaseUrl = 'https://your-project-id.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

## Step 4: Set Up Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Copy the contents of `supabase_schema.sql` from your project root
3. Paste it into the SQL Editor and click "Run"

This will create:
- `user_layouts` table for storing user layouts
- Row Level Security policies
- Necessary indexes for performance

## Step 5: Test the Integration

1. Run your Flutter app: `flutter run`
2. Navigate to the **Profile** tab
3. Try signing up with a test email
4. Check your email for verification (if email confirmation is enabled)
5. Sign in and test layout saving/loading

## Features Available

### Authentication
- ✅ User sign up
- ✅ User sign in
- ✅ User sign out
- ✅ Authentication state management

### Layout Management
- ✅ Save layouts to Supabase (when authenticated)
- ✅ Local storage fallback (when not authenticated)
- ✅ Sync layouts from Supabase
- ✅ Automatic backup to cloud

### UI Components
- ✅ Authentication screens
- ✅ Profile management
- ✅ Sync status indicators

## Development Mode

The app includes a "Skip Authentication (Dev Mode)" option for development purposes. This allows you to:
- Test the app without setting up Supabase
- Use local storage for layouts
- Focus on UI development

## Security Notes

1. **Never commit your Supabase credentials to version control**
2. The anon key is safe to use in client-side code (it's designed for this)
3. Row Level Security ensures users can only access their own data
4. Consider setting up email confirmation in production

## Troubleshooting

### Common Issues

1. **"Failed to initialize Supabase"**
   - Check your URL and anon key are correct
   - Ensure your Supabase project is active
   - Check your internet connection

2. **"User not authenticated" errors**
   - Make sure you're signed in
   - Check if your session has expired
   - Try signing out and back in

3. **Database errors**
   - Ensure you've run the schema SQL
   - Check Row Level Security policies are enabled
   - Verify your user has the correct permissions

### Debug Mode

The app logs Supabase operations to the console. Check your Flutter logs for detailed error messages:

```bash
flutter logs
```

## Next Steps

1. Set up email templates in Supabase Auth settings
2. Configure social login providers (Google, Apple, etc.)
3. Add real-time synchronization for collaborative features
4. Implement offline-first architecture with sync
5. Add user profile management features

## Support

For Supabase-specific issues, check:
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Supabase Community](https://github.com/supabase/supabase/discussions)
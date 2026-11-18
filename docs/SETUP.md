# Setup guide

## Requirements

- A Mac with **Xcode** (the project targets iOS 26.5 and uses Swift 5)
- An internet connection the first time, so Xcode can download the Swift packages
- Optional, only if you want your own backend: a free [Supabase](https://supabase.com) project

## Run the app

1. Clone the repository:
   ```
   git clone https://github.com/lowkey-tamad/UNICOM_MobDev.git
   cd UNICOM_MobDev
   ```
2. Open `UNICOM.xcodeproj` in Xcode.
3. Wait for Xcode to resolve the package **supabase-swift** (pinned to 2.55.4 in `Package.resolved`).
4. Pick an iPhone simulator and press **Run** (Cmd + R).

## Use your own Supabase project

The Supabase URL and publishable key are set in one place:

```
UNICOM/Controller/SupabaseManager.swift
```

Replace both values with the ones from your project's **Settings, API** page. Use the **publishable** (anon) key only. Never put a `service_role` or secret key in the app.

What your project needs is listed in [ARCHITECTURE.md](ARCHITECTURE.md#what-the-app-expects-from-supabase).

## Sign-up emails

Sign-up sends a 6-digit code to the user's email and the app checks it with `verifyOTP`. Supabase's built-in mailer is limited, so for real use set a custom SMTP sender in **Authentication, SMTP settings** (for example a dedicated Gmail account with an App Password).

## Common problems

| Problem | Fix |
|---|---|
| "Missing package product Supabase" | **File, Packages, Reset Package Caches**, then build again |
| Verification email never arrives | Check the SMTP settings and the spam folder |
| Posts or profiles do not load | Check the Supabase URL and key, and that the tables in ARCHITECTURE.md exist with row level security policies |

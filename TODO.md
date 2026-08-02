# Adalot Sathi — Task Tracker

## Backend (Laravel 12 + Sanctum) — ✅ VERIFIED LOCALLY (SQLite)
- [x] `composer.json` → Laravel 12 + Sanctum (Laravel 11 blocked by security advisories)
- [x] Env config: APP_NAME="Adalot Sathi API", timezone Asia/Dhaka, SQLite local / MySQL prod
- [x] Install API + Sanctum personal access tokens migration
- [x] User model (phone, role, subscription_tier, subscription_expires_at) + factory
- [x] LegalCase model (table `cases`, status enum) + factory + migration
- [x] Deadline model (event_type, status, reminder_days_before JSON) + factory + migration
- [x] DeviceToken + NotificationLog models/migrations
- [x] Form Requests (register, login, profile, case, deadline, device token)
- [x] Resources (User, Case, Deadline)
- [x] AuthController (register/login/logout/me/updateProfile)
- [x] CaseController (CRUD + search/filter + CaseLimitService)
- [x] DeadlineController (nested CRUD + upcoming + markCompleted)
- [x] DeviceTokenController (register/destroy)
- [x] Admin UserAdminController (index/show/update/destroy) + AdminMiddleware
- [x] Reminder command + job + FCM service + swappable SMS channel + schedule
- [x] Seeders: super admin, free-at-limit, paid lawyers, realistic BD cases/deadlines
- [x] `php artisan migrate` + `db:seed` run clean (8 users, 19 cases, 63 deadlines)
- [x] API verified via curl: login, register(422 dup phone), limit(403), closed-case(201)
- [ ] **DEFERRED (user):** Switch to MySQL `adalot_sathi` DB — will implement later
- [ ] API markdown reference

## Mobile (Flutter) — ✅ BUILDABLE & TESTED (wired to real API)
- [x] Install Flutter stable SDK (3.44.8 at ~/development/flutter)
- [x] `flutter create mobile` (org com.adalotsathi, no nested .git)
- [x] App identity: pubspec name "adalot_sathi", Android label "Adalot Sathi", package `com.adalotsathi.app`
- [x] Riverpod + flutter_secure_storage + dio + intl deps
- [x] Models (User, LegalCase, Deadline) matching API JSON
- [x] AuthRepository (ApiAuthRepository) + secure token storage
- [x] CaseRepository / DeadlineRepository / DeviceTokenRepository (API impl via dio + interceptors)
- [x] Auth screens (login/register) → real API
- [x] App shell: bottom nav (Today & Cases & Profile)
- [x] Home: today & upcoming grouped Overdue/Today/Week/Later
- [x] Case list (search/filter) + detail + add/edit form
- [x] Add/Edit deadline form (reminder_days_before 7/3/1)
- [x] Mark deadline complete
- [x] Profile: tier + usage bar + logout
- [x] Upgrade prompt screen on `case_limit_reached`
- [x] FCM device-token registration endpoint + deep-link routing (debug trigger in Home app bar)
- [x] `flutter analyze` clean (0 errors/warnings) + `flutter test` all passing
- [ ] Run on Pixel_9 emulator / physical Android device (user action)

## Shared / Followups
- [x] Root README maintained (progress + how to run)
- [ ] Commit to root git repo (single repo)
- [ ] Real SMS gateway integration (awaiting provider choice)
- [ ] Firebase Cloud Messaging credentials for real push


# Adalot Sathi — Task Tracker

## Connectivity Fix (login/register "could not reach server") — ✅ DONE
- [x] Add `android:usesCleartextTraffic="true"` to `mobile/android/app/src/main/AndroidManifest.xml`
- [x] Make API base URL configurable via `--dart-define=API_BASE_URL` in `mobile/lib/core/config/app_config.dart`
- [x] Verify backend reachable (server running on 0.0.0.0:8000, DB migrated+seeded — login returns HTTP 200)
- [ ] Run `flutter analyze`

## Backend (Laravel 12 + Sanctum) — ✅ VERIFIED LOCALLY (SQLite)
- [x] `composer.json` → Laravel 12 + Sanctum
- [x] Env config: APP_NAME="Adalot Sathi API", timezone Asia/Dhaka, SQLite local / MySQL prod
- [x] Install API + Sanctum personal access tokens migration
- [x] User model + factory
- [x] LegalCase model + factory + migration
- [x] Deadline model + factory + migration
- [x] DeviceToken + NotificationLog models/migrations
- [x] Form Requests
- [x] Resources
- [x] AuthController
- [x] CaseController
- [x] DeadlineController
- [x] DeviceTokenController
- [x] Admin UserAdminController + AdminMiddleware
- [x] Reminder command + job + FCM service + SMS channel + schedule
- [x] Seeders
- [x] `php artisan migrate` + `db:seed` run clean
- [x] API verified via curl
- [ ] **DEFERRED (user):** Switch to MySQL `adalot_sathi` DB — will implement later
- [ ] API markdown reference

## Mobile (Flutter) — ✅ BUILDABLE & TESTED (wired to real API)
- [x] Install Flutter stable SDK (3.44.8)
- [x] `flutter create mobile`
- [x] App identity: pubspec "adalot_sathi", Android label "Adalot Sathi", package `com.adalotsathi.app`
- [x] Riverpod + flutter_secure_storage + dio + intl deps
- [x] Models matching API JSON
- [x] AuthRepository + secure token storage
- [x] CaseRepository / DeadlineRepository / DeviceTokenRepository
- [x] Auth screens (login/register) → real API
- [x] App shell: bottom nav
- [x] Home: today & upcoming
- [x] Case list + detail + form
- [x] Deadline form
- [x] Mark deadline complete
- [x] Profile
- [x] Upgrade prompt screen
- [x] FCM device-token registration + deep-link routing
- [x] `flutter analyze` clean + `flutter test` passing
- [ ] Run on Pixel_9 emulator / physical Android device (user action)

## Shared / Followups
- [x] Root README maintained
- [ ] Commit to root git repo
- [ ] Real SMS gateway integration
- [ ] Firebase Cloud Messaging credentials

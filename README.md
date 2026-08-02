# Adalot Sathi (আদালত সাথী)

**Legal Case Deadline Manager for Bangladesh** — a mobile app for lawyers and small
law firms in Bangladesh. Centralizes every case and its deadlines in one place and
sends multi-stage reminders (push notification + SMS) so no deadline is missed.

## Architecture

Monorepo with two apps:

```
adalot-sathi/
├── backend/   ← Laravel 12 REST API (Sanctum auth, MySQL for production)
├── mobile/    ← Flutter app (Android-first, iOS later)
└── README.md  ← this file
```

Single git repository at the root. No nested `.git` folders.

## Business Model

| | Free | Paid (Adalot Sathi Plus) |
|---|---|---|
| Active cases | 5 max | Unlimited |
| Push notifications | ✅ | ✅ |
| SMS reminders | ❌ | ✅ (৳99–149/mo or annual) |

A future "firm" tier is planned (multi-user under one firm, shared billing).
The `User`/`LegalCase` ownership model is designed so adding a `firm_id` later
is a straightforward migration — `cases.user_id` already exists as the owner
foreign key and no assumption hardcodes "one person owns a case forever".

## Status

### Backend (backend/) — ✅ COMPLETE (core)

- **Laravel 12.64** + **Sanctum** token auth, MySQL-ready (SQLite used for local dev)
- App name: **"Adalot Sathi API"** (`config/app.php`), timezone `Asia/Dhaka`
- Models: `User` (role: admin/lawyer, subscription_tier: free/paid),
  `LegalCase` (table `cases`, status active/closed/on_hold),
  `Deadline` (status pending/completed/missed, reminder_days_before JSON [7,3,1]),
  `DeviceToken` (FCM), `NotificationLog`
- **Free-tier limit enforced server-side** via `CaseLimitService`:
  HTTP 403 `case_limit_reached` on a 6th active case for free users.
  Grandfathering: paid→free drop-back keeps existing cases visible/editable,
  only new active-case creation is blocked until under the limit.
- Full CRUD for cases & nested deadlines, search/filter, upcoming-deadlines
  endpoint, mark-deadline-completed endpoint, admin user-management endpoints.
- Reminder infrastructure: daily scheduled command → `SendDeadlineReminderJob`
  branching free (push only) vs paid (push + SMS) → `FcmPushService` +
  swappable `SmsChannel` (stub until a BTRC-approved SMS provider is chosen) →
  `notification_log` audit table.
- Form Request validation, API Resource classes, uniform JSON error envelope,
  seeders/factories (super admin + free-tier-at-limit + paid-tier lawyers).

### Mobile (mobile/) — 🔨 IN PROGRESS

Flutter app wired directly to the real API via repository interfaces (Riverpod).

### Running the Backend

```bash
cd backend
composer install
cp .env.example .env          # set DB_* / app name
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

API base: `http://127.0.0.1:8000/api/v1`

### Seed Credentials

| Role | Email | Password |
|---|---|---|
| **Super Admin** | `admin@adalotsathi.com` | `Admin@1234` |
| Free lawyer (at 5-case limit) | `tanvir@example.com` | `Password@123` |
| Paid lawyer | `nusrat@example.com` | `Password@123` |

### What's Next

- [ ] Flutter app: auth, home (today & upcoming), case list/detail/form,
      deadline form, mark-complete, profile, upgrade prompt
- [ ] Real SMS gateway integration (awaiting provider choice)
- [ ] Firebase Cloud Messaging credentials for push
- [ ] MySQL database creation (`adalot_sathi`) for production
- [ ] API markdown reference

## Notes

- `Case` is a PHP reserved word → Eloquent model is `LegalCase` (table `cases`).
- SMS channel is provider-agnostic by design; swapping providers is a one-file
  change in `app/Notifications/Channels/`.
- Notification titles/bodies include "Adalot Sathi" as sender identity.

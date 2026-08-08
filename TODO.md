# TODO

## Case Adding Fix & Form Restructure (DONE)
- [x] Backend: make `court_name` optional
- [x] Seeder: reduce free-tier demo user to 1 demo case
- [x] Form: restructure required/optional sections, remove Future AI

## Part 1 — Fix Null-cast bug on case detail
- [ ] deadline.dart: parse `reminder_days_before` defensively

## Part 2 — Admin Backend
- [ ] AdminDashboardController (stats endpoint)
- [ ] Admin cases oversight endpoint
- [ ] Admin subscription stats endpoint
- [ ] User verify/suspend/activate endpoints
- [ ] Routes in api.php

## Part 3 — Admin Mobile
- [ ] Role-based routing (admin → Admin Dashboard)
- [ ] Admin Dashboard screen
- [ ] Admin Users/lawyers screen
- [ ] Admin Cases oversight screen
- [ ] Admin Subscriptions screen

## Part 4 — Profile backend wiring
- [ ] Upgrade/cancel subscription endpoints
- [ ] Delete account endpoint
- [ ] Payment history endpoint
- [ ] Wire profile buttons to backend

# TODO

## Case Adding Fix & Form Restructure

### Backend
- [x] StoreCaseRequest: make `court_name` optional (nullable)
- [x] UpdateCaseRequest: make `court_name` optional (nullable)
- [x] DatabaseSeeder: reduce free-tier demo user to 1 demo case
- [x] LegalCaseFactory: fix null-safe date rendering (`?->format()`) to fix seeding crash

### Mobile
- [x] case_form_screen.dart: make Basic Info, Client Info, Important Dates required/expanded
- [x] case_form_screen.dart: make Court, Opposing Party, Financial, Documents, Case Progress optional dropdowns
- [x] case_form_screen.dart: remove Future AI Features section

### Verification
- [x] Run `php artisan migrate:fresh --seed` (in progress/fixed the LegalCaseFactory crash)
- [ ] Confirm case creation works
</content>

# Task: Update User Profile & Add Case Screens (Production-Ready)

## Backend (Laravel)
- [x] 1. Migration: add extended fields to `cases` table
- [x] 2. Migration: add profile fields to `users` table
- [x] 3. Migration: create `case_documents` table
- [x] 4. Update `LegalCase` model (fillable + casts)
- [x] 5. Update `User` model (fillable + casts)
- [x] 6. Update `StoreCaseRequest` / `UpdateCaseRequest` validation
- [x] 7. Update `UpdateProfileRequest` validation
- [x] 8. Update `CaseResource` / `UserResource` to expose new fields
- [x] 9. Add `CaseDocumentController` + routes
- [x] 10. Update `DatabaseSeeder`

## Frontend (Flutter)
- [x] 11. Update `legal_case.dart` model + `CaseInput`
- [x] 12. Update `user.dart` model
- [x] 13. Add `case_document.dart` model + document repository
- [x] 14. Rewrite `case_form_screen.dart` (collapsible sections A–I)
- [x] 15. Rewrite `profile_screen.dart` (all new sections)
- [x] 16. Update `profile_controller.dart` + `auth_repository.dart`
- [x] 17. Update `case_repository.dart` + `api_case_repository.dart`
- [x] 18. Update `repository_providers.dart`

## Followup
- [ ] 19. Run `php artisan migrate` (backend)
- [ ] 20. Run `flutter pub get` + `flutter analyze` (mobile)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../repositories/api/api_auth_repository.dart';
import '../repositories/api/api_case_document_repository.dart';
import '../repositories/api/api_case_repository.dart';
import '../repositories/api/api_deadline_repository.dart';
import '../repositories/api/api_device_token_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/case_document_repository.dart';
import '../repositories/case_repository.dart';
import '../repositories/deadline_repository.dart';
import '../repositories/device_token_repository.dart';

/// Core infrastructure providers. These are the single source of truth for the
/// real (API-backed) implementations. Swapping to mocks later (or to a
/// different API base URL) only requires changing these lines.
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(tokenStorageProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);

final caseRepositoryProvider = Provider<CaseRepository>(
  (ref) => ApiCaseRepository(ref.watch(apiClientProvider)),
);

final caseDocumentRepositoryProvider = Provider<CaseDocumentRepository>(
  (ref) => ApiCaseDocumentRepository(ref.watch(apiClientProvider)),
);

final deadlineRepositoryProvider = Provider<DeadlineRepository>(
  (ref) => ApiDeadlineRepository(ref.watch(apiClientProvider)),
);

final deviceTokenRepositoryProvider = Provider<DeviceTokenRepository>(
  (ref) => ApiDeviceTokenRepository(ref.watch(apiClientProvider)),
);

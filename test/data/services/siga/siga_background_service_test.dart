import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/data/repositories/block_of_profile/block_of_profile_repository.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository.dart';
import 'package:my_ufape/data/repositories/user/user_repository.dart';
import 'package:my_ufape/data/repositories/school_history/school_history_repository.dart';
import 'package:my_ufape/data/repositories/academic_achievement/academic_achievement_repository.dart';
import 'package:my_ufape/data/services/notification/notification_service.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockSubjectRepository extends Mock implements SubjectRepository {}

class MockSubjectNoteRepository extends Mock implements SubjectNoteRepository {}

class MockBlockOfProfileRepository extends Mock
    implements BlockOfProfileRepository {}

class MockScheduledSubjectRepository extends Mock
    implements ScheduledSubjectRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockSchoolHistoryRepository extends Mock
    implements SchoolHistoryRepository {}

class MockAcademicAchievementRepository extends Mock
    implements AcademicAchievementRepository {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late SigaBackgroundService service;
  late MockSettingsRepository mockSettings;
  late MockSubjectRepository mockSubject;
  late MockSubjectNoteRepository mockSubjectNote;
  late MockBlockOfProfileRepository mockBlock;
  late MockScheduledSubjectRepository mockScheduled;
  late MockUserRepository mockUser;
  late MockSchoolHistoryRepository mockSchoolHistory;
  late MockAcademicAchievementRepository mockAchievement;
  late MockNotificationService mockNotification;

  setUp(() {
    mockSettings = MockSettingsRepository();
    mockSubject = MockSubjectRepository();
    mockSubjectNote = MockSubjectNoteRepository();
    mockBlock = MockBlockOfProfileRepository();
    mockScheduled = MockScheduledSubjectRepository();
    mockUser = MockUserRepository();
    mockSchoolHistory = MockSchoolHistoryRepository();
    mockAchievement = MockAcademicAchievementRepository();
    mockNotification = MockNotificationService();

    injector.replaceInstance<SettingsRepository>(mockSettings);
    injector.replaceInstance<SubjectRepository>(mockSubject);
    injector.replaceInstance<SubjectNoteRepository>(mockSubjectNote);
    injector.replaceInstance<BlockOfProfileRepository>(mockBlock);
    injector.replaceInstance<ScheduledSubjectRepository>(mockScheduled);
    injector.replaceInstance<UserRepository>(mockUser);
    injector.replaceInstance<SchoolHistoryRepository>(mockSchoolHistory);
    injector.replaceInstance<AcademicAchievementRepository>(mockAchievement);
    injector.replaceInstance<NotificationService>(mockNotification);

    service = SigaBackgroundService();
  });

  tearDown(() {
    service.dispose();
  });

  test('initial state is correct', () {
    expect(service.isLoggedIn, false);
    expect(service.isSyncing, false);
    expect(service.authFailureNotifier.value, false);
    expect(service.captchaRequiredNotifier.value, false);
  });

  test('resetAuthFailure sets notifier to false', () {
    service.resetAuthFailure();
    expect(service.authFailureNotifier.value, false);
    service.resetAuthFailure();
    expect(service.authFailureNotifier.value, false);
  });

  test('cancelSync does not throw even when not syncing', () {
    expect(() => service.cancelSync(), returnsNormally);
  });

  test('dispose does not throw', () {
    final disposableService = SigaBackgroundService();

    expect(() => disposableService.dispose(), returnsNormally);
  });

  test('goToHome does nothing if controller is null', () async {
    await expectLater(service.goToHome(), completes);
  });
}

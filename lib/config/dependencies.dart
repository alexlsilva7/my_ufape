import 'package:auto_injector/auto_injector.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/data/repositories/academic_achievement/academic_achievement_repository.dart';
import 'package:my_ufape/data/repositories/academic_achievement/academic_achievement_repository_impl.dart';
import 'package:my_ufape/data/repositories/school_history/school_history_repository.dart';
import 'package:my_ufape/data/repositories/school_history/school_history_repository_impl.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository_impl.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository_impl.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository_impl.dart';
import 'package:my_ufape/data/services/academic_achievement/academic_achievement_service.dart';
import 'package:my_ufape/data/services/school_history/school_history_service.dart';
import 'package:my_ufape/data/services/settings/local_storage_preferences_service.dart';
import 'package:my_ufape/data/services/subject/subject_service.dart';
import 'package:my_ufape/data/services/block_of_profile/block_of_profile_service.dart';
import 'package:my_ufape/data/repositories/block_of_profile/block_of_profile_repository.dart';
import 'package:my_ufape/data/repositories/block_of_profile/block_of_profile_repository_impl.dart';
import 'package:my_ufape/data/services/subject_note/subject_note_service.dart';
import 'package:my_ufape/data/services/scheduled_subject/scheduled_subject_service.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository_impl.dart';
import 'package:my_ufape/data/repositories/user/user_repository.dart';
import 'package:my_ufape/data/repositories/user/user_repository_impl.dart';
import 'package:my_ufape/data/services/user/user_service.dart';
import 'package:my_ufape/ui/academic_achievement/academic_achievement_view_model.dart';
import 'package:my_ufape/ui/charts/charts_view_model.dart';
import 'package:my_ufape/ui/home/home_view_model.dart';
import 'package:my_ufape/ui/school_history/school_history_view_model.dart';
import 'package:my_ufape/ui/splash/splash_view_model.dart';
import 'package:my_ufape/ui/subjects/subjects_view_model.dart';
import 'package:my_ufape/ui/timetable/timetable_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_ufape/data/services/notification/notification_service.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/data/services/shorebird/shorebird_service.dart';
import 'package:my_ufape/data/services/upcoming_classes/upcoming_classes_service.dart';
import 'package:my_ufape/ui/initial_sync/initial_sync_view_model.dart';

final injector = AutoInjector();

Future<void> setupDependencies() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  injector.addInstance<SharedPreferences>(prefs);
  injector.addSingleton(Database.new);
  injector.addLazySingleton(LocalStoragePreferencesService.new);

  injector.addLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  injector.addLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      injector.get<LocalStoragePreferencesService>(),
      injector.get<SharedPreferences>(),
      injector.get<FlutterSecureStorage>(),
      injector.get<Database>(),
      injector.get<UserRepository>(),
    ),
  );

  injector.addLazySingleton<SubjectNoteService>(SubjectNoteService.new);
  injector.addLazySingleton<SubjectNoteRepository>(
    () => SubjectNoteRepositoryImpl(
      injector.get<SubjectNoteService>(),
    ),
  );

  injector.addLazySingleton<SubjectService>(
    () => SubjectService(
      injector.get<Database>(),
    ),
  );

  injector.addLazySingleton<SubjectRepository>(
    () => SubjectRepositoryImpl(
      injector.get<SubjectService>(),
    ),
  );

  injector.addLazySingleton<BlockOfProfileService>(
    () => BlockOfProfileService(
      injector.get<Database>(),
    ),
  );

  injector.addLazySingleton<BlockOfProfileRepository>(
    () => BlockOfProfileRepositoryImpl(
      injector.get<BlockOfProfileService>(),
    ),
  );

  injector.addLazySingleton<ScheduledSubjectService>(
    () => ScheduledSubjectService(
      injector.get<Database>(),
    ),
  );

  injector.addLazySingleton<ScheduledSubjectRepository>(
    () => ScheduledSubjectRepositoryImpl(
      injector.get<ScheduledSubjectService>(),
    ),
  );

  injector.addLazySingleton<UpcomingClassesService>(
    () => UpcomingClassesService(
      injector.get<ScheduledSubjectRepository>(),
    ),
  );

  injector.addLazySingleton<UserService>(
    () => UserService(
      injector.get<Database>(),
    ),
  );

  injector.addLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      injector.get<UserService>(),
    ),
  );

  injector.addLazySingleton<SchoolHistoryService>(
    () => SchoolHistoryService(
      injector.get<Database>(),
    ),
  );

  injector.addLazySingleton<SchoolHistoryRepository>(
    () => SchoolHistoryRepositoryImpl(
      injector.get<SchoolHistoryService>(),
    ),
  );

  injector.addLazySingleton(SplashViewModel.new);
  injector.addLazySingleton(
    () => HomeViewModel(
      injector.get<UserRepository>(),
    ),
  );

  injector.addLazySingleton(
    () => SubjectsViewModel(
      injector.get<SubjectRepository>(),
      injector.get<SubjectNoteRepository>(),
      injector.get<SchoolHistoryRepository>(),
    ),
  );

  injector.addLazySingleton(
    () => InitialSyncViewModel(
      injector.get<SigaBackgroundService>(),
      injector.get<UserRepository>(),
      injector.get<SettingsRepository>(),
    ),
  );

  injector.addLazySingleton(
    () => TimetableViewModel(
      injector.get<ScheduledSubjectRepository>(),
      injector.get<SigaBackgroundService>(),
    ),
  );

  injector.addLazySingleton<AcademicAchievementService>(
    () => AcademicAchievementService(injector.get<Database>()),
  );

  injector.addLazySingleton<AcademicAchievementRepository>(
    () => AcademicAchievementRepositoryImpl(
        injector.get<AcademicAchievementService>()),
  );

  injector.addLazySingleton(
    () => AcademicAchievementViewModel(
      injector.get<AcademicAchievementRepository>(),
      injector.get<SigaBackgroundService>(),
    ),
  );

  injector.addLazySingleton(ChartsViewModel.new);
  injector.addLazySingleton(() => SchoolHistoryViewModel(
        injector.get<SchoolHistoryRepository>(),
        injector.get<SigaBackgroundService>(),
      ));

  injector.addSingleton(NotificationService.new);

  // Serviço SIGA: instância única (Singleton)
  injector.addInstance<SigaBackgroundService>(
    SigaBackgroundService(),
  );

  injector.addSingleton(ShorebirdService.new);

  injector.commit();

  // Inicializa o banco de dados
  await injector.get<Database>().connection;
  await injector.get<Database>().seed();

  // Inicializa o serviço SIGA (cria controller e começa verificação)
  try {
    await injector.get<SigaBackgroundService>().initialize();
  } catch (_) {
    logarte.log('Falha ao inicializar SigaBackgroundService',
        source: 'setupDependencies');
  }

  // Inicializa serviço de notificação
  try {
    await injector.get<NotificationService>().init();
    await injector.get<NotificationService>().requestPermissions();
  } catch (_) {
    logarte.log('Falha ao inicializar NotificationService',
        source: 'setupDependencies');
  }

  // Inicializa o serviço do Shorebird para verificações automáticas
  try {
    injector.get<ShorebirdService>().init();
  } catch (_) {
    logarte.log('Falha ao inicializar ShorebirdService',
        source: 'setupDependencies');
  }
}

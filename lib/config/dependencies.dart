import 'package:auto_injector/auto_injector.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository_impl.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository_impl.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository_impl.dart';
import 'package:my_ufape/data/services/settings/local_storage_preferences_service.dart';
import 'package:my_ufape/data/services/subject/subject_service.dart';
import 'package:my_ufape/data/services/block_of_profile/block_of_profile_service.dart';
import 'package:my_ufape/data/repositories/block_of_profile/block_of_profile_repository.dart';
import 'package:my_ufape/data/repositories/block_of_profile/block_of_profile_repository_impl.dart';
import 'package:my_ufape/data/services/subject_note/subject_note_service.dart';
import 'package:my_ufape/data/services/scheduled_subject/scheduled_subject_service.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository_impl.dart';
import 'package:my_ufape/ui/home/home_view_model.dart';
import 'package:my_ufape/ui/splash/splash_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';

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

  injector.addLazySingleton(SplashViewModel.new);
  injector.addLazySingleton(HomeViewModel.new);

  // Registrar serviço SIGA em background
  injector.addSingleton<SigaBackgroundService>(() => SigaBackgroundService());

  injector.commit();

  // Inicializa o banco de dados
  await injector.get<Database>().connection;
  await injector.get<Database>().seed();

  // Inicializa o serviço SIGA em background (cria controller e começa verificação)
  try {
    await injector.get<SigaBackgroundService>().initialize();
  } catch (_) {
    // não bloquear inicialização do app se falhar
  }
}

import 'package:my_ufape/core/database/database.dart';
import 'package:my_ufape/domain/entities/user.dart';
import 'package:result_dart/result_dart.dart';
import 'package:isar_community/isar.dart';

class UserService {
  final Database _database;

  UserService(this._database);

  AsyncResult<User> upsertUser(User user) async {
    try {
      final isar = await _database.connection;
      await isar.writeTxn(() async {
        await isar.users.clear(); // Garante que apenas um usuário exista
        await isar.users.put(user);
      });
      return Success(user);
    } catch (e) {
      return Failure(Exception('Erro ao salvar usuário: $e'));
    }
  }

  AsyncResult<User> getUser() async {
    try {
      final isar = await _database.connection;
      final user = await isar.users.where().findFirst();
      if (user != null) {
        return Success(user);
      } else {
        return Failure(Exception('Usuário não encontrado no banco de dados.'));
      }
    } catch (e) {
      return Failure(Exception('Erro ao buscar usuário: $e'));
    }
  }
}

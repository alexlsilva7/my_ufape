import 'package:my_ufape/domain/entities/user.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class UserRepository {
  AsyncResult<User> upsertUser(User user);
  AsyncResult<User> getUser();
}
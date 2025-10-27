import 'package:my_ufape/data/services/user/user_service.dart';
import 'package:my_ufape/domain/entities/user.dart';
import 'package:result_dart/result_dart.dart';

import './user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserService _userService;

  UserRepositoryImpl(this._userService);

  @override
  AsyncResult<User> upsertUser(User user) {
    return _userService.upsertUser(user);
  }

  @override
  AsyncResult<User> getUser() {
    return _userService.getUser();
  }

  @override
  Stream<User?> userStream() {
    return _userService.watchUser();
  }
}

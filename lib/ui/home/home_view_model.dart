import 'package:flutter/foundation.dart';
import 'package:my_ufape/data/repositories/user/user_repository.dart';
import 'package:my_ufape/domain/entities/user.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  HomeViewModel(this._userRepository);

  User? _user;
  User? get user => _user;

  String get userName {
    final name = _user?.name.trim();
    if (name != null && name.isNotEmpty) {
      final nameParts = name.split(' ');
      return nameParts.first;
    }
    return 'Estudante';
  }

  Future<void> loadUser() async {
    final result = await _userRepository.getUser();
    result.fold(
      (user) {
        _user = user;
        notifyListeners();
      },
      (error) {
        _user = null;
        notifyListeners();
      },
    );

    _userRepository.userStream().listen((user) {
      _user = user;
      notifyListeners();
    });
  }
}

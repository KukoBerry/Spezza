import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/model/dto/user/create_user_dto.dart';
import 'package:spezza/model/dto/user/login_dto.dart';
import 'package:spezza/model/dto/user/user.dart';
import 'package:spezza/shared/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_model.g.dart';

class UserModel {
  final UserRepository _repository;

  UserModel(this._repository);
  Future<SpezzaUser> createUser(CreateUserDto dto) async {
    final user = _repository.createUser(dto);
    return user;
  }

  Future<bool> login(LoginDto dto) async {
    try{
      bool succesfullLogin = await _repository.login(dto);
    return succesfullLogin;
    } catch(_) {
      return false;
    }
    
  }

  Future<int> getCurrentUserId() async {
    final int userId = await _repository.getSessionUserId();
    return userId;
  }

  Future<void> signout() async {
    await _repository.signout();
  }

  Future<SpezzaUser> getUser(int id) async {
    final user = await _repository.findById(id);
    return user;
  }
}

@riverpod
UserModel userModel(Ref ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UserModel(repo);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/model/dto/user/create_user_dto.dart';
import 'package:spezza/model/dto/user/user.dart';
import 'package:spezza/shared/repositories/expense_repository.dart';
import 'package:spezza/shared/repositories/user_repository.dart';
import 'dto/expense.dart';

part 'user_model.g.dart';

class UserModel {
  final UserRepository _repository;

  UserModel(this._repository);
  Future<SpezzaUser> createUser(CreateUserDto dto) async {
    
    final user = _repository.createUser(dto);
    return user;
  }

  Future<SpezzaUser> getUser(int id) async {

    final user = await _repository.findById(id);
    return user;
  }
  
}

@riverpod
UserModel userModel(Ref ref) {
  final repo = ref.watch(userRepositoryProvider);
  return userModel(repo);
}

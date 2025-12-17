import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/model/dto/user/create_user_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/shared/supabase_config/supabase_provider.dart';
import 'package:spezza/model/dto/user/user.dart';

part 'user_repository.g.dart';

class UserRepository {
  final SupabaseClient _supabase;

  UserRepository(this._supabase);

  Future <SpezzaUser> createUser(CreateUserDto dto) async {
    final createdUser = await _supabase.from('user').insert(dto).select().single();
    return SpezzaUser.fromMap(createdUser);
  }

  Future<List<SpezzaUser>> fetchUsers() async {
    final results = await _supabase.from('user').select();

    return results.map<SpezzaUser>((map) => SpezzaUser.fromMap(map)).toList();
  }

  Future<SpezzaUser> findById(int id) async {
    final result = await _supabase.from('user').select().eq('id', id).single();
    return SpezzaUser.fromMap(result);
  }
}

@riverpod
UserRepository userRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return UserRepository(supabase);
}

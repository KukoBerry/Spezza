import 'package:spezza/model/dto/goal_expense.dart';
import 'package:spezza/model/dto/user/create_user_dto.dart';
import 'package:spezza/model/dto/user/login_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spezza/shared/supabase_config/supabase_provider.dart';
import 'package:spezza/model/dto/user/user.dart';

part 'user_repository.g.dart';

class UserRepository {
  final SupabaseClient _supabase;

  UserRepository(this._supabase);

  Future<SpezzaUser> createUser(CreateUserDto dto) async {
    final authResponse = await _supabase.auth.signUp(
      email: dto.email,
      password: dto.password,
    );
    final authUser = authResponse.user;
    if (authUser == null) {
      throw ("Sign up error");
    }
    final Map<String, dynamic> data = {...dto.toMap(), 'auth_id': authUser.id};
    final createdUser = await _supabase
        .from('user')
        .insert(data)
        .select()
        .single();
    return SpezzaUser.fromMap(createdUser);
  }

  Future<bool> login(LoginDto dto) async {
    final authResponse = await _supabase.auth.signInWithPassword(
      email: dto.email,
      password: dto.password,
    );
    final authUser = authResponse.user;
    if (authUser == null){
      return false;
    }
    return true;
  }

  Future<void> signout() async {
    await _supabase.auth.signOut();
  }

  Future<List<SpezzaUser>> fetchUsers() async {
    final results = await _supabase.from('user').select();

    return results.map<SpezzaUser>((map) => SpezzaUser.fromMap(map)).toList();
  }

  Future<SpezzaUser> findById(int id) async {
    final result = await _supabase.from('user').select().eq('id', id).single();
    return SpezzaUser.fromMap(result);
  }

  Future<int> getSessionUserId() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null){
      throw("No user logged");
    }
    final result = await _supabase.from('user').select('id').eq('auth_id', authUser.id).single();
    return result['id'];
  } 
}

@riverpod
UserRepository userRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return UserRepository(supabase);
}

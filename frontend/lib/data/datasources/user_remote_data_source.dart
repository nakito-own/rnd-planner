import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<List<UserModel>> getAllUsers();
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  
  @override
  Future<UserModel> getCurrentUser() async {
    throw UnimplementedError();
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser(String userId) async {
    throw UnimplementedError();
  }
}

import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<UserModel> getLastUser();
  Future<void> cacheUser(UserModel userToCache);
  Future<void> clearCache();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  
  @override
  Future<UserModel> getLastUser() async {
    throw UnimplementedError();
  }

  @override
  Future<void> cacheUser(UserModel userToCache) async {
    throw UnimplementedError();
  }

  @override
  Future<void> clearCache() async {
    throw UnimplementedError();
  }
}

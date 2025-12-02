import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedUserKey = 'CACHED_USER';

  const AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(cachedUserKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString);
        return UserModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw const ServerException(message: 'Failed to get cached user');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(cachedUserKey, jsonString);
    } catch (e) {
      throw const ServerException(message: 'Failed to cache user');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      print('now will clear cache auth local data source : $cachedUserKey');
      await sharedPreferences.remove(cachedUserKey);
      print('now deleted clear cache auth local data source : $cachedUserKey');
    } catch (e) {
      throw const ServerException(message: 'Failed to clear cache');
    }
  }
}

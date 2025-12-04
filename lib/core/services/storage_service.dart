

// import 'package:admin_panel/core/di/injection_container.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class StorageService {
//   static late SharedPreferences _prefs;

//   static Future<void> init() async {
//     _prefs = sl<SharedPreferences>();
//   }



//   // Authentication
//   static Future<bool> setAccessToken(String token) async {
//     return await _prefs.setString(StorageKeys.accessToken, token);
//   }

//   static String? getAccessToken() {
//     return _prefs.getString(StorageKeys.accessToken);
//   }

//   static Future<bool> setRefreshToken(String token) async {
//     return await _prefs.setString(StorageKeys.refreshToken, token);
//   }

//   static String? getRefreshToken() {
//     return _prefs.getString(StorageKeys.refreshToken);
//   }

//   static Future<bool> setUserId(String userId) async {
//     return await _prefs.setString(StorageKeys.userId, userId);
//   }

//   static String? getUserId() {
//     return _prefs.getString(StorageKeys.userId);
//   }

//   static Future<bool> setUserEmail(String email) async {
//     return await _prefs.setString(StorageKeys.userEmail, email);
//   }

//   static String? getUserEmail() {
//     return _prefs.getString(StorageKeys.userEmail);
//   }

//   static bool isAuthenticated() {
//     final token = getAccessToken();
//     return token != null && token.isNotEmpty;
//   }

//   // Language
//   static Future<bool> setUserLanguage(String language) async {
//     return await _prefs.setString(StorageKeys.userLanguage, language);
//   }

//   static String getUserLanguage() {
//     return _prefs.getString(StorageKeys.userLanguage) ?? 'en';
//   }

//   // Clear all data (logout)
//   static Future<bool> clearAll() async {
//     return await _prefs.clear();
//   }

//   // Clear auth data only
//   static Future<void> clearAuthData() async {
//     await _prefs.remove(StorageKeys.accessToken);
//     await _prefs.remove(StorageKeys.refreshToken);
//     await _prefs.remove(StorageKeys.userId);
//     await _prefs.remove(StorageKeys.userEmail);
//   }
// }

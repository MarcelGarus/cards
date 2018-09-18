import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ResourceMissingError implements Error {
  const ResourceMissingError(this.path) : assert(path != null);
  
  final String path;

  String toString() => "Resource missing: $path";

  StackTrace get stackTrace => null;
}


/// Handles all the low level stuff, like dealing with files or package
/// libraries.
abstract class ResourceManager {
  static Future<void> saveString(String key, String value) async {
    (await SharedPreferences.getInstance()).setString(key, value);
  }

  static Future<String> loadString(String key) async {
    return (await SharedPreferences.getInstance()).getString(key);
  }

  static Future<void> saveStringList(String key, List<String> value) async {
    (await SharedPreferences.getInstance()).setStringList(key, value);
  }
  
  static Future<List<String>> loadStringList(String key) async {
    return (await SharedPreferences.getInstance()).getStringList(key);
  }
}

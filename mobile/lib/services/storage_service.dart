import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService instance = StorageService._internal();
  StorageService._internal();

  SharedPreferences? _prefs;

  static const String keyPassengers = 'sbk_passengers_v1';
  static const String keyOwners = 'sbk_owners_v1';
  static const String keyConductors = 'sbk_conductors_v1';
  static const String keyBuses = 'sbk_buses_v1';
  static const String keyTickets = 'sbk_tickets_v1';
  static const String keyTransactions = 'sbk_transactions_v1';
  static const String keyReviews = 'sbk_reviews_v1';

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('StorageService init error (fallback to in-memory): $e');
    }
  }

  // Generic List Loader
  List<Map<String, dynamic>>? loadList(String key) {
    try {
      final raw = _prefs?.getString(key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('StorageService loadList error for key $key: $e');
    }
    return null;
  }

  // Generic List Saver
  Future<void> saveList(String key, List<Map<String, dynamic>> list) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final encoded = jsonEncode(list);
      await _prefs?.setString(key, encoded);
    } catch (e) {
      debugPrint('StorageService saveList error for key $key: $e');
    }
  }

  // Clear specific key or all
  Future<void> clearAll() async {
    try {
      await _prefs?.clear();
    } catch (e) {
      debugPrint('StorageService clearAll error: $e');
    }
  }
}

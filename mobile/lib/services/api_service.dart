import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  /// Base URL: localhost for Web/macOS, or 10.0.2.2 for Android emulator
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001/api';
    }
    return 'http://10.0.2.2:5001/api';
  }

  static String fallbackUrl = 'http://localhost:5001/api';
  static String activeUrl = kIsWeb ? 'http://localhost:5001/api' : 'http://10.0.2.2:5001/api';

  /// Health Check
  static Future<Map<String, dynamic>?> asyncCheckHealth() async {
    try {
      final res = await http.get(Uri.parse('$activeUrl/health')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {
      try {
        final res = await http.get(Uri.parse('$fallbackUrl/health')).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          activeUrl = fallbackUrl;
          return jsonDecode(res.body);
        }
      } catch (_) {}
    }
    return null;
  }

  /// Auth: Login
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$activeUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('Login Error: $e');
    }
    return null;
  }

  /// Routes: Calculate Authoritative Stage Fare
  static Future<Map<String, dynamic>?> calculateFare({
    required String routeId,
    required String boardingStop,
    required String destinationStop,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$activeUrl/routes/calculate-fare'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'routeId': routeId,
          'boardingStopName': boardingStop,
          'destinationStopName': destinationStop,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('Calculate Fare Error: $e');
    }
    return null;
  }

  /// Wallet: Get Balance
  static Future<double?> getWalletBalance(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$activeUrl/wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['data']['wallet']['balance'] as num).toDouble();
      }
    } catch (e) {
      debugPrint('Get Wallet Error: $e');
    }
    return null;
  }

  /// Wallet: Recharge Demo Balance
  static Future<double?> rechargeWallet(String token, double amount) async {
    try {
      final res = await http.post(
        Uri.parse('$activeUrl/wallet/recharge'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'amount': amount}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['data']['wallet']['balance'] as num).toDouble();
      }
    } catch (e) {
      debugPrint('Recharge Wallet Error: $e');
    }
    return null;
  }

  /// Tickets: Issue Spot Ticket
  static Future<Map<String, dynamic>?> issueTicket({
    required String token,
    required String passengerId,
    required String tripId,
    required String boardingStop,
    required String destinationStop,
    required String paymentMethod,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$activeUrl/tickets/issue'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'passengerId': passengerId,
          'tripId': tripId,
          'boardingStopName': boardingStop,
          'destinationStopName': destinationStop,
          'paymentMethod': paymentMethod,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('Issue Ticket Error: $e');
      return null;
    }
  }

  /// Active Trips for Live Tracking Radar
  static Future<List<dynamic>> getActiveTrips() async {
    try {
      final res = await http.get(Uri.parse('$activeUrl/trips/active'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data']['trips'] ?? [];
      }
    } catch (e) {
      debugPrint('Get Active Trips Error: $e');
    }
    return [];
  }

  /// Fetch full backend JSON state
  static Future<Map<String, dynamic>?> fetchBackendData() async {
    try {
      final res = await http.get(Uri.parse('$activeUrl/data/json')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {
      try {
        final res = await http.get(Uri.parse('$fallbackUrl/data/json')).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          return jsonDecode(res.body) as Map<String, dynamic>;
        }
      } catch (_) {}
    }
    return null;
  }

  /// Bidirectional sync: send latest frontend state to backend
  static Future<bool> syncData(Map<String, dynamic> payload) async {
    try {
      final res = await http.post(
        Uri.parse('$activeUrl/data/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      try {
        final res = await http.post(
          Uri.parse('$fallbackUrl/data/sync'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 4));
        return res.statusCode == 200;
      } catch (_) {}
    }
    return false;
  }
}

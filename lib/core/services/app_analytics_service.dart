import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppOrderRecord {
  final String id;
  final double totalAmount;
  final int itemsCount;
  final String timestamp;
  final String? customerEmail;

  const AppOrderRecord({
    required this.id,
    required this.totalAmount,
    required this.itemsCount,
    required this.timestamp,
    this.customerEmail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'totalAmount': totalAmount,
        'itemsCount': itemsCount,
        'timestamp': timestamp,
        'customerEmail': customerEmail,
      };

  factory AppOrderRecord.fromJson(Map<String, dynamic> json) {
    return AppOrderRecord(
      id: json['id']?.toString() ?? '',
      totalAmount: (num.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0).toDouble(),
      itemsCount: (num.tryParse(json['itemsCount']?.toString() ?? '1') ?? 1).toInt(),
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      customerEmail: json['customerEmail']?.toString(),
    );
  }
}

class AppAnalyticsService extends ChangeNotifier {
  static final AppAnalyticsService instance = AppAnalyticsService._internal();
  AppAnalyticsService._internal();

  static const String _prefOrdersLogKey = 'app_orders_analytics_log_v1';

  List<AppOrderRecord> _ordersLog = [];
  bool _isInitialized = false;

  List<AppOrderRecord> get ordersLog => _ordersLog;
  int get totalAppOrders => _ordersLog.length;
  double get totalRevenue => _ordersLog.fold(0.0, (sum, o) => sum + o.totalAmount);
  double get averageOrderValue => totalAppOrders > 0 ? (totalRevenue / totalAppOrders) : 0.0;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_prefOrdersLogKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(savedJson);
        _ordersLog = list.map((item) => AppOrderRecord.fromJson(item)).toList();
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing AppAnalyticsService: $e');
    }
  }

  Future<void> recordCheckout({
    required double totalAmount,
    required int itemsCount,
    String? customerEmail,
  }) async {
    final record = AppOrderRecord(
      id: 'APP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      totalAmount: totalAmount,
      itemsCount: itemsCount,
      timestamp: DateTime.now().toIso8601String(),
      customerEmail: customerEmail,
    );

    _ordersLog.insert(0, record);
    await _persist();
    notifyListeners();
  }

  Future<void> resetStats() async {
    _ordersLog.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefOrdersLogKey);
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_ordersLog.map((o) => o.toJson()).toList());
      await prefs.setString(_prefOrdersLogKey, jsonString);
    } catch (e) {
      debugPrint('Error saving analytics: $e');
    }
  }
}

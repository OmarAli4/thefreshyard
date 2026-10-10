import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/collection_remote_data_source.dart';

class ShopifyCollection {
  final String id;
  final String title;
  final String handle;
  final String imageUrl;

  const ShopifyCollection({
    required this.id,
    required this.title,
    required this.handle,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'handle': handle,
        'imageUrl': imageUrl,
      };

  factory ShopifyCollection.fromJson(Map<String, dynamic> json) {
    return ShopifyCollection(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      handle: json['handle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}

class CollectionCacheService extends ChangeNotifier {
  static final CollectionCacheService instance = CollectionCacheService._internal();
  CollectionCacheService._internal();

  static const String _cacheKey = 'shopify_collections_cache_v1';
  static const String _cacheTimestampKey = 'shopify_collections_cache_ts_v1';

  List<ShopifyCollection> _collections = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<ShopifyCollection> get collections => _collections;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Initialize: load from disk cache immediately, then refresh from network in background
  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Load from disk cache (instant)
    await _loadFromDiskCache();
    _isInitialized = true;
    notifyListeners();

    // 2. Refresh from network in background
    refreshFromNetwork();
  }

  /// Force refresh from Shopify API
  Future<void> refreshFromNetwork() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final dataSource = CollectionRemoteDataSourceImpl();
      final rawCollections = await dataSource.getCollections(limit: 50);

      if (rawCollections.isNotEmpty) {
        _collections = rawCollections
            .map((raw) => ShopifyCollection(
                  id: raw['id'] ?? '',
                  title: raw['title'] ?? '',
                  handle: raw['handle'] ?? '',
                  imageUrl: raw['imageUrl'] ?? '',
                ))
            .toList();

        // Persist to disk
        await _saveToDiskCache();
      }
    } catch (e) {
      debugPrint('CollectionCacheService: network refresh failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromDiskCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null && cached.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cached);
        _collections = decoded.map((item) => ShopifyCollection.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('CollectionCacheService: disk cache read error: $e');
    }
  }

  Future<void> _saveToDiskCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_collections.map((c) => c.toJson()).toList());
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('CollectionCacheService: disk cache write error: $e');
    }
  }
}

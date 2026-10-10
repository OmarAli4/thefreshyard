import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';

abstract class IProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    int limit = 100,
    String? collectionHandle,
  });

  Future<({List<ProductModel> products, bool hasNextPage, String? endCursor})> getProductsPaginated({
    int limit = 20,
    String? cursor,
    String? query,
  });

  Future<List<ProductModel>> getCachedProducts({
    String? collectionHandle,
  });

  Future<List<ProductModel>> getBestSellingProducts({int limit = 10});
}

class ProductRemoteDataSourceImpl implements IProductRemoteDataSource {
  final http.Client client;

  // Ultra-fast in-memory cache for 0ms transitions
  static final Map<String, List<ProductModel>> _inMemoryCache = {};

  ProductRemoteDataSourceImpl({http.Client? client}) 
      : client = client ?? http.Client();

  @override
  Future<List<ProductModel>> getCachedProducts({String? collectionHandle}) async {
    final key = collectionHandle ?? 'all';
    
    // 1. Check in-memory cache first (0ms)
    if (_inMemoryCache.containsKey(key) && _inMemoryCache[key]!.isNotEmpty) {
      return _inMemoryCache[key]!;
    }

    // 2. Check SharedPreferences disk cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'products_cache_$key';
      final cachedString = prefs.getString(cacheKey);
      if (cachedString != null) {
        final List<dynamic> decodedList = jsonDecode(cachedString);
        final models = decodedList.map((item) => ProductModel.fromJson(item)).toList();
        _inMemoryCache[key] = models;
        return models;
      }
    } catch (e) {
      debugPrint('Cache read error: $e');
    }
    return [];
  }

  @override
  Future<List<ProductModel>> getProducts({
    int limit = 100,
    String? collectionHandle,
  }) async {
    final bool isCollectionQuery = collectionHandle != null &&
        collectionHandle.isNotEmpty &&
        collectionHandle.toLowerCase() != 'all';

    final List<ProductModel> allModels = [];

    final headers = {
      'X-Shopify-Storefront-Access-Token': ApiConstants.storefrontAccessToken,
      'Content-Type': 'application/json',
    };

    final List<Uri> urls = kIsWeb
        ? [
            Uri.parse(ApiConstants.graphqlEndpoint),
            Uri.parse('https://api.codetabs.com/v1/proxy?quest=${Uri.encodeComponent(ApiConstants.graphqlEndpoint)}'),
            Uri.parse('https://thingproxy.freeboard.io/fetch/${ApiConstants.graphqlEndpoint}'),
            Uri.parse(ApiConstants.corsProxyEndpoint),
          ]
        : [
            Uri.parse(ApiConstants.graphqlEndpoint),
          ];

    String query;
    if (isCollectionQuery) {
      query = ApiConstants.collectionProductsQuery;
    } else {
      query = ApiConstants.productsQuery;
    }

    final Map<String, dynamic> variables = {'first': limit.clamp(1, 250)};
    if (isCollectionQuery) {
      variables['handle'] = collectionHandle;
    }

    final body = jsonEncode({
      'query': query,
      'variables': variables,
    });

    final List<Map<String, dynamic>> rawNodesToCache = [];

    for (var url in urls) {
      try {
        final response = await client
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          dynamic productsContainer;
          if (isCollectionQuery) {
            productsContainer = data['data']?['collection']?['products'];
          } else {
            productsContainer = data['data']?['products'];
          }

          final edges = productsContainer?['edges'];

          if (edges is List && edges.isNotEmpty) {
            for (var edge in edges) {
              if (edge is Map) {
                final node = edge['node'];
                if (node is Map) {
                  final nodeMap = Map<String, dynamic>.from(node);
                  rawNodesToCache.add(nodeMap);
                  final model = ProductModel.fromJson(nodeMap);
                  allModels.add(model);
                }
              }
            }
            break; // Successfully loaded batch
          }
        }
      } catch (e) {
        debugPrint('Proxy endpoint $url failed/timed out: $e');
      }
    }

    if (allModels.isNotEmpty) {
      final key = collectionHandle ?? 'all';
      _inMemoryCache[key] = allModels;

      // Save to disk cache asynchronously
      SharedPreferences.getInstance().then((prefs) {
        final cacheKey = 'products_cache_${collectionHandle ?? "all"}';
        prefs.setString(cacheKey, jsonEncode(rawNodesToCache));
      }).catchError((e) {
        debugPrint('Cache write error: $e');
      });
    }

    return allModels;
  }

  @override
  Future<({List<ProductModel> products, bool hasNextPage, String? endCursor})> getProductsPaginated({
    int limit = 20,
    String? cursor,
    String? query,
  }) async {
    final List<ProductModel> models = [];
    bool hasNextPage = false;
    String? endCursor;

    final headers = {
      'X-Shopify-Storefront-Access-Token': ApiConstants.storefrontAccessToken,
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> variables = {'first': limit.clamp(1, 250)};
    if (cursor != null) variables['after'] = cursor;
    // Note: The products query doesn't natively support free-text 'query' in ApiConstants yet without changing it.
    // For now we just paginate all products. If search is needed at the API level, the query must be updated to accept $query.

    final body = jsonEncode({
      'query': ApiConstants.productsQuery,
      'variables': variables,
    });

    final url = Uri.parse(ApiConstants.graphqlEndpoint);
    
    try {
      final response = await client
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productsContainer = data['data']?['products'];
        final edges = productsContainer?['edges'];
        final pageInfo = productsContainer?['pageInfo'];

        if (pageInfo != null) {
          hasNextPage = pageInfo['hasNextPage'] ?? false;
          endCursor = pageInfo['endCursor'];
        }

        if (edges is List && edges.isNotEmpty) {
          for (var edge in edges) {
            if (edge is Map) {
              final node = edge['node'];
              if (node is Map) {
                models.add(ProductModel.fromJson(Map<String, dynamic>.from(node)));
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Paginated products fetch failed: $e');
    }

    return (products: models, hasNextPage: hasNextPage, endCursor: endCursor);
  }

  @override
  Future<List<ProductModel>> getBestSellingProducts({int limit = 10}) async {
    // 1. Fetch from the official 'best-selling-products' Shopify collection used on website
    try {
      final collectionProducts = await getProducts(
        collectionHandle: 'best-selling-products',
        limit: limit,
      );
      if (collectionProducts.isNotEmpty) {
        return collectionProducts;
      }
    } catch (_) {}

    // 2. Fallback to store-wide BEST_SELLING sort query
    final headers = {
      'X-Shopify-Storefront-Access-Token': ApiConstants.storefrontAccessToken,
      'Content-Type': 'application/json',
    };

    final urls = [
      Uri.parse(ApiConstants.graphqlEndpoint),
      Uri.parse(ApiConstants.corsProxyEndpoint),
    ];

    final body = jsonEncode({
      'query': ApiConstants.bestSellingProductsQuery,
      'variables': {'first': limit.clamp(1, 50)},
    });

    for (var url in urls) {
      try {
        final response = await client
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final edges = data['data']?['products']?['edges'];

          if (edges is List && edges.isNotEmpty) {
            return edges
                .where((e) => e is Map && e['node'] is Map)
                .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e['node'])))
                .toList();
          }
        }
      } catch (e) {
        debugPrint('Best selling query failed for $url: $e');
      }
    }
    return [];
  }
}

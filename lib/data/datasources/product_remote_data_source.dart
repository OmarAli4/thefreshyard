import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';

abstract class IProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    int limit = 500,
    String? collectionHandle,
  });

  Future<List<ProductModel>> getCachedProducts({
    String? collectionHandle,
  });
}

class ProductRemoteDataSourceImpl implements IProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({http.Client? client}) 
      : client = client ?? http.Client();

  @override
  Future<List<ProductModel>> getCachedProducts({String? collectionHandle}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'products_cache_${collectionHandle ?? "all"}';
      final cachedString = prefs.getString(cacheKey);
      if (cachedString != null) {
        final List<dynamic> decodedList = jsonDecode(cachedString);
        return decodedList.map((item) => ProductModel.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Cache read error: $e');
    }
    return [];
  }

  @override
  Future<List<ProductModel>> getProducts({
    int limit = 500,
    String? collectionHandle,
  }) async {
    final bool isCollectionQuery = collectionHandle != null &&
        collectionHandle.isNotEmpty &&
        collectionHandle.toLowerCase() != 'all';

    final List<ProductModel> allModels = [];
    bool hasNextPage = true;
    String? afterCursor;

    final headers = {
      'X-Shopify-Storefront-Access-Token': ApiConstants.storefrontAccessToken,
      'Content-Type': 'application/json',
    };

    final urls = [
      Uri.parse(ApiConstants.graphqlEndpoint),
      Uri.parse(ApiConstants.corsProxyEndpoint),
    ];

    Uri? selectedUrl;

    final List<Map<String, dynamic>> rawNodesToCache = [];

    while (hasNextPage && allModels.length < limit) {
      final String afterClause = (afterCursor != null && afterCursor.isNotEmpty)
          ? ', after: "$afterCursor"'
          : '';

      String query;
      if (isCollectionQuery) {
        query = ApiConstants.collectionProductsQuery.replaceFirst(r'($first: Int!)', '(\$first: Int!$afterClause)');
      } else {
        query = ApiConstants.productsQuery.replaceFirst(r'($first: Int!)', '(\$first: Int!$afterClause)');
      }

      final Map<String, dynamic> variables = {'first': 100};
      if (isCollectionQuery) {
        variables['handle'] = collectionHandle;
      }

      final body = jsonEncode({
        'query': query,
        'variables': variables,
      });

      bool fetchedCurrentBatch = false;
      final currentUrls = selectedUrl != null ? [selectedUrl] : urls;

      for (var url in currentUrls) {
        try {
          final response = await client.post(
            url,
            headers: headers,
            body: body,
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            dynamic productsContainer;
            if (isCollectionQuery) {
              productsContainer = data['data']?['collection']?['products'];
            } else {
              productsContainer = data['data']?['products'];
            }

            final edges = productsContainer?['edges'];
            final pageInfo = productsContainer?['pageInfo'];

            if (edges is List && edges.isNotEmpty) {
              selectedUrl = url;
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

              if (pageInfo is Map) {
                hasNextPage = pageInfo['hasNextPage'] == true;
                afterCursor = pageInfo['endCursor']?.toString();
              } else {
                hasNextPage = false;
              }

              fetchedCurrentBatch = true;
              break;
            }
          }
        } catch (e) {
          // Log or handle network error
        }
      }

      if (!fetchedCurrentBatch) {
        break;
      }
    }

    if (rawNodesToCache.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cacheKey = 'products_cache_${collectionHandle ?? "all"}';
        await prefs.setString(cacheKey, jsonEncode(rawNodesToCache));
      } catch (e) {
        debugPrint('Cache write error: $e');
      }
    }

    return allModels;
  }
}

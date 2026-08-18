import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

abstract class ICollectionRemoteDataSource {
  Future<List<Map<String, String>>> getCollections({int limit = 50});
}

class CollectionRemoteDataSourceImpl implements ICollectionRemoteDataSource {
  final http.Client client;

  CollectionRemoteDataSourceImpl({http.Client? client}) 
      : client = client ?? http.Client();

  @override
  Future<List<Map<String, String>>> getCollections({int limit = 50}) async {
    final List<Map<String, String>> collections = [];

    final headers = {
      'X-Shopify-Storefront-Access-Token': ApiConstants.storefrontAccessToken,
      'Content-Type': 'application/json',
    };

    final urls = [
      Uri.parse(ApiConstants.graphqlEndpoint),
      Uri.parse(ApiConstants.corsProxyEndpoint),
    ];

    final body = jsonEncode({
      'query': ApiConstants.collectionsQuery,
      'variables': {'first': limit},
    });

    for (var url in urls) {
      try {
        final response = await client.post(
          url,
          headers: headers,
          body: body,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final edges = data['data']?['collections']?['edges'];

          if (edges is List && edges.isNotEmpty) {
            for (var edge in edges) {
              if (edge is Map) {
                final node = edge['node'];
                if (node is Map) {
                  collections.add({
                    'title': node['title']?.toString() ?? '',
                    'handle': node['handle']?.toString() ?? '',
                  });
                }
              }
            }
            break; // Stop falling back if successful
          }
        }
      } catch (e) {
        debugPrint('Failed to fetch collections from $url: $e');
      }
    }

    return collections;
  }
}

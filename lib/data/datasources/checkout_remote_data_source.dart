import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/app_analytics_service.dart';
import '../../domain/entities/cart_item.dart';
import 'customer_remote_data_source.dart';
import 'secure_storage_service.dart';

class CheckoutResult {
  final String checkoutUrl;
  final String? noticeMessage;

  CheckoutResult({
    required this.checkoutUrl,
    this.noticeMessage,
  });
}

abstract class ICheckoutRemoteDataSource {
  Future<CheckoutResult> createCheckout({
    required List<CartItem> items,
    String? customerAccessToken,
  });
}

class CheckoutRemoteDataSourceImpl implements ICheckoutRemoteDataSource {
  final http.Client client;
  final ICustomerRemoteDataSource customerRemoteDataSource;
  final SecureStorageService secureStorageService;

  CheckoutRemoteDataSourceImpl({
    http.Client? client,
    required this.customerRemoteDataSource,
    required this.secureStorageService,
  }) : client = client ?? http.Client();

  final Map<String, String> _headers = {
    'X-Shopify-Storefront-Access-Token': ApiConstants.storefrontAccessToken,
    'Content-Type': 'application/json',
  };

  Future<http.Response> _postGraphQL(String body) async {
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

    for (var url in urls) {
      try {
        final response = await client.post(url, headers: _headers, body: body);
        if (response.statusCode == 200) {
          return response;
        }
      } catch (_) {}
    }

    throw Exception('Failed to connect to Shopify server. Please check your internet connection.');
  }

  @override
  Future<CheckoutResult> createCheckout({
    required List<CartItem> items,
    String? customerAccessToken,
  }) async {
    if (items.isEmpty) {
      throw Exception('Cannot create checkout session for an empty cart.');
    }

    final validItems = items.where((item) {
      final id = item.selectedVariant.id;
      return !id.startsWith('fallback_') && !id.startsWith('v_offer_') && !id.startsWith('mock_');
    }).toList();

    if (validItems.isEmpty) {
      throw Exception('Your cart contains offline items. Please clear cart and re-add your fresh products.');
    }

    // Record App Order Metrics in Analytics Service
    final totalOrderAmount = validItems.fold(0.0, (sum, i) => sum + (i.selectedVariant.price * i.quantity));
    final totalOrderItems = validItems.fold(0, (sum, i) => sum + i.quantity);

    AppAnalyticsService.instance.recordCheckout(
      totalAmount: totalOrderAmount,
      itemsCount: totalOrderItems,
    );

    final lines = validItems.map((item) {
      return {
        'merchandiseId': item.selectedVariant.id,
        'quantity': item.quantity,
      };
    }).toList();

    if (customerAccessToken != null && customerAccessToken.isNotEmpty) {
      try {
        final result = await _executeCartCreate(lines, customerAccessToken);
        return CheckoutResult(checkoutUrl: result);
      } catch (_) {
        try {
          final credentials = await secureStorageService.getCredentials();
          if (credentials != null) {
            final refreshedToken = await customerRemoteDataSource.login(
              credentials['email']!,
              credentials['password']!,
            );
            await secureStorageService.saveCustomerToken(refreshedToken);
            final result = await _executeCartCreate(lines, refreshedToken);
            return CheckoutResult(checkoutUrl: result);
          }
        } catch (_) {}

        final guestUrl = await _executeCartCreate(lines, null);
        return CheckoutResult(
          checkoutUrl: guestUrl,
          noticeMessage: 'Session expired. You may log in during checkout to complete your order.',
        );
      }
    }

    final guestUrl = await _executeCartCreate(lines, null);
    return CheckoutResult(checkoutUrl: guestUrl);
  }

  Future<String> _executeCartCreate(List<Map<String, dynamic>> lines, String? token) async {
    final Map<String, dynamic> cartInput = {
      'lines': lines,
      'attributes': [
        {'key': 'Order Source', 'value': 'Fresh Yard Mobile App'},
        {'key': 'App Attribution', 'value': 'Mobile Storefront'},
      ],
    };
    if (token != null && token.isNotEmpty) {
      cartInput['buyerIdentity'] = {
        'customerAccessToken': token,
      };
    }

    final body = jsonEncode({
      'query': ApiConstants.cartCreateMutation,
      'variables': {
        'input': cartInput,
      },
    });

    final response = await _postGraphQL(body);
    final data = jsonDecode(response.body);

    if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
      final errorMsg = data['errors'][0]['message'] ?? 'Cart creation error';
      throw Exception(errorMsg);
    }

    final cartData = data['data']?['cartCreate'];
    final userErrors = cartData?['userErrors'] as List?;

    if (userErrors != null && userErrors.isNotEmpty) {
      final errorMsg = userErrors[0]['message'] ?? 'Failed to create checkout';
      throw Exception(errorMsg);
    }

    final checkoutUrl = cartData?['cart']?['checkoutUrl'] as String?;
    if (checkoutUrl == null || checkoutUrl.isEmpty) {
      throw Exception('Shopify returned an empty checkout URL.');
    }

    return checkoutUrl;
  }
}

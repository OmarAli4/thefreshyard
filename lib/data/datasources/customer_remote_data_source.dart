import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../domain/entities/customer.dart';

abstract class ICustomerRemoteDataSource {
  Future<String> login(String email, String password);
  Future<void> register(String firstName, String lastName, String email, String password);
  Future<Customer> getCustomerProfile(String accessToken);
}

class CustomerRemoteDataSourceImpl implements ICustomerRemoteDataSource {
  final http.Client client;

  CustomerRemoteDataSourceImpl({http.Client? client}) 
      : client = client ?? http.Client();

  final Map<String, String> _headers = {
    'X-Shopify-Storefront-Access-Token': ApiConstants.storefrontAccessToken,
    'Content-Type': 'application/json',
  };

  Future<http.Response> _postGraphQL(String body) async {
    final urls = [
      Uri.parse(ApiConstants.graphqlEndpoint),
      Uri.parse(ApiConstants.corsProxyEndpoint),
    ];

    for (var url in urls) {
      try {
        final response = await client.post(url, headers: _headers, body: body);
        if (response.statusCode == 200) {
          return response;
        }
      } catch (e) {
        // Try fallback CORS proxy URL
      }
    }

    throw Exception('Failed to connect to Shopify server. Please check your internet connection.');
  }

  @override
  Future<String> login(String email, String password) async {
    final body = jsonEncode({
      'query': ApiConstants.customerAccessTokenCreateMutation,
      'variables': {
        'input': {
          'email': email.trim(),
          'password': password.trim(),
        }
      }
    });

    final response = await _postGraphQL(body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        final topError = (data['errors'] as List).first['message']?.toString() ?? 'Shopify error occurred';
        if (topError.contains('unauthenticated_write_customers')) {
          throw Exception('Customer accounts permission is pending in Shopify Admin settings.');
        }
        throw Exception(topError);
      }

      final payload = data['data']?['customerAccessTokenCreate'];
      final errors = payload?['customerUserErrors'] as List?;

      if (errors != null && errors.isNotEmpty) {
        final msg = errors.first['message'] ?? 'Invalid credentials';
        throw Exception(msg);
      }

      final token = payload?['customerAccessToken']?['accessToken']?.toString();
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }

    throw Exception('Login failed. Please check your email and password.');
  }

  @override
  Future<void> register(String firstName, String lastName, String email, String password) async {
    final body = jsonEncode({
      'query': ApiConstants.customerCreateMutation,
      'variables': {
        'input': {
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.trim(),
          'password': password.trim(),
        }
      }
    });

    final response = await _postGraphQL(body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        final topError = (data['errors'] as List).first['message']?.toString() ?? 'Shopify error occurred';
        if (topError.contains('unauthenticated_write_customers')) {
          throw Exception('Customer accounts permission is pending in Shopify Admin settings.');
        }
        throw Exception(topError);
      }

      final payload = data['data']?['customerCreate'];
      final errors = payload?['customerUserErrors'] as List?;

      if (errors != null && errors.isNotEmpty) {
        final msg = errors.first['message'] ?? 'Registration failed';
        throw Exception(msg);
      }

      return;
    }

    throw Exception('Could not register account. Please try again.');
  }

  @override
  Future<Customer> getCustomerProfile(String accessToken) async {
    final body = jsonEncode({
      'query': ApiConstants.getCustomerProfileQuery,
      'variables': {
        'customerAccessToken': accessToken,
      }
    });

    final response = await _postGraphQL(body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final custNode = data['data']?['customer'];

      if (custNode != null && custNode is Map) {
        final String id = custNode['id']?.toString() ?? '';
        final String firstName = custNode['firstName']?.toString() ?? 'Valued';
        final String lastName = custNode['lastName']?.toString() ?? 'Customer';
        final String email = custNode['email']?.toString() ?? '';
        final String? phone = custNode['phone']?.toString();

        String? defaultAddress;
        if (custNode['defaultAddress'] is Map) {
          final addr = custNode['defaultAddress'];
          defaultAddress = '${addr['address1'] ?? ''}, ${addr['city'] ?? ''}, ${addr['country'] ?? ''}'.trim();
        }

        final List<CustomerOrder> orders = [];
        final orderEdges = custNode['orders']?['edges'] as List?;
        if (orderEdges != null) {
          for (var edge in orderEdges) {
            final node = edge['node'];
            if (node is Map) {
              final List<String> itemTitles = [];
              final lineEdges = node['lineItems']?['edges'] as List?;
              if (lineEdges != null) {
                for (var line in lineEdges) {
                  final title = line['node']?['title']?.toString();
                  final qty = line['node']?['quantity']?.toString();
                  if (title != null) itemTitles.add('$title (x$qty)');
                }
              }

              orders.add(CustomerOrder(
                id: node['id']?.toString() ?? '',
                orderNumber: int.tryParse(node['orderNumber']?.toString() ?? '0') ?? 0,
                processedAt: node['processedAt']?.toString() ?? '',
                financialStatus: node['financialStatus']?.toString() ?? 'PAID',
                fulfillmentStatus: node['fulfillmentStatus']?.toString() ?? 'FULFILLED',
                totalPrice: double.tryParse(node['totalPrice']?['amount']?.toString() ?? '0.0') ?? 0.0,
                currencyCode: node['totalPrice']?['currencyCode']?.toString() ?? 'EGP',
                itemTitles: itemTitles,
              ));
            }
          }
        }

        return Customer(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          accessToken: accessToken,
          defaultAddress: defaultAddress,
          orders: orders,
        );
      }
    }

    throw Exception('Failed to load profile details');
  }
}

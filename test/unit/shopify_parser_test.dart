import 'package:flutter_test/flutter_test.dart';
import 'package:the_fresh_yard/data/models/product_model.dart';
import 'package:the_fresh_yard/data/models/variant_model.dart';

void main() {
  group('Shopify GraphQL Data Parsers & Serialization Tests', () {
    test('ProductModel parses valid Shopify GraphQL node accurately', () {
      final jsonPayload = {
        'node': {
          'id': 'gid://shopify/Product/101',
          'title': 'Organic Hass Avocado',
          'description': 'Fresh creamy avocados straight from the farm.',
          'images': {
            'edges': [
              {
                'node': {
                  'url': 'https://cdn.shopify.com/s/files/1/avocado.jpg',
                }
              }
            ]
          },
          'variants': {
            'edges': [
              {
                'node': {
                  'id': 'gid://shopify/ProductVariant/201',
                  'title': '1 Kg',
                  'price': {
                    'amount': '120.00',
                    'currencyCode': 'EGP',
                  },
                  'compareAtPrice': {
                    'amount': '150.00',
                    'currencyCode': 'EGP',
                  },
                  'selectedOptions': [
                    {'name': 'Weight', 'value': '1 Kg'}
                  ]
                }
              }
            ]
          },
          'rating': {
            'value': '{"value":4.8,"scale_max":5.0}',
          },
          'ratingCount': {
            'value': '42',
          }
        }
      };

      final productModel = ProductModel.fromJson(jsonPayload);

      expect(productModel.id, 'gid://shopify/Product/101');
      expect(productModel.title, 'Organic Hass Avocado');
      expect(productModel.description, contains('creamy avocados'));
      expect(productModel.imageUrl, 'https://cdn.shopify.com/s/files/1/avocado.jpg');
      expect(productModel.variants.length, 1);
      expect(productModel.variants.first.price, 120.0);
      expect(productModel.variants.first.compareAtPrice, 150.0);
      expect(productModel.variants.first.currencyCode, 'EGP');
      expect(productModel.rating, 4.8);
      expect(productModel.ratingCount, 42);

      // Verify domain mapping
      final domain = productModel.toDomain();
      expect(domain.id, productModel.id);
      expect(domain.variants.first.price, 120.0);
      expect(domain.variants.first.compareAtPrice, 150.0);
    });

    test('ProductModel handles missing images and null compareAtPrice without crash', () {
      final minimalPayload = {
        'id': 'gid://shopify/Product/102',
        'title': 'Fresh Mint',
        'description': null,
        'images': {'edges': []},
        'variants': {
          'edges': [
            {
              'node': {
                'id': 'gid://shopify/ProductVariant/202',
                'title': 'Bunch',
                'price': {'amount': '15.5', 'currencyCode': 'EGP'},
                'compareAtPrice': null,
              }
            }
          ]
        },
      };

      final productModel = ProductModel.fromJson(minimalPayload);

      expect(productModel.id, 'gid://shopify/Product/102');
      expect(productModel.title, 'Fresh Mint');
      expect(productModel.imageUrl, isNull);
      expect(productModel.variants.first.compareAtPrice, isNull);
      expect(productModel.variants.first.price, 15.5);
    });

    test('ProductModel handles completely corrupted/malformed JSON gracefully', () {
      final corruptedPayload = <String, dynamic>{
        'random_garbage': 12345,
        'images': 'not_a_map',
        'variants': true,
      };

      final productModel = ProductModel.fromJson(corruptedPayload);

      expect(productModel.id, '');
      expect(productModel.title, isEmpty);
      expect(productModel.imageUrl, isNull);
      expect(productModel.variants, isEmpty);
    });

    test('VariantModel parses selected options correctly', () {
      final variantJson = {
        'id': 'gid://shopify/ProductVariant/505',
        'title': 'Medium / Red',
        'price': {'amount': '75.0', 'currencyCode': 'EGP'},
        'selectedOptions': [
          {'name': 'Size', 'value': 'Medium'},
          {'name': 'Color', 'value': 'Red'},
        ]
      };

      final variant = VariantModel.fromJson(variantJson);

      expect(variant.id, 'gid://shopify/ProductVariant/505');
      expect(variant.price, 75.0);
      expect(variant.options['Size'], 'Medium');
      expect(variant.options['Color'], 'Red');
    });
  });
}

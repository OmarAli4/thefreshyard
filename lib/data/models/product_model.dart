import 'dart:convert';
import 'variant_model.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';

class ProductModel {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<VariantModel> variants;
  final double? rating;
  final int? ratingCount;

  const ProductModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.variants,
    this.rating,
    this.ratingCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      final node = json['node'] is Map<String, dynamic> ? json['node'] as Map<String, dynamic> : json;

      String? parsedImageUrl;
      final imagesObj = node['images'];
      if (imagesObj is Map) {
        final edges = imagesObj['edges'];
        if (edges is List && edges.isNotEmpty) {
          final first = edges.first;
          if (first is Map) {
            final imgNode = first['node'];
            if (imgNode is Map) {
              parsedImageUrl = imgNode['url']?.toString();
            }
          }
        }
      }

      final List<VariantModel> parsedVariants = [];
      final variantsObj = node['variants'];
      if (variantsObj is Map) {
        final edges = variantsObj['edges'];
        if (edges is List) {
          for (var edge in edges) {
            if (edge is Map) {
              final vNode = edge['node'];
              if (vNode is Map<String, dynamic>) {
                parsedVariants.add(VariantModel.fromJson(vNode));
              }
            }
          }
        }
      }

      // Parse Shopify Reviews Metafields
      double? parsedRating;
      final ratingMeta = node['rating'];
      if (ratingMeta is Map) {
        final valStr = ratingMeta['value']?.toString();
        if (valStr != null && valStr.isNotEmpty) {
          try {
            if (valStr.startsWith('{')) {
              final valJson = jsonDecode(valStr);
              if (valJson is Map && valJson['value'] != null) {
                parsedRating = double.tryParse(valJson['value'].toString());
              }
            } else {
              parsedRating = double.tryParse(valStr);
            }
          } catch (_) {
            parsedRating = double.tryParse(valStr);
          }
        }
      }

      int? parsedRatingCount;
      final countMeta = node['ratingCount'];
      if (countMeta is Map) {
        final countVal = countMeta['value']?.toString();
        if (countVal != null && countVal.isNotEmpty) {
          parsedRatingCount = int.tryParse(countVal);
        }
      }

      return ProductModel(
        id: node['id']?.toString() ?? '',
        title: node['title']?.toString() ?? '',
        description: node['description']?.toString(),
        imageUrl: parsedImageUrl,
        variants: parsedVariants,
        rating: parsedRating,
        ratingCount: parsedRatingCount,
      );
    } catch (e, stack) {
      debugPrint('Error parsing ProductModel: $e\n$stack');
      return ProductModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Unknown Product',
        description: null,
        imageUrl: null,
        variants: [],
        rating: null,
        ratingCount: null,
      );
    }
  }

  Product toDomain() {
    return Product(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      variants: variants.map((v) => ProductVariant(
        id: v.id,
        title: v.title,
        price: v.price,
        compareAtPrice: v.compareAtPrice,
        currencyCode: v.currencyCode,
        options: v.options,
      )).toList(),
      rating: rating,
      ratingCount: ratingCount,
    );
  }
}

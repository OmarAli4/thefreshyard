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

  const ProductModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.variants,
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

      return ProductModel(
        id: node['id']?.toString() ?? '',
        title: node['title']?.toString() ?? '',
        description: node['description']?.toString(),
        imageUrl: parsedImageUrl,
        variants: parsedVariants,
      );
    } catch (e, stack) {
      debugPrint('Error parsing ProductModel: $e\n$stack');
      return ProductModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Unknown Product',
        description: null,
        imageUrl: null,
        variants: [],
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
        currencyCode: v.currencyCode,
        options: v.options,
      )).toList(),
    );
  }
}

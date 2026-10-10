import 'package:equatable/equatable.dart';
import 'product_variant.dart';

class Product extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<ProductVariant> variants;
  final double? rating;
  final int? ratingCount;

  const Product({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.variants,
    this.rating,
    this.ratingCount,
  });

  @override
  List<Object?> get props => [id, title, description, imageUrl, variants, rating, ratingCount];
}

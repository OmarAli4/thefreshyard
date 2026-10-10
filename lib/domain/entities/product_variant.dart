import 'package:equatable/equatable.dart';

class ProductVariant extends Equatable {
  final String id;
  final String title;
  final double price;
  final double? compareAtPrice;
  final String currencyCode;
  final Map<String, String> options;

  const ProductVariant({
    required this.id,
    required this.title,
    required this.price,
    this.compareAtPrice,
    required this.currencyCode,
    required this.options,
  });

  @override
  List<Object?> get props => [id, title, price, compareAtPrice, currencyCode, options];
}

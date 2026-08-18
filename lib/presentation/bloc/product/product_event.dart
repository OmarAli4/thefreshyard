import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final int limit;
  final String? collectionHandle;

  const FetchProductsEvent({this.limit = 500, this.collectionHandle});

  @override
  List<Object> get props => [limit, collectionHandle ?? ''];
}

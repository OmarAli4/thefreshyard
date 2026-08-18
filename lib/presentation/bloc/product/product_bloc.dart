import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/get_products_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase _getProductsUseCase;

  ProductBloc({required this._getProductsUseCase}) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      // 1. Fetch from Cache first for instant load
      // Since GetProductsUseCase only fetches from remote (or falls back), 
      // ideally we should inject GetCachedProductsUseCase. 
      // But for simplicity in this file, we can modify the usecase or repo later.
      final stream = _getProductsUseCase(
        limit: event.limit,
        collectionHandle: event.collectionHandle,
      );
      
      await for (final products in stream) {
        emit(ProductLoaded(products));
      }
    } catch (e) {
      emit(const ProductError("Failed to fetch products. Please try again."));
    }
  }
}

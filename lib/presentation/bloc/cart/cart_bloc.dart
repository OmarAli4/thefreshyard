import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/usecases/create_checkout_usecase.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CreateCheckoutUseCase? createCheckoutUseCase;

  CartBloc({this.createCheckoutUseCase}) : super(const CartState()) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<CreateCheckoutSessionEvent>(_onCreateCheckoutSession);
    on<ResetCheckoutStateEvent>(_onResetCheckoutState);
  }

  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) {
    if (event.variant.id.startsWith('fallback_') ||
        event.variant.id.startsWith('v_offer_')) {
      return;
    }

    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.selectedVariant.id == event.variant.id,
    );

    if (index >= 0) {
      final existingItem = currentItems[index];
      currentItems[index] = existingItem.copyWith(
        quantity: existingItem.quantity + event.quantity,
      );
    } else {
      currentItems.add(CartItem(
        product: event.product,
        selectedVariant: event.variant,
        quantity: event.quantity,
      ));
    }

    emit(state.copyWith(
      items: currentItems,
      clearCheckoutUrl: true,
      clearCheckoutError: true,
      clearCheckoutNotice: true,
    ));
  }

  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) {
    final updatedItems = state.items
        .where((item) => item.selectedVariant.id != event.variantId)
        .toList();
    emit(state.copyWith(
      items: updatedItems,
      clearCheckoutUrl: true,
      clearCheckoutError: true,
      clearCheckoutNotice: true,
    ));
  }

  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit) {
    if (event.newQuantity <= 0) {
      add(RemoveFromCartEvent(event.variantId));
      return;
    }

    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.selectedVariant.id == event.variantId,
    );

    if (index >= 0) {
      currentItems[index] = currentItems[index].copyWith(quantity: event.newQuantity);
      emit(state.copyWith(
        items: currentItems,
        clearCheckoutUrl: true,
        clearCheckoutError: true,
        clearCheckoutNotice: true,
      ));
    }
  }

  void _onResetCheckoutState(ResetCheckoutStateEvent event, Emitter<CartState> emit) {
    emit(state.copyWith(
      clearCheckoutUrl: true,
      clearCheckoutError: true,
      clearCheckoutNotice: true,
    ));
  }

  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    emit(state.copyWith(
      items: const [],
      clearCheckoutUrl: true,
      clearCheckoutError: true,
      clearCheckoutNotice: true,
    ));
  }

  Future<void> _onCreateCheckoutSession(
    CreateCheckoutSessionEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state.items.isEmpty) {
      emit(state.copyWith(checkoutError: 'Your shopping cart is empty.'));
      return;
    }

    if (createCheckoutUseCase == null) {
      emit(state.copyWith(checkoutError: 'Checkout service is not configured.'));
      return;
    }

    emit(state.copyWith(
      isCheckoutLoading: true,
      clearCheckoutUrl: true,
      clearCheckoutError: true,
      clearCheckoutNotice: true,
    ));

    try {
      final result = await createCheckoutUseCase!.call(
        items: state.items,
        customerAccessToken: event.customerAccessToken,
      );

      emit(state.copyWith(
        isCheckoutLoading: false,
        checkoutUrl: result.checkoutUrl,
        checkoutNoticeMessage: result.noticeMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCheckoutLoading: false,
        checkoutError: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

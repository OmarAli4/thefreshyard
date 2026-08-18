import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_state.dart';
import 'animated_drawing_text_logo.dart';

class CustomHeaderAppBar extends StatelessWidget {
  final VoidCallback onCartTap;

  const CustomHeaderAppBar({
    super.key,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.brandDarkGreen,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: 50,
        child: Stack(
          children: [
            const Positioned.fill(
              child: Center(
                child: AnimatedDrawingTextLogo(
                  height: 24.0,
                  strokeColor: AppColors.brandGold,
                  fillColor: AppColors.brandGold,
                  duration: Duration(seconds: 3),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (innerContext) => GestureDetector(
                            onTap: () => Scaffold.of(innerContext).openDrawer(),
                            child: const Icon(
                              Icons.menu,
                              color: AppColors.brandGold,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        return GestureDetector(
                          onTap: onCartTap,
                          child: Badge(
                            isLabelVisible: cartState.totalItemCount > 0,
                            label: Text(
                              '${cartState.totalItemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.redAccent,
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.brandGold,
                              size: 26,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

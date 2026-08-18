import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/top_promo_banner.dart';
import '../widgets/custom_header_app_bar.dart';
import '../widgets/app_drawer.dart';
import '../views/home_view.dart';
import '../views/search_view.dart';
import '../views/cart_view.dart';
import '../views/profile_view.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductBloc(getProductsUseCase: context.read())
            ..add(const FetchProductsEvent()),
      child: const ProductsView(),
    );
  }
}

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  int _selectedIndex = 0;

  void navigateToCart() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandCream,
      drawer: const AppDrawer(),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.brandDarkGreen,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onTabSelected,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: cartState.totalItemCount > 0,
                  label: Text(
                    '${cartState.totalItemCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.brandDarkGreen,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            const TopPromoBanner(),
            CustomHeaderAppBar(
              onCartTap: navigateToCart,
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  HomeView(onGoToCart: navigateToCart),
                  SearchView(onGoToCart: navigateToCart),
                  CartView(onExploreProducts: () => _onTabSelected(0)),
                  const ProfileView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

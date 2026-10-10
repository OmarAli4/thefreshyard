import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'data/datasources/checkout_remote_data_source.dart';
import 'data/datasources/customer_remote_data_source.dart';
import 'data/datasources/secure_storage_service.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/product_repository.dart';
import 'domain/usecases/create_checkout_usecase.dart';
import 'domain/usecases/get_products_usecase.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/pages/products_page.dart';
import 'presentation/pages/product_details_page.dart';

import 'core/services/collection_cache_service.dart';
import 'core/services/dynamic_content_service.dart';
import 'core/services/app_analytics_service.dart';
import 'core/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 2000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 400 * 1024 * 1024;

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('⚠️ Firebase init status in main: $e');
  }

  // Silence debug prints in release builds
  if (const bool.fromEnvironment('dart.vm.product')) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Global error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('❌ Flutter Error: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('❌ Uncaught Error: $error');
    return true;
  };

  try { await DynamicContentService.instance.init(); } catch (e) { debugPrint('⚠️ DynamicContent init: $e'); }
  try { await CollectionCacheService.instance.init(); } catch (e) { debugPrint('⚠️ CollectionCache init: $e'); }
  try { await AppAnalyticsService.instance.init(); } catch (e) { debugPrint('⚠️ Analytics init: $e'); }
  try {
    await NotificationService.instance.initialize(
      onTap: (payload) {
        debugPrint('🔔 Notification tapped with payload: $payload');
        _handleNotificationNavigation(payload);
      },
    );
  } catch (e) { debugPrint('⚠️ Notification init: $e'); }

  final productRepository = ProductRepository();
  final customerRepository = CustomerRepository();
  final getProductsUseCase = GetProductsUseCase(productRepository);

  final secureStorageService = SecureStorageService();
  final customerRemoteDataSource = CustomerRemoteDataSourceImpl();
  final checkoutRemoteDataSource = CheckoutRemoteDataSourceImpl(
    customerRemoteDataSource: customerRemoteDataSource,
    secureStorageService: secureStorageService,
  );
  final createCheckoutUseCase = CreateCheckoutUseCase(
    repository: checkoutRemoteDataSource,
  );

  runApp(MyApp(
    getProductsUseCase: getProductsUseCase,
    customerRepository: customerRepository,
    createCheckoutUseCase: createCheckoutUseCase,
  ));
}

void _handleNotificationNavigation(String? payload) {
  if (payload == null || payload.isEmpty) return;
  final state = navigatorKey.currentState;
  if (state == null) return;

  debugPrint('🔗 Handling notification navigation for payload: $payload');
  state.popUntil((route) => route.isFirst);

  if (payload.startsWith('product_id:') || payload.startsWith('product:')) {
    final searchParam = payload.replaceFirst(RegExp(r'^product(_id)?:'), '').trim();
    final allProducts = ProductRepository.getFallbackProducts();

    final matchingProduct = allProducts.firstWhere(
      (p) => p.id == searchParam || p.title.toLowerCase().contains(searchParam.toLowerCase()),
      orElse: () => allProducts.first,
    );

    state.push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsPage(product: matchingProduct),
      ),
    );
  }
}

class FastMobileScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics(); // Instant 1:1 responsive touch scrolling
  }
}

class MyApp extends StatelessWidget {
  final GetProductsUseCase getProductsUseCase;
  final ICustomerRepository customerRepository;
  final CreateCheckoutUseCase createCheckoutUseCase;

  const MyApp({
    super.key,
    required this.getProductsUseCase,
    required this.customerRepository,
    required this.createCheckoutUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GetProductsUseCase>.value(value: getProductsUseCase),
        RepositoryProvider<ICustomerRepository>.value(value: customerRepository),
        RepositoryProvider<CreateCheckoutUseCase>.value(value: createCheckoutUseCase),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CartBloc>(

            create: (context) => CartBloc(createCheckoutUseCase: createCheckoutUseCase),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(customerRepository: customerRepository)
              ..add(FetchCustomerProfileEvent()),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'The Fresh Yard',
          debugShowCheckedModeBanner: false,
          scrollBehavior: FastMobileScrollBehavior(),
          theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.grey[50],
          ),
          home: const ProductsPage(),
        ),
      ),
    );
  }
}

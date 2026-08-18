import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/datasources/checkout_remote_data_source.dart';
import 'data/datasources/customer_remote_data_source.dart';
import 'data/datasources/secure_storage_service.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/product_repository.dart';
import 'domain/usecases/create_checkout_usecase.dart';
import 'domain/usecases/get_products_usecase.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/pages/products_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
            create: (context) => AuthBloc(customerRepository: customerRepository),
          ),
        ],
        child: MaterialApp(
          title: 'The Fresh Yard',
          debugShowCheckedModeBanner: false,
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

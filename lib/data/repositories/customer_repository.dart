import '../../domain/entities/customer.dart';
import '../datasources/customer_remote_data_source.dart';

abstract class ICustomerRepository {
  Future<String> login(String email, String password);
  Future<void> register(String firstName, String lastName, String email, String password);
  Future<Customer> getCustomerProfile(String accessToken);
}

class CustomerRepository implements ICustomerRepository {
  final ICustomerRemoteDataSource _remoteDataSource;

  CustomerRepository({ICustomerRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CustomerRemoteDataSourceImpl();

  @override
  Future<String> login(String email, String password) async {
    return await _remoteDataSource.login(email, password);
  }

  @override
  Future<void> register(String firstName, String lastName, String email, String password) async {
    return await _remoteDataSource.register(firstName, lastName, email, password);
  }

  @override
  Future<Customer> getCustomerProfile(String accessToken) async {
    return await _remoteDataSource.getCustomerProfile(accessToken);
  }
}

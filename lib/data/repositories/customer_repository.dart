import '../../domain/entities/customer.dart';
import '../datasources/customer_remote_data_source.dart';

abstract class ICustomerRepository {
  Future<String> login(String email, String password);
  Future<void> register(String firstName, String lastName, String email, String password);
  Future<void> recoverPassword(String email);
  Future<Customer> getCustomerProfile(String accessToken);

  // Modern Passwordless Flow — direct auto-login, returns access token
  Future<String> sendPasswordlessLogin(String email);
  Future<String> registerPasswordless(String firstName, String lastName, String email);
  Future<String> verifyPasswordlessCode(String email, String code);
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
  Future<void> recoverPassword(String email) async {
    return await _remoteDataSource.recoverPassword(email);
  }

  @override
  Future<Customer> getCustomerProfile(String accessToken) async {
    return await _remoteDataSource.getCustomerProfile(accessToken);
  }

  @override
  Future<String> sendPasswordlessLogin(String email) async {
    return await _remoteDataSource.sendPasswordlessLogin(email);
  }

  @override
  Future<String> registerPasswordless(String firstName, String lastName, String email) async {
    return await _remoteDataSource.registerPasswordless(firstName, lastName, email);
  }

  @override
  Future<String> verifyPasswordlessCode(String email, String code) async {
    return await _remoteDataSource.verifyPasswordlessCode(email, code);
  }
}


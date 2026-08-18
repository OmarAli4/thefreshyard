import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? accessToken;
  final String? defaultAddress;
  final List<CustomerOrder> orders;

  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.accessToken,
    this.defaultAddress,
    this.orders = const [],
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone, accessToken, defaultAddress, orders];
}

class CustomerOrder extends Equatable {
  final String id;
  final int orderNumber;
  final String processedAt;
  final String financialStatus;
  final String fulfillmentStatus;
  final double totalPrice;
  final String currencyCode;
  final List<String> itemTitles;

  const CustomerOrder({
    required this.id,
    required this.orderNumber,
    required this.processedAt,
    required this.financialStatus,
    required this.fulfillmentStatus,
    required this.totalPrice,
    required this.currencyCode,
    required this.itemTitles,
  });

  @override
  List<Object?> get props => [id, orderNumber, processedAt, financialStatus, fulfillmentStatus, totalPrice, currencyCode, itemTitles];
}

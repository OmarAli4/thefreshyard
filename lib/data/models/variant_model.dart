class VariantModel {
  final String id;
  final String title; 
  final double price;
  final double? compareAtPrice;
  final String currencyCode;
  final Map<String, String> options;

  const VariantModel({
    required this.id,
    required this.title,
    required this.price,
    this.compareAtPrice,
    required this.currencyCode,
    required this.options,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    try {
      final priceObj = json['price'];
      double parsedPrice = 0.0;
      String currency = 'EGP';

      if (priceObj is Map) {
        final amount = priceObj['amount'];
        parsedPrice = double.tryParse(amount?.toString() ?? '0') ?? 0.0;
        currency = priceObj['currencyCode']?.toString() ?? 'EGP';
      }

      double? parsedComparePrice;
      final compObj = json['compareAtPrice'];
      if (compObj is Map) {
        final compAmount = compObj['amount'];
        if (compAmount != null) {
          parsedComparePrice = double.tryParse(compAmount.toString());
        }
      }

      final Map<String, String> parsedOptions = {};
      final optionsList = json['selectedOptions'];
      if (optionsList is List) {
        for (var option in optionsList) {
          if (option is Map) {
            final name = option['name']?.toString();
            final value = option['value']?.toString();
            if (name != null && value != null) {
              parsedOptions[name] = value;
            }
          }
        }
      }

      return VariantModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        price: parsedPrice,
        compareAtPrice: parsedComparePrice,
        currencyCode: currency,
        options: parsedOptions,
      );
    } catch (e) {
      return VariantModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        price: 0.0,
        compareAtPrice: null,
        currencyCode: 'EGP',
        options: {},
      );
    }
  }
}

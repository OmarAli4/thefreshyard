import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ProductSortOption {
  featured('Featured', 'featured'),
  bestSelling('Best Selling', 'best_selling'),
  priceLowToHigh('Price: Low to High', 'price_asc'),
  priceHighToLow('Price: High to Low', 'price_desc'),
  titleAToZ('Alphabetically: A-Z', 'title_asc'),
  titleZToA('Alphabetically: Z-A', 'title_desc');

  final String label;
  final String code;
  const ProductSortOption(this.label, this.code);
}

class ProductFilterState {
  final ProductSortOption sortOption;
  final RangeValues priceRange;
  final bool inStockOnly;
  final bool isPriceFilterActive;

  const ProductFilterState({
    this.sortOption = ProductSortOption.featured,
    this.priceRange = const RangeValues(0, 5000),
    this.inStockOnly = false,
    this.isPriceFilterActive = false,
  });

  bool get hasActiveFilters =>
      sortOption != ProductSortOption.featured ||
      isPriceFilterActive ||
      inStockOnly;

  int get activeFiltersCount {
    int count = 0;
    if (sortOption != ProductSortOption.featured) count++;
    if (isPriceFilterActive) count++;
    if (inStockOnly) count++;
    return count;
  }

  ProductFilterState copyWith({
    ProductSortOption? sortOption,
    RangeValues? priceRange,
    bool? inStockOnly,
    bool? isPriceFilterActive,
  }) {
    return ProductFilterState(
      sortOption: sortOption ?? this.sortOption,
      priceRange: priceRange ?? this.priceRange,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      isPriceFilterActive: isPriceFilterActive ?? this.isPriceFilterActive,
    );
  }
}

class ProductFilterBottomSheet extends StatefulWidget {
  final ProductFilterState initialState;
  final double maxPriceLimit;
  final Function(ProductFilterState newState) onApply;

  const ProductFilterBottomSheet({
    super.key,
    required this.initialState,
    this.maxPriceLimit = 5000.0,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductFilterState currentState,
    double maxPriceLimit = 5000.0,
    required Function(ProductFilterState newState) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductFilterBottomSheet(
        initialState: currentState,
        maxPriceLimit: maxPriceLimit,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  late ProductSortOption _selectedSort;
  late RangeValues _priceRange;
  late bool _inStockOnly;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialState.sortOption;
    _priceRange = RangeValues(
      widget.initialState.priceRange.start.clamp(0.0, widget.maxPriceLimit),
      widget.initialState.priceRange.end.clamp(0.0, widget.maxPriceLimit),
    );
    _inStockOnly = widget.initialState.inStockOnly;
  }

  void _reset() {
    setState(() {
      _selectedSort = ProductSortOption.featured;
      _priceRange = RangeValues(0, widget.maxPriceLimit);
      _inStockOnly = false;
    });
  }

  void _apply() {
    final bool isPriceTouched = _priceRange.start > 0 || _priceRange.end < widget.maxPriceLimit;
    final newState = ProductFilterState(
      sortOption: _selectedSort,
      priceRange: _priceRange,
      inStockOnly: _inStockOnly,
      isPriceFilterActive: isPriceTouched,
    );
    widget.onApply(newState);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.brandDarkGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.brandGold, width: 1.5),
          left: BorderSide(color: AppColors.brandGold, width: 0.5),
          right: BorderSide(color: AppColors.brandGold, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.brandGold.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppColors.brandGold, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Filter & Sort Harvest",
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandGold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _reset,
                child: Text(
                  "Reset All",
                  style: TextStyle(
                    color: AppColors.brandCream,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0x33C4AB63), height: 20),

          // 1. Sort By Section
          Text(
            "SORT BY",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: AppColors.brandGold,
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProductSortOption.values.map((option) {
              final isSelected = _selectedSort == option;
              return ChoiceChip(
                label: Text(option.label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedSort = option);
                  }
                },
                selectedColor: AppColors.brandGold,
                backgroundColor: AppColors.brandDarkGreen,
                side: BorderSide(
                  color: isSelected ? AppColors.brandGold : AppColors.brandGold.withValues(alpha: 0.35),
                  width: 1.0,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.brandDarkGreen : AppColors.brandCream,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),

          // 2. Price Range Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PRICE RANGE (EGP)",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppColors.brandGold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  "LE ${_priceRange.start.toInt()} - LE ${_priceRange.end.toInt()}",
                  style: TextStyle(
                    color: AppColors.brandGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0.0,
            max: widget.maxPriceLimit,
            divisions: 20,
            activeColor: AppColors.brandGold,
            inactiveColor: AppColors.brandGold.withValues(alpha: 0.2),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          SizedBox(height: 12),

          // 3. Availability Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.brandGold, size: 20),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "In Stock Only",
                          style: TextStyle(
                            color: AppColors.brandCream,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          "Hide currently out-of-stock items",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _inStockOnly,
                  activeThumbColor: AppColors.brandGold,
                  activeTrackColor: AppColors.brandGold.withValues(alpha: 0.4),
                  onChanged: (val) {
                    setState(() => _inStockOnly = val);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGold,
                foregroundColor: AppColors.brandDarkGreen,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: _apply,
              icon: const Icon(Icons.check_rounded, color: AppColors.brandDarkGreen),
              label: Text(
                "Apply Filters",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




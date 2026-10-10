import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicPromoBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final String tag;
  final String ctaText;

  const DynamicPromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.tag,
    required this.ctaText,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'imagePath': imagePath,
        'tag': tag,
        'ctaText': ctaText,
      };

  factory DynamicPromoBanner.fromJson(Map<String, dynamic> json) {
    return DynamicPromoBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      tag: json['tag']?.toString() ?? '',
      ctaText: json['ctaText']?.toString() ?? 'Shop Now',
    );
  }

  DynamicPromoBanner copyWith({
    String? title,
    String? subtitle,
    String? imagePath,
    String? tag,
    String? ctaText,
  }) {
    return DynamicPromoBanner(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imagePath: imagePath ?? this.imagePath,
      tag: tag ?? this.tag,
      ctaText: ctaText ?? this.ctaText,
    );
  }
}

class DynamicContentService extends ChangeNotifier {
  static final DynamicContentService instance = DynamicContentService._internal();
  DynamicContentService._internal();

  static const String _prefBannersKey = 'dynamic_promo_banners_v1';
  static const String _prefCategoryImagesKey = 'dynamic_category_images_v1';

  // Default Factory Promo Banners
  static const List<DynamicPromoBanner> _defaultBanners = [
    DynamicPromoBanner(
      id: 'default_1',
      title: 'ORCHARD HARVEST',
      subtitle: 'Sun-Kissed Golden Mangoes & Fresh Berries Direct from Ismailia Orchards',
      imagePath: 'assets/images/banner_mango_wow.jpg',
      tag: '100% ESTATE GROWN',
      ctaText: 'Explore Mangoes',
    ),
    DynamicPromoBanner(
      id: 'default_2',
      title: 'ARTISANAL GREENS',
      subtitle: 'Hand-Picked Hydroponic Salads & Crisp Vegetables Harvested Daily at Dawn',
      imagePath: 'assets/images/banner_veggies_wow.jpg',
      tag: 'FRESH AT DAWN',
      ctaText: 'Explore Veggies',
    ),
    DynamicPromoBanner(
      id: 'default_3',
      title: 'THE FRESH LAB',
      subtitle: 'Cold-Pressed Pure Fruit Elixirs & Ceremonial Uji Japanese Matcha',
      imagePath: 'assets/images/banner_fresh_lab.png',
      tag: 'COLD PRESSED',
      ctaText: 'Explore Lab',
    ),
  ];

  List<DynamicPromoBanner> _banners = [];
  Map<String, String> _categoryImages = {};
  bool _isInitialized = false;

  List<DynamicPromoBanner> get banners => _banners.isNotEmpty ? _banners : _defaultBanners;
  Map<String, String> get categoryImages => _categoryImages;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Load Banners
      final bannersString = prefs.getString(_prefBannersKey);
      if (bannersString != null && bannersString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(bannersString);
        _banners = decoded.map((item) => DynamicPromoBanner.fromJson(item)).toList();
      } else {
        _banners = List.from(_defaultBanners);
      }

      // 2. Load Category Image Overrides
      final catImagesString = prefs.getString(_prefCategoryImagesKey);
      if (catImagesString != null && catImagesString.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(catImagesString);
        _categoryImages = decoded.map((k, v) => MapEntry(k, v.toString()));
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing DynamicContentService: $e');
      _banners = List.from(_defaultBanners);
    }
  }

  // --- Category Images Management ---

  String getCategoryImage(String collectionHandle, String fallbackAssetPath) {
    final handleClean = collectionHandle.toLowerCase().trim();
    if (_categoryImages.containsKey(handleClean) && _categoryImages[handleClean]!.isNotEmpty) {
      return _categoryImages[handleClean]!;
    }
    return fallbackAssetPath;
  }

  Future<void> setCategoryImage(String collectionHandle, String newImagePath) async {
    final handleClean = collectionHandle.toLowerCase().trim();
    _categoryImages[handleClean] = newImagePath.trim();
    await _persistCategoryImages();
    notifyListeners();
  }

  Future<void> removeCategoryImageOverride(String collectionHandle) async {
    final handleClean = collectionHandle.toLowerCase().trim();
    _categoryImages.remove(handleClean);
    await _persistCategoryImages();
    notifyListeners();
  }

  Future<void> _persistCategoryImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefCategoryImagesKey, jsonEncode(_categoryImages));
    } catch (e) {
      debugPrint('Error saving category images: $e');
    }
  }

  // --- Banners Management ---

  Future<void> addBanner(DynamicPromoBanner banner) async {
    _banners.add(banner);
    await _persistBanners();
    notifyListeners();
  }

  Future<void> updateBanner(DynamicPromoBanner updatedBanner) async {
    final index = _banners.indexWhere((b) => b.id == updatedBanner.id);
    if (index >= 0) {
      _banners[index] = updatedBanner;
      await _persistBanners();
      notifyListeners();
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    _banners.removeWhere((b) => b.id == bannerId);
    if (_banners.isEmpty) {
      _banners = List.from(_defaultBanners);
    }
    await _persistBanners();
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _banners = List.from(_defaultBanners);
    _categoryImages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefBannersKey);
    await prefs.remove(_prefCategoryImagesKey);
    notifyListeners();
  }

  Future<void> _persistBanners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_banners.map((b) => b.toJson()).toList());
      await prefs.setString(_prefBannersKey, jsonString);
    } catch (e) {
      debugPrint('Error saving banners: $e');
    }
  }
}

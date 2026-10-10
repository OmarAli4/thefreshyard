import 'package:flutter/material.dart';
import '../../core/services/admin_service.dart';
import '../../core/services/app_analytics_service.dart';
import '../../core/services/collection_cache_service.dart';
import '../../core/services/dynamic_content_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/product_repository.dart';
import 'admin_product_search_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Product> _availableProducts;
  Product? _selectedProduct;

  final _customDiscountController = TextEditingController(text: '30% OFF');
  final _customOfferNotificationTitleController = TextEditingController();
  final _customOfferNotificationBodyController = TextEditingController();

  List<Map<String, String>> get _shopifyCollections {
    final live = CollectionCacheService.instance.collections;
    return [
      {'title': 'All Harvest', 'handle': 'all', 'defaultAsset': 'assets/images/banner_berry_wow.jpg'},
      ...live.map((c) => {
            'title': c.title,
            'handle': c.handle,
            'defaultAsset': c.imageUrl.isNotEmpty ? c.imageUrl : 'assets/images/banner_berry_wow.jpg',
          }),
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _availableProducts = ProductRepository.getFallbackProducts();
    if (_availableProducts.isNotEmpty) {
      _selectedProduct = _availableProducts.first;
      _autoGenerateOfferText();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customDiscountController.dispose();
    _customOfferNotificationTitleController.dispose();
    _customOfferNotificationBodyController.dispose();
    super.dispose();
  }

  void _autoGenerateOfferText() {
    if (_selectedProduct == null) return;
    final productTitle = _selectedProduct!.title;
    final discount = _customDiscountController.text.trim();

    final title = "🥭 Special Harvest Offer: ${discount.isNotEmpty ? discount : 'Special Deal'} on $productTitle!";
    final body = "Limited time deal! Get ${discount.isNotEmpty ? discount : 'discount'} on $productTitle today. Tap here to open and order now!";

    _customOfferNotificationTitleController.text = title;
    _customOfferNotificationBodyController.text = body;
    setState(() {});
  }

  Widget _buildImagePreview(String path, {double width = 60, double height = 60, double radius = 12}) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: width,
        height: height,
        color: AppColors.brandDarkGreen,
        child: isNetwork
            ? Image.network(
                path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_rounded,
                  color: AppColors.brandGold,
                ),
              )
            : Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_rounded,
                  color: AppColors.brandGold,
                ),
              ),
      ),
    );
  }

  // --- Dialog: Add / Edit Banner ---
  void _showBannerDialog({DynamicPromoBanner? bannerToEdit}) {
    final titleController = TextEditingController(text: bannerToEdit?.title ?? '');
    final subtitleController = TextEditingController(text: bannerToEdit?.subtitle ?? '');
    final imageController = TextEditingController(text: bannerToEdit?.imagePath ?? '');
    final tagController = TextEditingController(text: bannerToEdit?.tag ?? 'ESTATE HARVEST');
    final ctaController = TextEditingController(text: bannerToEdit?.ctaText ?? 'Shop Now');
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.brandGold, width: 1.2),
              ),
              title: Text(
                bannerToEdit == null ? "Add New Promo Banner" : "Edit Promo Banner",
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandDarkGreen,
                  fontSize: 18,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dialogError != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dialogError!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Banner Title (e.g. SUMMER BERRY FIESTA)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle / Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL or Asset Path',
                        hintText: 'https://images.unsplash.com/... or assets/...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tagController,
                      decoration: const InputDecoration(
                        labelText: 'Badge Tag (e.g. 100% ORGANIC)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ctaController,
                      decoration: const InputDecoration(
                        labelText: 'Button Text (e.g. Shop Now)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandDarkGreen,
                    foregroundColor: AppColors.brandGold,
                  ),
                  onPressed: () {
                    final t = titleController.text.trim();
                    final img = imageController.text.trim();

                    if (t.isEmpty) {
                      setDialogState(() => dialogError = "Please enter a banner title.");
                      return;
                    }
                    if (img.isEmpty) {
                      setDialogState(() => dialogError = "Please enter an image URL or asset path.");
                      return;
                    }

                    if (bannerToEdit != null) {
                      final updated = bannerToEdit.copyWith(
                        title: t,
                        subtitle: subtitleController.text.trim(),
                        imagePath: img,
                        tag: tagController.text.trim(),
                        ctaText: ctaController.text.trim(),
                      );
                      DynamicContentService.instance.updateBanner(updated);
                    } else {
                      final newBanner = DynamicPromoBanner(
                        id: 'banner_${DateTime.now().millisecondsSinceEpoch}',
                        title: t,
                        subtitle: subtitleController.text.trim(),
                        imagePath: img,
                        tag: tagController.text.trim(),
                        ctaText: ctaController.text.trim(),
                      );
                      DynamicContentService.instance.addBanner(newBanner);
                    }

                    Navigator.of(ctx).pop();
                    setState(() {});
                  },
                  child: const Text('Save Banner', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Dialog: Change Category Image ---
  void _showChangeCategoryImageDialog(Map<String, String> col) {
    final currentImg = DynamicContentService.instance.getCategoryImage(col['handle']!, col['defaultAsset']!);
    final urlController = TextEditingController(text: currentImg);
    String? localError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.brandGold, width: 1.2),
              ),
              title: Text(
                "Change Image: ${col['title']}",
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandDarkGreen,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Paste a new image URL from Unsplash, Shopify, or web. It will immediately appear across the entire app for this collection.",
                    style: TextStyle(fontSize: 12.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 14),
                  if (localError != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        localError!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL or Asset Path',
                      hintText: 'https://...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    DynamicContentService.instance.removeCategoryImageOverride(col['handle']!);
                    Navigator.of(ctx).pop();
                    setState(() {});
                  },
                  child: const Text('Reset to Default', style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandDarkGreen,
                    foregroundColor: AppColors.brandGold,
                  ),
                  onPressed: () {
                    final newImg = urlController.text.trim();
                    if (newImg.isEmpty) {
                      setDialogState(() => localError = "Please enter an image path or URL.");
                      return;
                    }

                    DynamicContentService.instance.setCategoryImage(col['handle']!, newImg);
                    Navigator.of(ctx).pop();
                    setState(() {});
                  },
                  child: const Text('Apply Image', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandDarkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.brandDarkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.brandGold, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: AppColors.brandGold, size: 22),
            SizedBox(width: 8),
            Text(
              "ADMIN CONTROL CENTER",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.brandGold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.brandGold,
          labelColor: AppColors.brandGold,
          unselectedLabelColor: AppColors.brandCream.withValues(alpha: 0.6),
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined, size: 20), text: "Analytics"),
            Tab(icon: Icon(Icons.view_carousel_outlined, size: 20), text: "Banners CMS"),
            Tab(icon: Icon(Icons.grid_view_rounded, size: 20), text: "Collections CMS"),
            Tab(icon: Icon(Icons.tune_rounded, size: 20), text: "Settings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsTab(),
          _buildBannersTab(),
          _buildCollectionsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  // --- 1. Analytics & Sales Tab ---
  Widget _buildAnalyticsTab() {
    return AnimatedBuilder(
      animation: AppAnalyticsService.instance,
      builder: (context, _) {
        final totalOrders = AppAnalyticsService.instance.totalAppOrders;
        final totalRevenue = AppAnalyticsService.instance.totalRevenue;
        final aov = AppAnalyticsService.instance.averageOrderValue;
        final ordersLog = AppAnalyticsService.instance.ordersLog;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF144D32), AppColors.brandDarkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.5), width: 1.2),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: AppColors.brandGold, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Live App Attribution Tracking",
                          style: TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Every checkout generated via the mobile app is automatically tagged in Shopify as 'Fresh Yard Mobile App'.",
                      style: TextStyle(color: AppColors.brandCream, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Metric Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: "App Orders",
                      value: "$totalOrders",
                      subtitle: "Orders from App",
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: "App Revenue",
                      value: "LE ${totalRevenue.toStringAsFixed(0)}",
                      subtitle: "Total Sales",
                      icon: Icons.attach_money_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                title: "Average Order Value (AOV)",
                value: "LE ${aov.toStringAsFixed(2)}",
                subtitle: "Per App Customer Checkout",
                icon: Icons.trending_up_rounded,
              ),
              const SizedBox(height: 24),

              // Recent App Orders Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent App Checkouts",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandGold,
                    ),
                  ),
                  if (ordersLog.isNotEmpty)
                    TextButton(
                      onPressed: () => AppAnalyticsService.instance.resetStats(),
                      child: const Text("Clear Log", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (ordersLog.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.2)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, color: AppColors.brandGold, size: 44),
                      SizedBox(height: 10),
                      Text(
                        "No orders logged yet",
                        style: TextStyle(color: AppColors.brandGold, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Checkouts initiated through the app will appear here live.",
                        style: TextStyle(color: AppColors.brandCream, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ordersLog.length,
                  itemBuilder: (context, index) {
                    final record = ordersLog[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.brandDarkGreen.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.shopping_cart, color: AppColors.brandDarkGreen, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.id,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brandDarkGreen,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "${record.itemsCount} items • ${record.timestamp.substring(0, 10)}",
                                    style: TextStyle(color: Colors.grey[700], fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            "LE ${record.totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: AppColors.brandDarkGreen,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.4), width: 1.1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[800], fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Icon(icon, color: AppColors.brandDarkGreen, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.brandDarkGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // --- 2. Banners CMS Tab ---
  Widget _buildBannersTab() {
    return AnimatedBuilder(
      animation: DynamicContentService.instance,
      builder: (context, _) {
        final banners = DynamicContentService.instance.banners;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Home Promo Banners",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandGold,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandGold,
                      foregroundColor: AppColors.brandDarkGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () => _showBannerDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Banner", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.4), width: 1.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Thumbnail Header
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                              child: SizedBox(
                                height: 110,
                                width: double.infinity,
                                child: _buildImagePreview(banner.imagePath, width: double.infinity, height: 110, radius: 0),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.brandDarkGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  banner.tag,
                                  style: const TextStyle(color: AppColors.brandGold, fontSize: 9.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      banner.title,
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brandDarkGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      banner.subtitle,
                                      style: TextStyle(color: Colors.grey[700], fontSize: 11.5),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.brandDarkGreen),
                                onPressed: () => _showBannerDialog(bannerToEdit: banner),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => DynamicContentService.instance.deleteBanner(banner.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 3. Collections Images CMS Tab ---
  Widget _buildCollectionsTab() {
    return AnimatedBuilder(
      animation: DynamicContentService.instance,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Collection & Category Images",
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandGold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Customize the photos of all 9 collections in both the Home circles and the Collections view.",
                style: TextStyle(color: AppColors.brandCream, fontSize: 12),
              ),
              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _shopifyCollections.length,
                itemBuilder: (context, index) {
                  final col = _shopifyCollections[index];
                  final currentImg = DynamicContentService.instance.getCategoryImage(col['handle']!, col['defaultAsset']!);
                  final isOverridden = DynamicContentService.instance.categoryImages.containsKey(col['handle']!);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOverridden ? AppColors.brandGold : Colors.grey[300]!,
                        width: isOverridden ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Circle Thumbnail
                        _buildImagePreview(currentImg, width: 54, height: 54, radius: 27),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    col['title']!,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.brandDarkGreen,
                                    ),
                                  ),
                                  if (isOverridden) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.brandGold,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "CUSTOM",
                                        style: TextStyle(
                                          color: AppColors.brandDarkGreen,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Handle: ${col['handle']}",
                                style: TextStyle(color: Colors.grey[600], fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandDarkGreen,
                            foregroundColor: AppColors.brandGold,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _showChangeCategoryImageDialog(col),
                          child: const Text("Change", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 4. Settings & Reset Tab ---
  Widget _buildSettingsTab() {
    final pinController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Admin Preferences & Security",
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.brandGold,
            ),
          ),
          const SizedBox(height: 16),

          // Change Admin PIN Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Change Admin Access PIN",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandDarkGreen, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Current default PIN is 2026. You can change it below.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "New 4-digit PIN",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandDarkGreen,
                      foregroundColor: AppColors.brandGold,
                    ),
                    onPressed: () {
                      final p = pinController.text.trim();
                      if (p.length >= 4) {
                        AdminService.instance.changePin(p);
                        pinController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.brandDarkGreen,
                            content: Text("Admin PIN updated successfully!", style: TextStyle(color: AppColors.brandGold)),
                          ),
                        );
                      }
                    },
                    child: const Text("Save New PIN", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Push Notifications Testing Console
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active_rounded, color: AppColors.brandDarkGreen, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Push Notifications Console",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandDarkGreen, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "Test system push notifications directly on this device with sound, badge, and banner.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 14),

                // Presets
                const Text(
                  "Quick Test Presets:",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandDarkGreen),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.nature_people_rounded, size: 16, color: AppColors.brandDarkGreen),
                      label: const Text("Organic Offer", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.brandGold.withValues(alpha: 0.2),
                      onPressed: () async {
                        final success = await NotificationService.instance.showLocalNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: "🍓 Special Fresh Harvest Discount!",
                          body: "Get 20% off all fresh organic berries & tropical fruits today. Code: FRESH20",
                          channel: AppNotificationChannel.promos,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: success ? AppColors.brandDarkGreen : Colors.redAccent,
                            content: Text(
                              success ? "✅ Organic Offer notification fired [Channel: Promos]!" : "❌ Notification permission denied",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ));
                        }
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.brandDarkGreen),
                      label: const Text("Order Dispatch", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.brandGold.withValues(alpha: 0.2),
                      onPressed: () async {
                        final success = await NotificationService.instance.showLocalNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: "🚚 Order #1042 Dispatched!",
                          body: "Your fresh organic basket is on its way with our express courier. ETA: 25 mins.",
                          channel: AppNotificationChannel.orders,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: success ? AppColors.brandDarkGreen : Colors.redAccent,
                            content: Text(
                              success ? "✅ Order Dispatch notification fired [Channel: Orders]!" : "❌ Notification permission denied",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ));
                        }
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.card_giftcard_rounded, size: 16, color: AppColors.brandDarkGreen),
                      label: const Text("VIP Reward", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.brandGold.withValues(alpha: 0.2),
                      onPressed: () async {
                        final success = await NotificationService.instance.showLocalNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: "🎁 Fresh Yard VIP Perk",
                          body: "You earned 100 organic loyalty points on your last order!",
                          channel: AppNotificationChannel.vip,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: success ? AppColors.brandDarkGreen : Colors.redAccent,
                            content: Text(
                              success ? "✅ VIP Reward notification fired [Channel: VIP]!" : "❌ Notification permission denied",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ));
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.local_offer_rounded, color: AppColors.brandDarkGreen, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "Custom Product Offer Push Creator:",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.brandDarkGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final selected = await Navigator.push<Product>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminProductSearchPage(initialProducts: _availableProducts),
                      ),
                    );
                    if (selected != null) {
                      setState(() {
                        _selectedProduct = selected;
                        _autoGenerateOfferText();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        _selectedProduct?.imageUrl != null && _selectedProduct!.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(_selectedProduct!.imageUrl!, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40, color: Colors.grey)),
                              )
                            : Container(width: 40, height: 40, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Target Product', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(
                                _selectedProduct?.title ?? 'Select a product...',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.brandDarkGreen),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.search_rounded, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _customDiscountController,
                  onChanged: (_) => _autoGenerateOfferText(),
                  decoration: const InputDecoration(
                    labelText: 'Discount Offer / Promo Code',
                    hintText: 'e.g. 30% OFF or Code: MANGO30',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _customOfferNotificationTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Notification Banner Title',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _customOfferNotificationBodyController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notification Message Body',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandDarkGreen,
                      foregroundColor: AppColors.brandGold,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      "Send Product Push (Deep Links to Product Page)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    onPressed: () async {
                      if (_selectedProduct == null) return;
                      final title = _customOfferNotificationTitleController.text.trim();
                      final body = _customOfferNotificationBodyController.text.trim();

                      if (title.isEmpty || body.isEmpty) return;

                      final success = await NotificationService.instance.showLocalNotification(
                        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        title: title,
                        body: body,
                        payload: 'product_id:${_selectedProduct!.id}',
                        channel: AppNotificationChannel.promos,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: success ? AppColors.brandDarkGreen : Colors.redAccent,
                          content: Text(
                            success ? "✅ Product Push sent for '${_selectedProduct!.title}'!" : "❌ Notification permission denied",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ));
                      }
                    },
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "FCM Device Token:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.brandDarkGreen),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brandDarkGreen,
                        side: const BorderSide(color: AppColors.brandDarkGreen),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () async {
                        final token = await NotificationService.instance.getFcmToken() ?? 
                                      await NotificationService.instance.getStoredFcmToken();
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Device FCM Token"),
                              content: SelectableText(token ?? "No FCM Token generated yet (requires real device or connected FCM)."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.key_rounded, size: 14),
                      label: const Text("View FCM Token", style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Factory Reset Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Reset All Custom Media",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Restore all original 8K bespoke produce banners and collection photos to original factory defaults.",
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      DynamicContentService.instance.resetToDefaults();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.brandDarkGreen,
                          content: Text("Restored all factory defaults!", style: TextStyle(color: AppColors.brandGold)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.restore, color: Colors.white),
                    label: const Text("Restore Factory Presets", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

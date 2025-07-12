import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/screen_export.dart';

class OnSaleScreen extends StatefulWidget {
  const OnSaleScreen({super.key});

  @override
  State<OnSaleScreen> createState() => _OnSaleScreenState();
}

class _OnSaleScreenState extends State<OnSaleScreen> {
  List<ProductModel> _saleProducts = [];
  String _sortBy = "discount"; // "discount", "price_low", "price_high"
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaleProducts();
  }

  void _loadSaleProducts() {
    setState(() {
      _isLoading = true;
    });
    
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // 合并所有商品
    final allProducts = <ProductModel>[
      ...productProvider.popularProducts,
      ...productProvider.flashSaleProducts,
      ...productProvider.bestSellersProducts,
      ...productProvider.kidsProductsList,
    ];

    // 筛选有折扣的商品
    _saleProducts = allProducts
        .where((product) => product.priceAfetDiscount != null)
        .toSet() // 去重
        .toList();

    _sortProducts();
    
    setState(() {
      _isLoading = false;
    });
  }

  void _sortProducts() {
    switch (_sortBy) {
      case "discount":
        _saleProducts.sort((a, b) => 
            (b.dicountpercent ?? 0).compareTo(a.dicountpercent ?? 0));
        break;
      case "price_low":
        _saleProducts.sort((a, b) => 
            (a.priceAfetDiscount ?? a.price).compareTo(b.priceAfetDiscount ?? b.price));
        break;
      case "price_high":
        _saleProducts.sort((a, b) => 
            (b.priceAfetDiscount ?? b.price).compareTo(a.priceAfetDiscount ?? a.price));
        break;
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "排序方式",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            _buildSortOption("折扣最大", "discount", Icons.local_offer),
            _buildSortOption("价格从低到高", "price_low", Icons.arrow_upward),
            _buildSortOption("价格从高到低", "price_high", Icons.arrow_downward),
            SizedBox(height: MediaQuery.of(context).padding.bottom + defaultPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: isSelected ? Border.all(color: primaryColor.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? primaryColor : Theme.of(context).iconTheme.color,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryColor : null,
            fontWeight: isSelected ? FontWeight.w600 : null,
          ),
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: primaryColor, size: 20)
            : null,
        onTap: () {
          setState(() {
            _sortBy = value;
            _sortProducts();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(defaultPadding),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.15),
            primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "限时促销",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "发现 ${_saleProducts.length} 件超值商品",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 4),
                Text(
                  "最高享受80%折扣",
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
          Text(
            "暂无促销商品",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          Text(
            "敬请期待更多优惠活动",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
          ElevatedButton.icon(
            onPressed: _loadSaleProducts,
            icon: const Icon(Icons.refresh),
            label: const Text("刷新页面"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: defaultPadding),
          Text("正在加载促销商品..."),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("促销专区"),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: _loadSaleProducts,
                icon: const Icon(Icons.refresh),
                tooltip: "刷新",
              ),
              IconButton(
                onPressed: _showSortOptions,
                icon: SvgPicture.asset(
                  "assets/icons/Filter.svg",
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
                tooltip: "排序",
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              _loadSaleProducts();
            },
            color: primaryColor,
            child: Column(
              children: [
                // 头部信息
                _buildHeader(),
                
                // 主要内容区域
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _saleProducts.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                defaultPadding, 
                                0, 
                                defaultPadding, 
                                defaultPadding
                              ),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: defaultPadding,
                                mainAxisSpacing: defaultPadding,
                              ),
                              itemCount: _saleProducts.length,
                              itemBuilder: (context, index) {
                                final product = _saleProducts[index];
                                return Hero(
                                  tag: 'product_${product.id}_sale_$index',
                                  child: ProductCard(
                                    product: product,
                                    press: () {
                                      Navigator.pushNamed(
                                        context,
                                        productDetailsScreenRoute,
                                        arguments: product,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

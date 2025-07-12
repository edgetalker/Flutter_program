import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';
import 'components/search_form.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<ProductModel> _searchResults = [];
  final List<String> _searchHistory = [
    "Nike Air Max",
    "iPhone 14",
    "Samsung Galaxy",
    "MacBook Pro",
    "Wireless Headphones"
  ];
  final List<String> _popularSearches = [
    "运动鞋",
    "连衣裙", 
    "手机",
    "笔记本电脑",
    "化妆品",
    "包包",
    "手表",
    "耳机"
  ];
  
  bool _isSearching = false;
  bool _showResults = false;

  // 合并所有商品用于搜索
  List<ProductModel> get _allProducts => [
    ...demoPopularProducts,
    ...demoFlashSaleProducts, 
    ...demoBestSellersProducts,
    ...kidsProducts,
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _showResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // 模拟搜索延迟
    Future.delayed(const Duration(milliseconds: 500), () {
      final results = _allProducts.where((product) {
        final titleLower = product.title.toLowerCase();
        final brandLower = product.brandName.toLowerCase();
        final queryLower = query.toLowerCase();
        
        return titleLower.contains(queryLower) || 
               brandLower.contains(queryLower);
      }).toList();

      setState(() {
        _searchResults = results;
        _showResults = true;
        _isSearching = false;
      });

      // 添加到搜索历史
      if (!_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showResults = false;
      _searchResults = [];
    });
  }

  void _selectHistoryItem(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  void _removeHistoryItem(String query) {
    setState(() {
      _searchHistory.remove(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("搜索商品"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: SearchForm(
                    controller: _searchController,
                    focusNode: _focusNode,
                    autofocus: true,
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        _performSearch(value);
                      } else {
                        _clearSearch();
                      }
                    },
                    onFieldSubmitted: (value) {
                      if (value != null && value.isNotEmpty) {
                        _performSearch(value);
                      }
                    },
                    onTabFilter: () {
                      // 筛选功能
                      _showFilterBottomSheet();
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty) ...[
                  const SizedBox(width: defaultPadding / 2),
                  IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: _showResults ? _buildSearchResults() : _buildSearchHome(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索历史
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "搜索历史",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchHistory.clear();
                    });
                  },
                  child: const Text("清空"),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.map((item) {
                return GestureDetector(
                  onTap: () => _selectHistoryItem(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding / 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item),
                        const SizedBox(width: defaultPadding / 2),
                        GestureDetector(
                          onTap: () => _removeHistoryItem(item),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: defaultPadding * 2),
          ],
          
          // 热门搜索
          Text(
            "热门搜索",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: defaultPadding / 2),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((item) {
              return GestureDetector(
                onTap: () => _selectHistoryItem(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: defaultPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/icons/Search.svg",
              height: 64,
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!.withValues(alpha: 0.3),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              "未找到相关商品",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              "试试其他关键词吧",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 搜索结果头部
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "找到 ${_searchResults.length} 个结果",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              IconButton(
                onPressed: _showFilterBottomSheet,
                icon: SvgPicture.asset(
                  "assets/icons/Filter.svg",
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 商品网格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.64,
              crossAxisSpacing: defaultPadding / 2,
              mainAxisSpacing: defaultPadding,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return ProductCard(
                product: product,
                press: () {
                  Navigator.pushNamed(
                    context,
                    productDetailsScreenRoute,
                    arguments: product,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "筛选",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            
            // 价格筛选
            Text(
              "价格区间",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: defaultPadding / 2),
            Wrap(
              spacing: 8,
              children: [
                "全部", "0-100", "100-500", "500-1000", "1000+"
              ].map((range) {
                return FilterChip(
                  label: Text(range),
                  selected: false,
                  onSelected: (selected) {
                    // 实现价格筛选逻辑
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: defaultPadding),
            
            // 品牌筛选
            Text(
              "品牌",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: defaultPadding / 2),
            Wrap(
              spacing: 8,
              children: [
                "全部", "Lipsy London", "Nike", "Samsung", "Apple"
              ].map((brand) {
                return FilterChip(
                  label: Text(brand),
                  selected: false,
                  onSelected: (selected) {
                    // 实现品牌筛选逻辑
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: defaultPadding * 2),
            
            // 底部按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 重置筛选
                      Navigator.pop(context);
                    },
                    child: const Text("重置"),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 应用筛选
                      Navigator.pop(context);
                    },
                    child: const Text("确定"),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

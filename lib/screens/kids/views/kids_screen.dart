import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/screen_export.dart';

import '../../../constants.dart';

class KidsScreen extends StatefulWidget {
  const KidsScreen({super.key});

  @override
  State<KidsScreen> createState() => _KidsScreenState();
}

class _KidsScreenState extends State<KidsScreen> {
  String _selectedCategory = "全部";
  final List<String> _categories = ["全部", "男童", "女童", "婴儿", "玩具"];

  List<ProductModel> _getFilteredProducts(List<ProductModel> kidsProducts) {
    // 基于选中的分类筛选商品
    switch (_selectedCategory) {
      case "男童":
        return kidsProducts.where((p) => p.title.toLowerCase().contains('boy') || 
               p.title.contains('男')).toList();
      case "女童":
        return kidsProducts.where((p) => p.title.toLowerCase().contains('girl') || 
               p.title.contains('女') || p.title.contains('dress')).toList();
      case "婴儿":
        return kidsProducts.where((p) => p.title.toLowerCase().contains('baby') || 
               p.title.contains('婴')).toList();
      case "玩具":
        return kidsProducts.where((p) => p.title.toLowerCase().contains('toy') || 
               p.title.contains('玩具')).toList();
      default:
        return kidsProducts;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final filteredProducts = _getFilteredProducts(productProvider.kidsProductsList);
        
        return Scaffold(
          appBar: AppBar(
            title: const Text("儿童专区"),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: Column(
            children: [
              // 儿童专区头部
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(defaultPadding),
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B9D).withOpacity(0.1),
                      const Color(0xFF4ECDC4).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  border: Border.all(color: const Color(0xFFFF6B9D).withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.child_care,
                          color: Color(0xFFFF6B9D),
                          size: 24,
                        ),
                        const SizedBox(width: defaultPadding / 2),
                        Text(
                          "儿童专区",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFFF6B9D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      "为您的小宝贝精选 ${productProvider.kidsProductsList.length} 件优质商品",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // 分类选择
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == _categories.length - 1 ? 0 : defaultPadding / 2,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding,
                            vertical: defaultPadding / 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFFFF6B9D) 
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.transparent 
                                  : Theme.of(context).dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected 
                                  ? Colors.white 
                                  : Theme.of(context).textTheme.bodyLarge!.color,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 商品网格
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.toys,
                              size: 64,
                              color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                            ),
                            const SizedBox(height: defaultPadding),
                            Text(
                              "该分类暂无商品",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: defaultPadding / 2),
                            Text(
                              "试试其他分类吧",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(defaultPadding),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.64,
                          crossAxisSpacing: defaultPadding / 2,
                          mainAxisSpacing: defaultPadding,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
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
          ),
        );
      },
    );
  }
}

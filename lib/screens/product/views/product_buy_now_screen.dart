import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:shop/screens/product/views/size_guide_screen.dart';
import 'package:shop/utils/message_utils.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
import 'components/selected_colors.dart';
import 'components/selected_size.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  const ProductBuyNowScreen({super.key, this.product});

  final ProductModel? product;

  @override
  _ProductBuyNowScreenState createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  int _quantity = 1;
  String? _selectedSize;
  String? _selectedColor;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;

  // 颜色选项
  final List<Color> _availableColors = const [
    Color(0xFFEA6262),
    Color(0xFFB1CC63),
    Color(0xFFFFBF5F),
    Color(0xFF9FE1DD),
    Color(0xFFC482DB),
  ];

  // 尺寸选项
  final List<String> _availableSizes = const ["S", "M", "L", "XL", "XXL"];

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _quantity = product.minOrder;
      // 设置默认选择
      if (_availableSizes.isNotEmpty) {
        _selectedSize = _availableSizes[_selectedSizeIndex];
      }
      if (_availableColors.isNotEmpty) {
        _selectedColor = _getColorName(_availableColors[_selectedColorIndex]);
      }
    }
  }

  // 获取颜色名称
  String _getColorName(Color color) {
    if (color == const Color(0xFFEA6262)) return "红色";
    if (color == const Color(0xFFB1CC63)) return "绿色";
    if (color == const Color(0xFFFFBF5F)) return "黄色";
    if (color == const Color(0xFF9FE1DD)) return "青色";
    if (color == const Color(0xFFC482DB)) return "紫色";
    return "未知";
  }

  @override
  Widget build(BuildContext context) {
    // 使用传入的产品数据，如果没有则使用默认值
    final productData = widget.product ?? ProductModel(
      id: "default",
      image: productDemoImg1,
      title: "无袖荷叶边上衣", 
      brandName: "时尚女装",
      price: 140.0,
      stock: 10,
    );

    final currentPrice = productData.priceAfetDiscount ?? productData.price;
    final totalPrice = currentPrice * _quantity;

    return Scaffold(
      bottomNavigationBar: CartButton(
        price: totalPrice,
        title: "添加到购物车",
        subTitle: "总价",
        press: () => _addToCart(context, productData),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2, vertical: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Text(
                  productData.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: NetworkImageWithLoader(productData.image),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: UnitPrice(
                            price: productData.price,
                            priceAfterDiscount: productData.priceAfetDiscount,
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: _quantity,
                          onIncrement: () {
                            if (_quantity < productData.maxOrder && _quantity < productData.stock) {
                              setState(() {
                                _quantity++;
                              });
                            }
                          },
                          onDecrement: () {
                            if (_quantity > productData.minOrder) {
                              setState(() {
                                _quantity--;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
                SliverToBoxAdapter(
                  child: SelectedColors(
                    colors: _availableColors,
                    selectedColorIndex: _selectedColorIndex,
                    press: (index) {
                      setState(() {
                        _selectedColorIndex = index;
                        _selectedColor = _getColorName(_availableColors[index]);
                      });
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: SelectedSize(
                    sizes: _availableSizes,
                    selectedIndex: _selectedSizeIndex,
                    press: (index) {
                      setState(() {
                        _selectedSizeIndex = index;
                        _selectedSize = _availableSizes[index];
                      });
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "尺寸指南",
                    svgSrc: "assets/icons/Sizeguid.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const SizeGuideScreen(),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          "库存信息",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text("库存状态: ${productData.stockStatusText}"),
                        Text("最小起订量: ${productData.minOrder}件"),
                        Text("最大购买量: ${productData.maxOrder}件"),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "附近门店",
                    svgSrc: "assets/icons/Stores.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.92,
                        child: const LocationPermissonStoreAvailabilityScreen(),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: defaultPadding))
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, ProductModel product) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // 显示加载指示器
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await cartProvider.addToCart(
        product: product,
        quantity: _quantity,
        selectedSize: _selectedSize,
        selectedColor: _selectedColor,
      );

      Navigator.pop(context); // 关闭加载指示器

      if (success) {
        // 显示成功页面
        customModalBottomSheet(
          context,
          isDismissible: false,
          child: const AddedToCartMessageScreen(),
        );
      } else {
        MessageUtils.showError(context, "添加到购物车失败");
      }
    } catch (e) {
      Navigator.pop(context); // 关闭加载指示器
      MessageUtils.showError(context, "添加到购物车时发生错误: $e");
    }
  }
}

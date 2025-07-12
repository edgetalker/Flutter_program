import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../network_image_with_loader.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/message_utils.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.press,
  });
  
  final ProductModel product;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // 直接使用传入的product，因为getProductById是异步的
        final currentProduct = product;
        
        return OutlinedButton(
          onPressed: currentProduct.isInStock ? press : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(140, 220),
            maximumSize: const Size(140, 220),
            padding: const EdgeInsets.all(8),
            backgroundColor: currentProduct.isInStock 
                ? null 
                : Colors.grey.withOpacity(0.1),
          ),
          child: Column(
            children: [
              // 图片区域
              AspectRatio(
                aspectRatio: 1.15,
                child: Stack(
                  children: [
                    NetworkImageWithLoader(
                      currentProduct.image, 
                      radius: defaultBorderRadious,
                    ),
                    
                    // 折扣标签
                    if (currentProduct.dicountpercent != null && currentProduct.isInStock)
                      Positioned(
                        right: defaultPadding / 2,
                        top: defaultPadding / 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding / 2),
                          height: 16,
                          decoration: const BoxDecoration(
                            color: errorColor,
                            borderRadius: BorderRadius.all(
                                Radius.circular(defaultBorderRadious)),
                          ),
                          child: Text(
                            "${currentProduct.dicountpercent}% off",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    
                    // 库存状态标签
                    Positioned(
                      left: defaultPadding / 2,
                      top: defaultPadding / 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding / 2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStockStatusColor(currentProduct),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(defaultBorderRadious),
                          ),
                        ),
                        child: Text(
                          _getStockStatusText(currentProduct),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    // 购物车按钮 - 紧贴图片右下角
                    if (currentProduct.isInStock)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _quickAddToCart(context, currentProduct),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    
                    // 缺货遮罩
                    if (!currentProduct.isInStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(defaultBorderRadious),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '缺货',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // 商品信息区域
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding / 2, vertical: defaultPadding / 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentProduct.brandName.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Expanded(
                        child: Text(
                          currentProduct.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontSize: 12),
                        ),
                      ),
                      
                      // 低库存提示
                      if (currentProduct.isInStock && currentProduct.isLowStock)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            "仅剩${currentProduct.stock}件",
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      
                      // 价格信息
                      currentProduct.priceAfetDiscount != null
                          ? Wrap(
                              children: [
                                Text(
                                    "\$${currentProduct.priceAfetDiscount}",
                                    style: TextStyle(
                                      color: currentProduct.isInStock 
                                        ? const Color(0xFF31B0D8) 
                                        : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    )),
                                const SizedBox(width: 4),
                                Text(
                                  "\$${currentProduct.price}",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color!
                                        .withOpacity(0.64),
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "\$${currentProduct.price}",
                              style: TextStyle(
                                color: currentProduct.isInStock
                                    ? const Color(0xFF31B0D8)
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 获取库存状态颜色
  Color _getStockStatusColor(ProductModel product) {
    if (!product.isInStock) {
      return Colors.grey;
    } else if (product.isLowStock) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // 获取库存状态文本
  String _getStockStatusText(ProductModel product) {
    if (!product.isInStock) {
      return '缺货';
    } else if (product.isLowStock) {
      return '库存不足';
    } else {
      return '有货';
    }
  }

  // 快速添加到购物车
  Future<void> _quickAddToCart(BuildContext context, ProductModel product) async {
    if (!product.isInStock) {
      MessageUtils.showError(context, '商品暂时缺货');
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    try {
      final success = await cartProvider.addToCart(product: product, quantity: 1);
      if (success) {
        MessageUtils.showSuccess(context, '已添加到购物车');
      } else {
        MessageUtils.showError(context, '添加失败，请重试');
      }
    } catch (e) {
      MessageUtils.showError(context, '添加失败：${e.toString()}');
    }
  }
}

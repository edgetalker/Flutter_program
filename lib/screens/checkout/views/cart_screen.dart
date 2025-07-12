import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/utils/message_utils.dart';
// 购物车
class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.onGoShopping});// 构造函数

  final VoidCallback? onGoShopping;// 点击事件

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          body: cartProvider.isEmpty ? _buildEmptyCart(context) : _buildCartContent(context, cartProvider),
          bottomNavigationBar: cartProvider.isEmpty 
              ? null 
              : CartButton(
                  price: cartProvider.finalTotalPrice,
                  title: "去结算",
                  subTitle: "总计",
                  press: () => _handleCheckout(context, cartProvider),
                ),
        );
      },
    );
  }
// 空购物车
  Widget _buildEmptyCart(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/icons/Bag.svg",
              height: 80,
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!.withOpacity(0.3),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              "购物车是空的",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              "快去添加一些喜欢的商品吧",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: defaultPadding * 2),
            ElevatedButton(
              onPressed: onGoShopping,
              child: const Text("去购物"),
            ),
          ],
        ),
      ),
    );
  }
// 购物车内容
  Widget _buildCartContent(BuildContext context, CartProvider cartProvider) {
    return SafeArea(
      child: Column(
        children: [
          // 购物车标题栏
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "购物车 (${cartProvider.itemCount})",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (cartProvider.items.isNotEmpty)
                  TextButton(
                    onPressed: () => _showClearCartDialog(context, cartProvider),
                    child: const Text("清空"),
                  ),
              ],
            ),
          ),
          // 购物车商品列表
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              itemCount: cartProvider.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: defaultPadding),
              itemBuilder: (context, index) {
                final cartItem = cartProvider.items[index];
                return _buildCartItem(context, cartItem, cartProvider);
              },
            ),
          ),
          // 价格汇总
          _buildPriceSummary(context, cartProvider),
        ],
      ),
    );
  }
// 购物车商品
  Widget _buildCartItem(BuildContext context, cartItem, CartProvider cartProvider) {
    final product = cartItem.product;
    
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        boxShadow: [// 阴影效果
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(defaultBorderRadious),
            child: SizedBox(
              width: 80,
              height: 80,
              child: NetworkImageWithLoader(product.image),
            ),
          ),
          
          const SizedBox(width: defaultPadding),
          
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.brandName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                
                // 规格信息
                if (cartItem.selectedSize != null || cartItem.selectedColor != null)
                  Text(
                    "${cartItem.selectedSize ?? ''} ${cartItem.selectedColor ?? ''}".trim(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // 价格和库存状态
                Row(
                  children: [
                    Text(// 价格
                      "¥${product.priceAfetDiscount ?? product.price}",
                      style: const TextStyle(
                        color: Color(0xFF31B0D8),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!product.isInStock)
                      Container(// 容器
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "缺货",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      )
                    else if (product.isLowStock)
                      Container(// 容器
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "仅剩${product.stock}件",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // 数量控制和删除按钮
          Column(
            children: [
              // 删除按钮
              IconButton(
                onPressed: () => _removeItem(context, cartProvider, cartItem.id),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              
              const SizedBox(height: 8),
              
              // 数量控制
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: cartItem.canDecreaseQuantity()
                          ? () => _updateQuantity(context, cartProvider, cartItem.id, cartItem.quantity - 1)
                          : null,
                    ),
                    Container(// 数量显示
                      constraints: const BoxConstraints(minWidth: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        '${cartItem.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: cartItem.canIncreaseQuantity()
                          ? () => _updateQuantity(context, cartProvider, cartItem.id, cartItem.quantity + 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
// 数量按钮
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onPressed != null ? null : Colors.grey.shade100,
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed != null ? null : Colors.grey,
        ),
      ),
    );
  }
// 价格汇总
  Widget _buildPriceSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey.shade50
            : const Color(0xFF1C1C1E),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          _buildPriceRow(context, "商品总价", cartProvider.totalPrice),
          const SizedBox(height: 8),
          _buildPriceRow(context, "运费", cartProvider.shippingFee),
          if (cartProvider.shippingFee > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "满¥200免运费",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                ),
              ),
            ),
          const Divider(),
          _buildPriceRow(
            context, 
            "总计", 
            cartProvider.finalTotalPrice,
            isTotal: true,
          ),
        ],
      ),
    );
  }
// 价格行
  Widget _buildPriceRow(BuildContext context, String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal 
              ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          "¥${amount.toStringAsFixed(2)}",
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF31B0D8),
                )
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
// 更新数量
  void _updateQuantity(BuildContext context, CartProvider cartProvider, String cartItemId, int newQuantity) {
    cartProvider.updateQuantity(cartItemId, newQuantity).then((success) {
      if (!success) {
        MessageUtils.showError(context, "更新数量失败");
      }
    });
  }
// 移除商品
  void _removeItem(BuildContext context, CartProvider cartProvider, String cartItemId) {
    cartProvider.removeFromCart(cartItemId);
    MessageUtils.showSuccess(context, "商品已移除");
  }
// 清空购物车
  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("清空购物车"),
        content: const Text("确定要清空购物车吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cartProvider.clearCart();
              MessageUtils.showSuccess(context, "购物车已清空");
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }
// 结算
  void _handleCheckout(BuildContext context, CartProvider cartProvider) {
    _showCheckoutDialog(context, cartProvider);
  }
// 结算对话框
  void _showCheckoutDialog(BuildContext context, CartProvider cartProvider) {
    final TextEditingController addressController = TextEditingController(
      text: "北京市朝阳区xxx街道xxx号", // 默认地址
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("确认订单"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "商品总价: ¥${cartProvider.totalPrice.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "运费: ¥${cartProvider.shippingFee.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(),
            Text(
              "总计: ¥${cartProvider.finalTotalPrice.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text("收货地址:"),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                hintText: "请输入收货地址",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          ElevatedButton(
            onPressed: () => _processCheckout(context, cartProvider, addressController.text),
            child: const Text("确认下单"),
          ),
        ],
      ),
    );
  }
// 处理结算   
  void _processCheckout(BuildContext context, CartProvider cartProvider, String shippingAddress) async {
    Navigator.pop(context); // 关闭确认对话框

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("正在创建订单..."),
          ],
        ),
      ),
    );

    try {
      // 1. 获取购物车数据副本
      final cartItems = cartProvider.getCartItemsForOrder();
      final shippingFee = cartProvider.shippingFee;

      // 2. 执行结算（扣减库存并清空购物车）
      final checkoutResult = await cartProvider.checkout(shippingAddress: shippingAddress);
      
      if (checkoutResult == null) {
        Navigator.pop(context); // 关闭加载对话框
        MessageUtils.showError(context, "结算失败，请检查商品库存");
        return;
      }

      // 3. 创建订单
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final order = await orderProvider.createOrderFromCart(
        cartItems,
        shippingFee,
        shippingAddress,
      );

      Navigator.pop(context); // 关闭加载对话框

      if (order != null) {
        // 4. 显示成功消息并跳转到订单页面
        MessageUtils.showSuccess(context, "订单创建成功！订单号：${order.orderNumber}");
        
        // 可选：跳转到订单详情页面
        _showOrderSuccessDialog(context, order.orderNumber);
      } else {
        MessageUtils.showError(context, "订单创建失败");
      }
    } catch (e) {
      Navigator.pop(context); // 关闭加载对话框
      MessageUtils.showError(context, "结算过程中发生错误：$e");
    }
  }
// 订单成功对话框
  void _showOrderSuccessDialog(BuildContext context, String orderNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("订单创建成功"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text("订单号：$orderNumber"),
            const SizedBox(height: 8),
            const Text("您可以在\"我的订单\"中查看订单状态"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("继续购物"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 这里可以跳转到订单页面
              // Navigator.pushNamed(context, ordersScreenRoute);
            },
            child: const Text("查看订单"),
          ),
        ],
      ),
    );
  }
}

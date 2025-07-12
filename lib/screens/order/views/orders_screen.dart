import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import '../../../providers/order_provider.dart';
import '../../../models/order_model.dart';
import '../../../components/network_image_with_loader.dart';


// 订单
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // 初始化时刷新订单数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().refreshOrders();
    });
  }
// 销毁
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(// 应用栏
        title: const Text("我的订单"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) => setState(() {}),
          tabs: const [
            Tab(text: "全部"),
            Tab(text: "处理中"),
            Tab(text: "已发货"),
            Tab(text: "已送达"),
            Tab(text: "已取消"),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.errorMessage != null) {
            return _buildErrorState(orderProvider.errorMessage!);
          }

          final filteredOrders = _getFilteredOrders(orderProvider);
          
          if (filteredOrders.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(// 刷新指示器
            onRefresh: () => orderProvider.refreshOrders(),
            child: _buildOrderList(filteredOrders, orderProvider),
          );
        },
      ),
    );
  }
// 获取过滤后的订单
  List<OrderModel> _getFilteredOrders(OrderProvider orderProvider) {
    switch (_tabController.index) {
      case 0:
        return orderProvider.orders; // 全部订单
      case 1:
        return orderProvider.getOrdersByStatus(OrderStatus.processing);
      case 2:
        return orderProvider.getOrdersByStatus(OrderStatus.shipped);
      case 3:
        return orderProvider.getOrdersByStatus(OrderStatus.delivered);
      case 4:
        return orderProvider.getOrdersByStatus(OrderStatus.cancelled);
      default:
        return orderProvider.orders;
    }
  }
// 构建错误状态
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<OrderProvider>().refreshOrders(),
            child: const Text("重试"),
          ),
        ],
      ),
    );
  }
// 构建空状态
  Widget _buildEmptyState() {
    String emptyMessage;
    switch (_tabController.index) {
      case 1:
        emptyMessage = "暂无处理中订单";
        break;
      case 2:
        emptyMessage = "暂无已发货订单";
        break;
      case 3:
        emptyMessage = "暂无已送达订单";
        break;
      case 4:
        emptyMessage = "暂无已取消订单";
        break;
      default:
        emptyMessage = "暂无订单";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/icons/Bag.svg",
            height: 80,
            colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!.withValues(alpha: 0.3),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "去购物车结算创建您的第一个订单吧！",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
// 构建订单列表
  Widget _buildOrderList(List<OrderModel> orders, OrderProvider orderProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(defaultPadding),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, orderProvider);
      },
    );
  }
// 构建订单卡片
  Widget _buildOrderCard(OrderModel order, OrderProvider orderProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单头部信息
            _buildOrderHeader(order),
            const Divider(),
            // 订单商品列表
            ...order.items.map((item) => _buildOrderItem(item)),
            const Divider(),
            // 订单总价和操作按钮
            _buildOrderFooter(order, orderProvider),
          ],
        ),
      ),
    );
  }
// 构建订单头部
  Widget _buildOrderHeader(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "订单号: ${order.orderNumber}",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${order.orderDate.year}-${order.orderDate.month.toString().padLeft(2, '0')}-${order.orderDate.day.toString().padLeft(2, '0')} ${order.orderDate.hour.toString().padLeft(2, '0')}:${order.orderDate.minute.toString().padLeft(2, '0')}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getStatusColor(order.status),
              width: 1,
            ),
          ),
          child: Text(
            order.statusText,
            style: TextStyle(
              color: _getStatusColor(order.status),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
// 构建订单项
  Widget _buildOrderItem(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 60,
              width: 60,
              child: NetworkImageWithLoader(
                item.productImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.brandName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
                if (item.selectedSize != null || item.selectedColor != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (item.selectedSize != null) "尺寸: ${item.selectedSize}",
                      if (item.selectedColor != null) "颜色: ${item.selectedColor}",
                    ].join(" | "),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 价格和数量
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "¥${(item.priceAfterDiscount ?? item.price).toStringAsFixed(2)}",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "x${item.quantity}",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
// 构建订单底部
  Widget _buildOrderFooter(OrderModel order, OrderProvider orderProvider) {
    return Column(
      children: [
        // 价格信息
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "共${order.totalQuantity}件商品",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (order.shippingFee > 0) ...[
                  Text(
                    "运费: ¥${order.shippingFee.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  "总计: ¥${order.finalTotal.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 操作按钮
        _buildOrderActions(order, orderProvider),
      ],
    );
  }
// 构建订单操作
  Widget _buildOrderActions(OrderModel order, OrderProvider orderProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 取消订单按钮
        if (order.canCancel) ...[
          Flexible(
            child: OutlinedButton(
              onPressed: () => _showCancelOrderDialog(order, orderProvider),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text("取消订单"),
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        // 确认收货按钮
        if (order.canConfirmDelivery) ...[
          Flexible(
            child: ElevatedButton(
              onPressed: () => _showConfirmDeliveryDialog(order, orderProvider),
              child: const Text("确认收货"),
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        // 再次购买按钮
        Flexible(
          child: OutlinedButton(
            onPressed: () => _showRepurchaseDialog(order),
            child: const Text("再次购买"),
          ),
        ),
      ],
    );
  }
// 获取状态颜色
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
// 显示取消订单对话框
  void _showCancelOrderDialog(OrderModel order, OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("取消订单"),
        content: Text("确定要取消订单 ${order.orderNumber} 吗？\n取消后库存将自动恢复。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await orderProvider.cancelOrder(order.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "订单已取消" : "取消订单失败"),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("确定取消", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeliveryDialog(OrderModel order, OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("确认收货"),
        content: Text("确定已收到订单 ${order.orderNumber} 的商品吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await orderProvider.confirmDelivery(order.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "确认收货成功" : "确认收货失败"),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text("确认收货"),
          ),
        ],
      ),
    );
  }

  void _showRepurchaseDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("再次购买"),
        content: const Text("此功能将在后续版本中实现，敬请期待！"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("知道了"),
          ),
        ],
      ),
    );
  }
}

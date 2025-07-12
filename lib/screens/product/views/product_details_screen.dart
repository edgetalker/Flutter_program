import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';

import 'package:shop/route/screen_export.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';
import 'product_buy_now_screen.dart';
// 商品详情页面  
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key, 
    this.isProductAvailable = true,
    this.product,
  });

  final bool isProductAvailable;
  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    // 使用传入的产品数据，如果没有则使用默认值
    final productData = product ?? ProductModel(
      id: "default",
      image: productDemoImg1,
      title: "无袖荷叶边上衣", 
      brandName: "时尚女装",
      price: 140.0,
      stock: 10,
    );

    return Scaffold(// 底部导航栏
      bottomNavigationBar: isProductAvailable
          ? CartButton(// 商品可用时
              price: productData.priceAfetDiscount ?? productData.price,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(product: productData),
                );
              },
            )
          :
          NotifyMeCard(// 商品不可用时
              isNotify: false,
              onChanged: (value) {},
            ),
      body: SafeArea(// 内容区域
        child: CustomScrollView(
          slivers: [// 列表
            SliverAppBar(// 顶部导航栏
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,// 浮动效果
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ],
            ),
            ProductImages(// 商品图片
              images: [productData.image, productData.image, productData.image],
            ),
            ProductInfo(// 商品信息
              brand: productData.brandName,
              title: productData.title,
              isAvailable: isProductAvailable,
              description:
                  "这款时尚的无袖荷叶边上衣采用优质面料制作，设计简约大方，适合多种场合穿着。精致的荷叶边设计增添女性魅力，是您衣橱中不可缺少的时尚单品。",
              rating: 4.4,
              numOfReviews: 126,
            ),
            ProductListTile(// 商品详情
              svgSrc: "assets/icons/Product.svg",
              title: "商品详情",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: _buildProductDetailsModal(context),
                );
              },
            ),
            ProductListTile(// 配送信息
              svgSrc: "assets/icons/Delivery.svg",
              title: "配送信息",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: _buildShippingInfoModal(context),
                );
              },
            ),
            ProductListTile(// 退换货
              svgSrc: "assets/icons/Return.svg",
              title: "退换货",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            const SliverToBoxAdapter(// 商品评价
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: 4.3,
                  numOfReviews: 128,
                  numOfFiveStar: 80,
                  numOfFourStar: 30,
                  numOfThreeStar: 5,
                  numOfTwoStar: 4,
                  numOfOneStar: 1,
                ),
              ),
            ),
            ProductListTile(// 商品评价
              svgSrc: "assets/icons/Chat.svg",
              title: "商品评价",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(context, productReviewsScreenRoute);
              },
            ),
            SliverPadding(// 猜你喜欢
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "猜你喜欢",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(// 猜你喜欢  
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                        left: defaultPadding,
                        right: index == 4 ? defaultPadding : 0),
                    child: ProductCard(
                      product: ProductModel(
                        id: "related_$index",
                        image: productDemoImg2,
                        title: "无袖分层府绸摆裙",
                        brandName: "时尚女装",
                        price: 24.65,
                        priceAfetDiscount: index.isEven ? 20.99 : null,
                        dicountpercent: index.isEven ? 25 : null,
                        stock: 20,
                      ),
                      press: () {},
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(// 间距
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
// 商品详情弹窗
  Widget _buildProductDetailsModal(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("商品详情"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(defaultPadding),
          children: [
            Text(
              "材质成分",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            const Text("外层：100% 棉\n内层：95% 棉，5% 弹性纤维"),
            const SizedBox(height: defaultPadding * 2),
            Text(
              "护理说明",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            const Text("• 机洗温度不超过30°C\n• 不可漂白\n• 可熨烫\n• 不可干洗"),
            const SizedBox(height: defaultPadding * 2),
            Text(
              "品牌信息",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            const Text("LIPSY LONDON 致力于为现代女性提供时尚、优质的服装。每件产品都经过精心设计和严格质量控制。"),
          ],
        ),
      ),
    );
  }
// 配送信息弹窗
  Widget _buildShippingInfoModal(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("配送信息"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(defaultPadding),
          children: [
            _buildShippingOptionCard(
              context,
              "标准配送",
              "3-5个工作日",
              "¥15",
              "满¥200免运费",
            ),
            const SizedBox(height: defaultPadding),
            _buildShippingOptionCard(
              context,
              "快速配送",
              "1-2个工作日",
              "¥25",
              "适用于紧急订单",
            ),
            const SizedBox(height: defaultPadding),
            _buildShippingOptionCard(
              context,
              "次日达",
              "次日送达",
              "¥35",
              "当日下午2点前下单",
            ),
            const SizedBox(height: defaultPadding * 2),
            Text(
              "配送说明",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            const Text(
              "• 工作日：周一至周五\n• 配送时间：9:00-18:00\n• 偏远地区可能需要额外1-2天\n• 节假日配送时间可能延长",
            ),
          ],
        ),
      ),
    );
  }
// 配送选项卡片
  Widget _buildShippingOptionCard(BuildContext context, String title, String duration, String price, String note) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

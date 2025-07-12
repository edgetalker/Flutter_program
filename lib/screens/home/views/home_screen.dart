import 'package:flutter/material.dart';
import 'package:shop/components/Banner/S/banner_s_style_1.dart';
import 'package:shop/components/Banner/S/banner_s_style_5.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';

import 'components/best_sellers.dart';
import 'components/flash_sale.dart';
import 'components/most_popular.dart';
import 'components/offer_carousel_and_categories.dart';
import 'components/popular_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [// 主页内容
            // 轮播图
            const SliverToBoxAdapter(child: OffersCarouselAndCategories()),
            // 热门商品
            const SliverToBoxAdapter(child: PopularProducts()),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(child: FlashSale()),
            ),
            // 新品上架
            SliverToBoxAdapter(
              child: Column(
                children: [
                  BannerSStyle1(
                    title: "新品\n上架",
                    subtitle: "特别优惠",
                    discountParcent: 50,
                    press: () {// 路由到onSale页面
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            // 最佳销售
            const SliverToBoxAdapter(child: BestSellers()),
            // 最受欢迎
            const SliverToBoxAdapter(child: MostPopular()),
            // 黑色星期五
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  const SizedBox(height: defaultPadding / 4),
                  BannerSStyle5(
                    title: "黑色\n星期五",
                    subtitle: "五折优惠",
                    bottomText: "精选系列".toUpperCase(),
                    press: () {// 路由到onSale页面
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            // 最受欢迎
            const SliverToBoxAdapter(child: MostPopular()),
            // 黑色星期五
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  const SizedBox(height: defaultPadding / 4),
                  BannerSStyle5(
                    title: "黑色\n星期五",
                    subtitle: "五折优惠",
                    bottomText: "精选系列".toUpperCase(),
                    press: () {// 路由到onSale页面
                      Navigator.pushNamed(context, onSaleScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

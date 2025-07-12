import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';

import 'components/wallet_balance_card.dart';
import 'components/wallet_history_card.dart';
// 钱包
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(// 应用栏
        title: const Text("钱包"),
      ),
      body: SafeArea(// 安全区域
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: CustomScrollView(
            slivers: [
              SliverPadding(//余额卡片
                padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                sliver: SliverToBoxAdapter(//
                  child: WalletBalanceCard(
                    balance: 384.90,
                    onTabChargeBalance: () {},
                  ),
                ),
              ),
              SliverPadding(// 交易历史
                padding: const EdgeInsets.only(top: defaultPadding / 2),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "交易历史",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              SliverList(// 交易历史列表
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(top: defaultPadding),
                    child: WalletHistoryCard(
                      isReturn: index == 1,
                      date: "2020年6月12日",
                      amount: 129,
                      products: [
                        ProductModel(
                          id: "wallet_demo_1",
                          image: productDemoImg1,
                          title: "Mountain Warehouse for Women",
                          brandName: "Lipsy london",
                          price: 540,
                          priceAfetDiscount: 420,
                          dicountpercent: 20,
                          stock: 10,
                        ),
                        ProductModel(
                          id: "wallet_demo_2",
                          image: productDemoImg4,
                          title: "Mountain Beta Warehouse",
                          brandName: "Lipsy london",
                          price: 800,
                          stock: 5,
                        ),
                      ],
                    ),
                  ),
                  childCount: 4,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

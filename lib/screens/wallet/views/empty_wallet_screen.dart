import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'components/wallet_balance_card.dart';

class EmptyWalletScreen extends StatelessWidget {
  const EmptyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("钱包"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: WalletBalanceCard(
                balance: 384.90,
                onTabChargeBalance: () {},
              ),
            ),
            const Spacer(flex: 2),
            Image.asset(
              Theme.of(context).brightness == Brightness.light
                  ? "assets/Illustration/EmptyState_lightTheme.png"
                  : "assets/Illustration/EmptyState_darkTheme.png",
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            const Spacer(),
            Text(
              "暂无钱包历史",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5, vertical: defaultPadding),
              child: Text(
                "您的钱包历史记录为空。开始购物后，您的交易记录将显示在这里。",
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop/components/Banner/M/banner_m_style_1.dart';
import 'package:shop/components/Banner/M/banner_m_style_2.dart';
import 'package:shop/components/Banner/M/banner_m_style_3.dart';
import 'package:shop/components/Banner/M/banner_m_style_4.dart';
import 'package:shop/components/dot_indicators.dart';

import '../../../../constants.dart';

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({
    super.key,
  });

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late Timer _timer;

  //数据源模块
  List offers = [
    BannerMStyle1(
      text: "New items with \nFree shipping",
      press: () {},
    ),
    BannerMStyle2(
      title: "Black \nfriday",
      subtitle: "Collection",
      discountParcent: 50,
      press: () {},
    ),
    BannerMStyle3(
      title: "Grab \nyours now",
      discountParcent: 50,
      press: () {},
    ),
    BannerMStyle4(
      // image: , user your image
      title: "SUMMER \nSALE",
      subtitle: "SPECIAL OFFER",
      discountParcent: 80,
      press: () {},
    ),
  ];
// 初始化
  @override
  void initState() {// 初始化
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_selectedIndex < offers.length - 1) {
        _selectedIndex++;
      } else {
        _selectedIndex = 0;
      }

      _pageController.animateToPage(
        _selectedIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
    super.initState();
  }

  @override
  void dispose() {// 销毁
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(// 比例布局
      aspectRatio: 1.87,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(// 轮播图
            controller: _pageController,
            itemCount: offers.length,
            onPageChanged: (int index) {
              setState(() {// 更新状态
                _selectedIndex = index;
              });
            },
            itemBuilder: (context, index) => offers[index],// 动态构建
          ),
          FittedBox(// 自适应布局
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: List.generate(// 动态构建
                    offers.length,
                    (index) {
                      return Padding(// 间距
                        padding:
                            const EdgeInsets.only(left: defaultPadding / 4),// 左边距
                        child: DotIndicator(// 点指示器
                          isActive: index == _selectedIndex,// 是否选中
                          activeColor: Colors.white70,// 选中颜色
                          inActiveColor: Colors.white54,// 未选中颜色
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

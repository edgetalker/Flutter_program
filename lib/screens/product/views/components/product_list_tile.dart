import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 商品列表项
class ProductListTile extends StatelessWidget {
  const ProductListTile({// 构造函数
    super.key,
    required this.svgSrc,
    required this.title,
    this.isShowBottomBorder = false,
    required this.press,
  });

  final String svgSrc, title;
  final bool isShowBottomBorder;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(// 垂直布局
      child: Column(// 垂直布局
        children: [
          const Divider(height: 1),// 分割线
          ListTile(// 列表项
            onTap: press,// 点击事件
            minLeadingWidth: 24,// 最小前导宽度
            leading: SvgPicture.asset(// 图标
              svgSrc,
              height: 24,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            title: Text(title),
            trailing: SvgPicture.asset(
              "assets/icons/miniRight.svg",
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
          if (isShowBottomBorder) const Divider(height: 1),
        ],
      ),
    );
  }
}

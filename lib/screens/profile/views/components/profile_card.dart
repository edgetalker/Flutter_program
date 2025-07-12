import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/network_image_with_loader.dart';

import '../../../../constants.dart';
// 用户资料卡
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,// 用户名
    required this.email,// 邮箱
    required this.imageSrc,// 头像
    this.proLableText = "Pro",// 会员标签文本
    this.isPro = false,// 是否是会员
    this.press,// 点击事件
    this.isShowHi = true,// 是否显示欢迎语
    this.isShowArrow = true,// 是否显示箭头
  });

  final String name, email, imageSrc;
  final String proLableText;
  final bool isPro, isShowHi, isShowArrow;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return ListTile(// 列表项
      onTap: press,
      leading: CircleAvatar(// 圆形头像
        radius: 28,
        child: NetworkImageWithLoader(
          imageSrc,
          radius: 100,
        ),
      ),
      title: Row(// 标题行
        children: [
          Text(// 文本
            isShowHi ? "Hi, $name" : name,
            style: const TextStyle(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: defaultPadding / 2),
          if (isPro)// 会员标签
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding / 2, vertical: defaultPadding / 4),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius:
                    BorderRadius.all(Radius.circular(defaultBorderRadious)),
              ),
              child: Text(
                proLableText,
                style: const TextStyle(
                  fontFamily: grandisExtendedFont,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.7,
                  height: 1,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(email),
      trailing: isShowArrow
          ? SvgPicture.asset(
              "assets/icons/miniRight.svg",
              color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
            )
          : null,
    );
  }
}

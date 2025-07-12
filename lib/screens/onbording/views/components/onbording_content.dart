import 'package:flutter/material.dart';

import '../../../../constants.dart';

// 内容组件 支持自定义标题和描述 图片 是否显示在图片上方
class OnbordingContent extends StatelessWidget {
  const OnbordingContent({
    super.key,
    this.isTextOnTop = false, // 标题和描述默认显示在图片下方
    required this.title,
    required this.description,
    required this.image,
  });

  final bool isTextOnTop;
  final String title, description, image;

  @override
  Widget build(BuildContext context) {
    return Column(// 列布局
      children: [
        const Spacer(),// 间距

        if (isTextOnTop)// 如果标题和描述显示在图片上方
          OnbordTitleDescription(
            title: title,
            description: description,
          ),
        if (isTextOnTop) const Spacer(),

        /// 可换为svg图片
        // 图片
        Image.asset(
          image,
          height: 250,
        ),
        if (!isTextOnTop) const Spacer(),
        if (!isTextOnTop)
          OnbordTitleDescription(
            title: title,
            description: description,
          ),

        const Spacer(),
      ],
    );
  }
}

class OnbordTitleDescription extends StatelessWidget {
  const OnbordTitleDescription({
    super.key,
    required this.title,
    required this.description,
  });

  final String title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,// 居中
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: defaultPadding),// 自定义参数
        Text(
          description,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

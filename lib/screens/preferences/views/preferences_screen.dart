import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

import 'components/prederence_list_tile.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("偏好设置"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("重置"),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: defaultPadding),
        child: Column(
          children: [
            PreferencesListTile(
              titleText: "数据分析",
              subtitleTxt:
                  "分析Cookie帮助我们通过收集和报告您的使用信息来改进应用程序。它们以不直接识别任何人身份的方式收集信息。",
              isActive: true,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "个性化",
              subtitleTxt:
                  "个性化Cookie收集您使用此应用的信息，以便显示与您相关的内容和体验。",
              isActive: false,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "营销推广",
              subtitleTxt:
                  "营销Cookie收集您使用此应用和其他应用的信息，以便展示更贴合您需求的广告和营销内容。",
              isActive: false,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "社交媒体Cookie",
              subtitleTxt:
                  "这些Cookie由我们添加到应用中的各种社交媒体服务设置，以便您与朋友和网络分享我们的内容。",
              isActive: false,
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}

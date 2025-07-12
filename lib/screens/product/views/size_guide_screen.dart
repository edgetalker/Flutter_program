import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

// 尺码指南
class SizeGuideScreen extends StatefulWidget {
  const SizeGuideScreen({super.key});// 构造函数

  @override
  State<SizeGuideScreen> createState() => _SizeGuideScreenState();
}

class _SizeGuideScreenState extends State<SizeGuideScreen> {
  bool _isShowCentimetersSize = false;// 是否显示厘米尺寸

  void updateSizes() {// 更新尺寸
    setState(() {
      _isShowCentimetersSize = !_isShowCentimetersSize;
    });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(// 
      appBar: AppBar(// 应用栏
        title: const Text("尺码指南"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: updateSizes,
            child: Text(
              _isShowCentimetersSize ? "英寸" : "厘米",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 测量说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "如何测量",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("• 胸围：测量胸部最宽处的周长"),
                  const Text("• 腰围：测量腰部最细处的周长"),
                  const Text("• 臀围：测量臀部最宽处的周长"),
                  const Text("• 肩宽：测量两肩端点的直线距离"),
                ],
              ),
            ),            
            const SizedBox(height: defaultPadding * 2),
            // 女装尺码表
            _buildSizeTable("女装尺码", [
              ["尺码", "胸围", "腰围", "臀围"],
              ["XS", _getSize("81-84", "32-33"), _getSize("61-64", "24-25"), _getSize("89-92", "35-36")],
              ["S", _getSize("86-89", "34-35"), _getSize("66-69", "26-27"), _getSize("94-97", "37-38")],
              ["M", _getSize("91-94", "36-37"), _getSize("71-74", "28-29"), _getSize("99-102", "39-40")],
              ["L", _getSize("96-99", "38-39"), _getSize("76-79", "30-31"), _getSize("104-107", "41-42")],
              ["XL", _getSize("101-104", "40-41"), _getSize("81-84", "32-33"), _getSize("109-112", "43-44")],
              ["XXL", _getSize("106-109", "42-43"), _getSize("86-89", "34-35"), _getSize("114-117", "45-46")],
            ]),            
            const SizedBox(height: defaultPadding * 2),           
            // 男装尺码表
            _buildSizeTable("男装尺码", [
              ["尺码", "胸围", "腰围", "肩宽"],
              ["S", _getSize("86-91", "34-36"), _getSize("71-76", "28-30"), _getSize("42-44", "16.5-17.3")],
              ["M", _getSize("91-96", "36-38"), _getSize("76-81", "30-32"), _getSize("44-46", "17.3-18.1")],
              ["L", _getSize("96-101", "38-40"), _getSize("81-86", "32-34"), _getSize("46-48", "18.1-18.9")],
              ["XL", _getSize("101-106", "40-42"), _getSize("86-91", "34-36"), _getSize("48-50", "18.9-19.7")],
              ["XXL", _getSize("106-111", "42-44"), _getSize("91-96", "36-38"), _getSize("50-52", "19.7-20.5")],
              ["XXXL", _getSize("111-116", "44-46"), _getSize("96-101", "38-40"), _getSize("52-54", "20.5-21.3")],
            ]),            
            const SizedBox(height: defaultPadding * 2),            
            // 儿童尺码表
            _buildSizeTable("儿童尺码", [
              ["年龄", "身高", "胸围", "腰围"],
              ["2-3岁", _getSize("92-98", "36-39"), _getSize("52-54", "20-21"), _getSize("50-52", "20-20.5")],
              ["4-5岁", _getSize("104-110", "41-43"), _getSize("54-56", "21-22"), _getSize("52-54", "20.5-21")],
              ["6-7岁", _getSize("116-122", "46-48"), _getSize("56-58", "22-23"), _getSize("54-56", "21-22")],
              ["8-9岁", _getSize("128-134", "50-53"), _getSize("58-60", "23-24"), _getSize("56-58", "22-23")],
              ["10-11岁", _getSize("140-146", "55-57"), _getSize("60-62", "24-24.5"), _getSize("58-60", "23-24")],
              ["12-13岁", _getSize("152-158", "60-62"), _getSize("62-64", "24.5-25"), _getSize("60-62", "24-24.5")],
            ]),           
            const SizedBox(height: defaultPadding * 2),           
            // 贴心提示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(defaultBorderRadious),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "贴心提示",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("• 如果您的尺寸介于两个尺码之间，建议选择较大的尺码"),
                  const Text("• 不同品牌的尺码可能略有差异"),
                  const Text("• 建议购买前查看具体商品的尺码信息"),
                  const Text("• 如有疑问，请联系客服获得专业建议"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// 构建尺码表
  Widget _buildSizeTable(String title, List<List<String>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(// 表格标题
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: defaultPadding),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(defaultBorderRadious),
          ),
          child: Table(// 表格主题
            border: TableBorder.all(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
            children: data.map((row) {
              bool isHeader = data.indexOf(row) == 0;
              return TableRow(
                decoration: BoxDecoration(
                  color: isHeader 
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                ),
                children: row.map((cell) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      cell,
                      style: TextStyle(
                        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
// 获取尺寸
  String _getSize(String cm, String inch) {
    return _isShowCentimetersSize ? "$cm cm" : "$inch \"";
  }
}

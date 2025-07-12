class CategoryModel {
  final String title;
  final String? image, svgSrc;
  final List<CategoryModel>? subCategories;

  CategoryModel({
    required this.title,
    this.image,
    this.svgSrc,
    this.subCategories,
  });
}

final List<CategoryModel> demoCategoriesWithImage = [
  CategoryModel(title: "女装", image: "assets/Illustration/Illustration-0.png"),
  CategoryModel(title: "男装", image: "assets/Illustration/Illustration-1.png"),
  CategoryModel(title: "童装", image: "assets/Illustration/Illustration-2.png"),
  CategoryModel(title: "配饰", image: "assets/Illustration/Illustration-3.png"),
];

final List<CategoryModel> demoCategories = [
  CategoryModel(
    title: "特价商品",
    svgSrc: "assets/icons/Sale.svg",
    subCategories: [
      CategoryModel(title: "全部服装"),
      CategoryModel(title: "新品上架"),
      CategoryModel(title: "外套夹克"),
      CategoryModel(title: "连衣裙"),
      CategoryModel(title: "牛仔裤"),
    ],
  ),
  CategoryModel(
    title: "男装女装",
    svgSrc: "assets/icons/Man&Woman.svg",
    subCategories: [
      CategoryModel(title: "全部服装"),
      CategoryModel(title: "新品上架"),
      CategoryModel(title: "外套夹克"),
    ],
  ),
  CategoryModel(
    title: "童装",
    svgSrc: "assets/icons/Child.svg",
    subCategories: [
      CategoryModel(title: "全部服装"),
      CategoryModel(title: "新品上架"),
      CategoryModel(title: "外套夹克"),
    ],
  ),
  CategoryModel(
    title: "配饰",
    svgSrc: "assets/icons/Accessories.svg",
    subCategories: [
      CategoryModel(title: "全部配饰"),
      CategoryModel(title: "新品上架"),
    ],
  ),
];

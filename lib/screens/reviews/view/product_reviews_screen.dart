import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

// 评价模型
class Review {
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> images;
  final String userAvatar;

  Review({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.images = const [],
    required this.userAvatar,
  });
}

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({super.key});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  int _selectedRatingFilter = 0; // 0表示全部，1-5表示对应星级
  String _selectedSortOrder = '最新'; // 排序方式：最新、最热、最有用

  final List<Review> _reviews = [
    Review(
      userName: "小美",
      rating: 5.0,
      comment: "质量很好，穿着很舒服，尺码也很合适！物流很快，包装也很用心。",
      date: DateTime.now().subtract(const Duration(days: 1)),
      images: ["assets/Illustration/Illustration-0.png"],
      userAvatar: "assets/images/notification.png",
    ),
    Review(
      userName: "购物达人",
      rating: 4.0,
      comment: "整体不错，样式好看，就是颜色比图片稍微深一点点，但是可以接受。",
      date: DateTime.now().subtract(const Duration(days: 3)),
      images: [],
      userAvatar: "assets/images/notification.png",
    ),
    Review(
      userName: "时尚女孩",
      rating: 5.0,
      comment: "超级喜欢！面料很舒服，版型也很好，已经推荐给朋友了。客服态度也很好。",
      date: DateTime.now().subtract(const Duration(days: 5)),
      images: ["assets/Illustration/Illustration-1.png", "assets/Illustration/Illustration-2.png"],
      userAvatar: "assets/images/notification.png",
    ),
    Review(
      userName: "优雅女士",
      rating: 4.0,
      comment: "品质不错，设计简约大方，适合日常穿着。发货速度很快。",
      date: DateTime.now().subtract(const Duration(days: 7)),
      images: [],
      userAvatar: "assets/images/notification.png",
    ),
    Review(
      userName: "简约主义",
      rating: 3.0,
      comment: "质量一般，价格还算合理。尺码偏小，建议买大一码。",
      date: DateTime.now().subtract(const Duration(days: 10)),
      images: [],
      userAvatar: "assets/images/notification.png",
    ),
  ];

  List<Review> get _filteredReviews {
    List<Review> filtered = _reviews;
    
    // 按星级过滤
    if (_selectedRatingFilter > 0) {
      filtered = filtered.where((review) => review.rating.round() == _selectedRatingFilter).toList();
    }
    
    // 排序
    switch (_selectedSortOrder) {
      case '最新':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case '最热':
        // 模拟按点赞数排序（这里简化为按评分排序）
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case '最有用':
        // 模拟按有用性排序（这里简化为按评论长度排序）
        filtered.sort((a, b) => b.comment.length.compareTo(a.comment.length));
        break;
    }
    
    return filtered;
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("商品评价"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showAddReviewDialog,
            icon: const Icon(Icons.add_comment),
            tooltip: "写评价",
          ),
        ],
      ),
      body: Column(
        children: [
          // 评价统计
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(
                  children: [
                    // 平均评分
                    Column(
                      children: [
                        Text(
                          _averageRating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        _buildStarRating(_averageRating),
                        Text(
                          "${_reviews.length} 条评价",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: defaultPadding * 2),
                    
                    // 评分分布
                    Expanded(
                      child: Column(
                        children: [
                          for (int i = 5; i >= 1; i--)
                            _buildRatingBar(i, _getRatingCount(i), _reviews.length),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 筛选和排序
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              children: [
                // 星级筛选
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip("全部", _selectedRatingFilter == 0, () {
                          setState(() => _selectedRatingFilter = 0);
                        }),
                        for (int i = 5; i >= 1; i--)
                          _buildFilterChip("${i}星", _selectedRatingFilter == i, () {
                            setState(() => _selectedRatingFilter = i);
                          }),
                      ],
                    ),
                  ),
                ),
                
                // 排序
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() => _selectedSortOrder = value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "最新", child: Text("最新")),
                    const PopupMenuItem(value: "最热", child: Text("最热")),
                    const PopupMenuItem(value: "最有用", child: Text("最有用")),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedSortOrder),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 评价列表
          Expanded(
            child: _filteredReviews.isEmpty
                ? const Center(child: Text("暂无符合条件的评价"))
                : ListView.separated(
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: _filteredReviews.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return _buildReviewItem(_filteredReviews[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        double starValue = index + 1;
        return Icon(
          starValue <= rating ? Icons.star : Icons.star_border,
          color: const Color(0xFFFFB800),
          size: 16,
        );
      }),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    double percentage = total > 0 ? count / total : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$stars", style: const TextStyle(fontSize: 12)),
          const Icon(Icons.star, color: Color(0xFFFFB800), size: 12),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB800)),
            ),
          ),
          const SizedBox(width: 8),
          Text("$count", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: primaryColor.withOpacity(0.2),
        checkmarkColor: primaryColor,
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户信息和评分
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(review.userAvatar),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      _buildStarRating(review.rating),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(review.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 评价内容
        Text(review.comment),
        
        // 评价图片
        if (review.images.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: review.images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(review.images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        
        const SizedBox(height: 8),
        
        // 操作按钮
        Row(
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
              label: const Text("有用"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.comment_outlined, size: 16),
              label: const Text("回复"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _getRatingCount(int rating) {
    return _reviews.where((review) => review.rating.round() == rating).length;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    if (diff == 0) return "今天";
    if (diff == 1) return "昨天";
    if (diff < 7) return "${diff}天前";
    if (diff < 30) return "${(diff / 7).floor()}周前";
    return "${date.month}-${date.day}";
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("写评价"),
        content: const Text("添加评价功能正在开发中，敬请期待！"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }
}

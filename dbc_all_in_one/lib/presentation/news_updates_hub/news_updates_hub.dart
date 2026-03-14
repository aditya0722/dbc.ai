import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import './widgets/news_poster_card_widget.dart';

class NewsUpdatesHub extends StatefulWidget {
  const NewsUpdatesHub({super.key});

  @override
  State<NewsUpdatesHub> createState() => _NewsUpdatesHubState();
}

class _NewsUpdatesHubState extends State<NewsUpdatesHub> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isRefreshing = false;

  final List<String> _categories = [
    'All',
    'Industry News',
    'Business Tips',
    'Market Updates',
    'Technology',
    'Regulations',
  ];

  final List<Map<String, dynamic>> _sampleNews = [
    {
      'id': '1',
      'title': 'Small Business Growth Strategies for 2025',
      'source': 'Business Insider',
      'timestamp': '2 hours ago',
      'category': 'Business Tips',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_15cea8705-1765487413695.png',
      'semanticLabel':
          'Business professional analyzing growth charts on laptop in modern office',
      'readingTime': '5 min',
      'summary':
          'Discover proven strategies to scale your business in the new year with expert insights.',
      'likes': 234,
      'shares': 45,
      'isSaved': false,
    },
    {
      'id': '2',
      'title': 'AI Integration in Retail: What You Need to Know',
      'source': 'Tech Today',
      'timestamp': '4 hours ago',
      'category': 'Technology',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_14d9c7ed0-1765220505039.png',
      'semanticLabel':
          'Futuristic AI technology interface with digital blue holographic displays',
      'readingTime': '7 min',
      'summary':
          'How artificial intelligence is transforming the retail landscape and customer experience.',
      'likes': 567,
      'shares': 89,
      'isSaved': true,
    },
    {
      'id': '3',
      'title': 'New Tax Regulations Impact Small Businesses',
      'source': 'Financial Times',
      'timestamp': '6 hours ago',
      'category': 'Regulations',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_15db54338-1764657811017.png',
      'semanticLabel':
          'Accountant reviewing financial documents and tax forms on desk',
      'readingTime': '6 min',
      'summary':
          'Understanding the latest tax policy changes and their implications for your business.',
      'likes': 189,
      'shares': 67,
      'isSaved': false,
    },
    {
      'id': '4',
      'title': 'Supply Chain Optimization Tips for 2025',
      'source': 'Industry Weekly',
      'timestamp': '8 hours ago',
      'category': 'Industry News',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_135ea089a-1764637482598.png',
      'semanticLabel':
          'Warehouse logistics manager coordinating inventory with digital tablet',
      'readingTime': '8 min',
      'summary':
          'Streamline your supply chain with cutting-edge strategies and tools.',
      'likes': 412,
      'shares': 123,
      'isSaved': true,
    },
    {
      'id': '5',
      'title': 'Market Trends: Consumer Behavior Shifts',
      'source': 'Market Insights',
      'timestamp': '10 hours ago',
      'category': 'Market Updates',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1fe26f223-1764664593903.png',
      'semanticLabel':
          'Stock market graphs and financial data on multiple computer screens',
      'readingTime': '4 min',
      'summary':
          'Key insights into evolving consumer preferences and shopping habits.',
      'likes': 345,
      'shares': 78,
      'isSaved': false,
    },
    {
      'id': '6',
      'title': 'Digital Marketing Essentials for Small Business',
      'source': 'Marketing Pro',
      'timestamp': '12 hours ago',
      'category': 'Business Tips',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_179a29bb3-1764669852473.png',
      'semanticLabel':
          'Digital marketing analytics dashboard showing social media metrics',
      'readingTime': '6 min',
      'summary':
          'Master digital marketing fundamentals to boost your online presence.',
      'likes': 278,
      'shares': 92,
      'isSaved': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredNews {
    return _sampleNews.where((news) {
      final matchesCategory =
          _selectedCategory == 'All' || news['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          news['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          news['source'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('News feed updated'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  void _toggleSave(String newsId) {
    setState(() {
      final index = _sampleNews.indexWhere((news) => news['id'] == newsId);
      if (index != -1) {
        _sampleNews[index]['isSaved'] = !_sampleNews[index]['isSaved'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'News & Updates'),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _filteredNews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No news articles found',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(4.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 2.h,
                        crossAxisSpacing: 4.w,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _filteredNews.length,
                      itemBuilder: (context, index) {
                        final news = _filteredNews[index];
                        return NewsPosterCardWidget(
                          newsItem: news,
                          onSaveTap: () => _toggleSave(news['id']),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:dbc_all_in_one/routes/app_routes.dart';
import 'package:flutter/material.dart';

// ── Reused app-wide widgets (same ones BusinessDashboard uses) ─────────────────
import '../../widgets/custom_bottom_bar.dart'; // same mobile bottom bar
import '../../widgets/dbc_back_button.dart';
import '../business_dashboard/widgets/desktop_sidebar_widget.dart'; // same sidebar
import '../business_dashboard/widgets/desktop_right_panel_widget.dart'; // same right panel

// ── News-specific widgets ──────────────────────────────────────────────────────
import './widgets/news_search_bar_widget.dart';
import './widgets/news_hero_card_widget.dart';
import './widgets/news_market_panel_widget.dart';
import './widgets/news_podcast_promo_widget.dart';
import './widgets/news_section_header_widget.dart';
import './widgets/news_insight_card_widget.dart';
import './widgets/news_subscribe_banner_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  NewsUpdatesHub
//
//  Reuses the EXACT same DesktopSidebarWidget and CustomBottomBar that
//  BusinessDashboard uses — no duplication.
//
//  Desktop (>700px) : DesktopSidebarWidget (72px) | news content
//  Mobile  (≤700px) : AppBar | news content | CustomBottomBar
// ─────────────────────────────────────────────────────────────────────────────

class NewsUpdatesHub extends StatefulWidget {
  /// Pass the current nav index from the parent so the sidebar highlights
  /// the correct item — same pattern as BusinessDashboard.initialIndex.
  final int initialIndex;

  const NewsUpdatesHub({super.key, this.initialIndex = 5});

  @override
  State<NewsUpdatesHub> createState() => _NewsUpdatesHubState();
}

class _NewsUpdatesHubState extends State<NewsUpdatesHub> {
  late int _currentNavIndex;

  // ── Filter state ───────────────────────────────────────────────────────────
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Business',
    'Security',
    'Staff',
    'Tech',
  ];

  // ── Sample data ────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _sampleNews = [
    {
      'id': '1',
      'title': 'The 2024 Sovereign Executive: Redefining Digital Stewardship',
      'source': 'Business Insider',
      'timestamp': 'Oct 12, 2023',
      'category': 'Business',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_15cea8705-1765487413695.png',
      'readingTime': '12 min',
      'summary':
          'Exploring the transition to post-quantum cryptography and how it impacts executive data.',
      'isSaved': false,
    },
    {
      'id': '2',
      'title': 'AI Integration in Retail: What You Need to Know',
      'source': 'Tech Today',
      'timestamp': '4 hours ago',
      'category': 'Tech',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_14d9c7ed0-1765220505039.png',
      'readingTime': '7 min',
      'summary':
          'How artificial intelligence is transforming the retail landscape and customer experience.',
      'isSaved': true,
    },
    {
      'id': '3',
      'title': 'Quantum Encryption: A New Protocol for Asset Protection',
      'source': 'Security Weekly',
      'timestamp': '2 days ago',
      'category': 'Security',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_15db54338-1764657811017.png',
      'readingTime': '6 min',
      'summary':
          'Exploring the upcoming transition to post-quantum cryptography and how it impacts executive data.',
      'isSaved': false,
    },
    {
      'id': '4',
      'title': 'Global Connectivity Infrastructure: The Shift West',
      'source': 'Network',
      'timestamp': '6 days ago',
      'category': 'Tech',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_135ea089a-1764637482598.png',
      'readingTime': '8 min',
      'summary':
          'New subsea cables are reshaping how executives manage international operations and latency.',
      'isSaved': true,
    },
    {
      'id': '5',
      'title': 'Retaining Top-Tier Talent in an AI-Driven Market',
      'source': 'Staff Insights',
      'timestamp': '1 week ago',
      'category': 'Staff',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1fe26f223-1764664593903.png',
      'readingTime': '4 min',
      'summary':
          'A strategic guide for executives on fostering human-centric culture amidst massive automation.',
      'isSaved': false,
    },
  ];

  // ── Computed ───────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _filteredNews {
    return _sampleNews.where((news) {
      final matchesCategory =
          _selectedCategory == 'All' || news['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          (news['title'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (news['source'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialIndex;
  }

  // ── Handlers ───────────────────────────────────────────────────────────────
  void _onCategoryTap(String cat) => setState(() => _selectedCategory = cat);
  void _onSearchChanged(String q) => setState(() => _searchQuery = q);
  void _onSearchClear() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _toggleSave(String id) {
    setState(() {
      final idx = _sampleNews.indexWhere((n) => n['id'] == id);
      if (idx != -1)
        _sampleNews[idx]['isSaved'] = !(_sampleNews[idx]['isSaved'] as bool);
    });
  }

  /// Navigate using the same named-route approach as BusinessDashboard
  void _onNavTap(int i) {
    // Delegate back to BusinessDashboard's navigator so the shared
    // sidebar stays in sync — use pushReplacementNamed just like the dashboard.
    Navigator.pushReplacementNamed(context, _routeForIndex(i));
  }

  String _routeForIndex(int i) {
    // Mirror the exact same route map from BusinessDashboard._navigateToIndex
    switch (i) {
      case 0:
        return AppRoutes.businessDashboard;
      case 1:
        return AppRoutes.liveCameraView;
      case 2:
        return AppRoutes.inventoryManagement;
      case 3:
        return AppRoutes.staffManagement;
      case 4:
        return AppRoutes.paymentProcessingCenter;
      case 5:
        return AppRoutes.orderManagementHub; // this screen
      default:
        return AppRoutes.businessDashboard;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD — same LayoutBuilder + 700px breakpoint as BusinessDashboard
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 700;
        return isDesktop ? _buildDesktopScaffold() : _buildMobileScaffold();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DESKTOP: reuses DesktopSidebarWidget directly
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDesktopScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left sidebar — identical to BusinessDashboard ────────────────
          DesktopSidebarWidget(
            currentIndex: _currentNavIndex,
            onTap: _onNavTap,
            navItems: [
              {
                'icon': Icons.home_outlined,
                'activeIcon': Icons.home,
                'label': 'Home',
              },
              {
                'icon': Icons.security_outlined,
                'activeIcon': Icons.security,
                'label': 'Security',
              },
              {
                'icon': Icons.inventory_2_outlined,
                'activeIcon': Icons.inventory_2,
                'label': 'Stock',
              },
              {
                'icon': Icons.people_outline,
                'activeIcon': Icons.people,
                'label': 'Staff',
              },
              {
                'icon': Icons.account_balance_wallet_outlined,
                'activeIcon': Icons.account_balance_wallet,
                'label': 'Payments',
              },
              {
                'icon': Icons.more_horiz,
                'activeIcon': Icons.more_horiz,
                'label': 'More',
              },
            ],
          ),

          // ── Center content — capped at 780px, same as BusinessDashboard ──
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Column(
                  children: [
                    NewsSearchBarWidget(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onClear: _onSearchClear,
                      categories: _categories,
                      selectedCategory: _selectedCategory,
                      onCategoryTap: _onCategoryTap,
                    ),
                    Expanded(child: _buildPageBody()),
                  ],
                ),
              ),
            ),
          ),

          // ── Right panel — identical to BusinessDashboard ─────────────────
          const DesktopRightPanelWidget(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  MOBILE: reuses CustomBottomBar directly
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMobileScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: DBCBackButton(
          onPressed: () => Navigator.maybePop(context),
          iconColor: const Color(0xFF1A1A1A),
          backgroundColor: Colors.white,
        ),
        titleSpacing: 16,
        title: const Text(
          'News & Updates',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          NewsSearchBarWidget(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _onSearchClear,
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategoryTap: _onCategoryTap,
          ),
          Expanded(child: _buildPageBody()),
        ],
      ),
      // ── Reuse the exact same bottom bar from BusinessDashboard ───────────
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAGE BODY — responsive content, shared between desktop & mobile
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPageBody() {
    if (_filteredNews.isEmpty) return _buildEmpty();
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w >= 860) return _buildWideLayout(w);
        if (w >= 520) return _buildTabletLayout();
        return _buildMobileLayout();
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No articles found',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          const SizedBox(height: 6),
          const Text('Try adjusting your search or category filter',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  // ── Wide (≥860) ────────────────────────────────────────────────────────────
  Widget _buildWideLayout(double w) {
    final hero = _filteredNews[0];
    final featured = _filteredNews.length > 1 ? _filteredNews[1] : hero;
    final insights =
        List.generate(3, (i) => _filteredNews[(i + 2) % _filteredNews.length]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 340,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: NewsHeroCardWidget(newsItem: hero)),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: NewsMarketPanelWidget(
                            newsItem: featured, onViewAnalytics: () {}),
                      ),
                      const SizedBox(height: 12),
                      NewsPodcastPromoWidget(onPlay: () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          NewsSectionHeaderWidget(
              title: 'Industry Insights',
              actionLabel: 'View All Updates',
              onAction: () {}),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: insights.map((news) {
              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: news == insights.last ? 0 : 16),
                  child: NewsInsightCardWidget(
                    newsItem: news,
                    onSaveTap: () => _toggleSave(news['id'] as String),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          NewsSubscribeBannerWidget(onSubscribe: () {}),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Tablet (520–859) ───────────────────────────────────────────────────────
  Widget _buildTabletLayout() {
    final hero = _filteredNews[0];
    final rest = _filteredNews.skip(1).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 280, child: NewsHeroCardWidget(newsItem: hero)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: NewsMarketPanelWidget(
                      newsItem: rest.isNotEmpty ? rest[0] : hero,
                      onViewAnalytics: () {}),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: NewsPodcastPromoWidget(onPlay: () {})),
            ],
          ),
          const SizedBox(height: 28),
          NewsSectionHeaderWidget(title: 'Industry Insights', onAction: () {}),
          const SizedBox(height: 14),
          ...List.generate((rest.length / 2).ceil(), (row) {
            final a = row * 2;
            final b = a + 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (a < rest.length)
                    Expanded(
                      child: NewsInsightCardWidget(
                        newsItem: rest[a],
                        onSaveTap: () => _toggleSave(rest[a]['id'] as String),
                      ),
                    ),
                  if (b < rest.length) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: NewsInsightCardWidget(
                        newsItem: rest[b],
                        onSaveTap: () => _toggleSave(rest[b]['id'] as String),
                      ),
                    ),
                  ] else if (a < rest.length)
                    const Expanded(child: SizedBox()),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          NewsSubscribeBannerWidget(onSubscribe: () {}),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Mobile (<520) ──────────────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    final hero = _filteredNews[0];
    final rest = _filteredNews.skip(1).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 240, child: NewsHeroCardWidget(newsItem: hero)),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: NewsMarketPanelWidget(
                newsItem: rest.isNotEmpty ? rest[0] : hero,
                onViewAnalytics: () {}),
          ),
          const SizedBox(height: 12),
          NewsPodcastPromoWidget(onPlay: () {}),
          const SizedBox(height: 24),
          NewsSectionHeaderWidget(title: 'Industry Insights', onAction: () {}),
          const SizedBox(height: 14),
          ...rest.map((news) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: NewsInsightCardWidget(
                  newsItem: news,
                  onSaveTap: () => _toggleSave(news['id'] as String),
                ),
              )),
          const SizedBox(height: 8),
          NewsSubscribeBannerWidget(onSubscribe: () {}),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

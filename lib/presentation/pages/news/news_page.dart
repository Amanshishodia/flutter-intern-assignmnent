import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['Business', 'Technology', 'Sports', 'Health', 'Science', 'Entertainment'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      newsProvider.getTopHeadlines();
      newsProvider.loadBookmarks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('News Dashboard'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: NewsSearchWidget(
            controller: _searchController,
            onChanged: (query) {
              Provider.of<NewsProvider>(context, listen: false)
                  .onSearchQueryChanged(query);
            },
            onClear: () {
              _searchController.clear();
              Provider.of<NewsProvider>(context, listen: false)
                  .onSearchQueryChanged('');
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              return Visibility(
                visible: !newsProvider.isSearchActive,
                child: CategoryFilterWidget(
                  categories: _categories,
                  selectedCategory: newsProvider.currentCategory,
                  onCategorySelected: (category) {
                    if (category.isEmpty) {
                      newsProvider.getTopHeadlines();
                    } else {
                      newsProvider.getNewsByCategory(category.toLowerCase());
                    }
                  },
                ),
              );
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final newsProvider = Provider.of<NewsProvider>(context, listen: false);
                if (newsProvider.isSearchActive && newsProvider.searchQuery.isNotEmpty) {
                  newsProvider.onSearchQueryChanged(newsProvider.searchQuery);
                } else if (newsProvider.currentCategory.isNotEmpty) {
                  await newsProvider.getNewsByCategory(newsProvider.currentCategory);
                } else {
                  await newsProvider.getTopHeadlines();
                }
              },
              child: _buildNewsContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsContent() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        final status = newsProvider.status;

        if (status == NewsStatus.initial) {
          return Center(child: Text('No news available'));
        }

        if (status == NewsStatus.loading && newsProvider.articles.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (status == NewsStatus.error && newsProvider.articles.isEmpty) {
          return AppErrorWidget(
            message: newsProvider.errorMessage ?? 'Failed to load news',
            onRetry: () {
              if (newsProvider.isSearchActive && newsProvider.searchQuery.isNotEmpty) {
                newsProvider.onSearchQueryChanged(newsProvider.searchQuery);
              } else if (newsProvider.currentCategory.isNotEmpty) {
                newsProvider.getNewsByCategory(newsProvider.currentCategory);
              } else {
                newsProvider.getTopHeadlines();
              }
            },
          );
        }

        return ArticleListWidget(
          articles: newsProvider.articles,
          isLoading: status == NewsStatus.loading,
          onBookmarkToggle: (article) => newsProvider.bookmarkArticle(article),
          isArticleBookmarked: (url) => newsProvider.isArticleBookmarked(url),
        );
      },
    );
  }
}
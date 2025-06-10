import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/connectivity_provider.dart';
import '../../provider/theme_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    WeatherPage(),
    NewsPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _pages,
          ),
          _buildOfflineMessage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          themeProvider.setThemeMode(
              themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark
          );
        },
        child: Icon(Icons.brightness_6),
      ),
    );
  }

  Widget _buildOfflineMessage() {
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, child) {
        if (provider.isOnline) return SizedBox.shrink();

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Colors.red,
            child: Center(
              child: Text(
                'You are offline. Showing cached data.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
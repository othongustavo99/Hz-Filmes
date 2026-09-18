import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/catalog_drawer.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'favorites_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onSearchTap: () => _onTabTapped(1),
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      const SearchPage(),
      const FavoritesPage(),
    ];

    return Scaffold(
      key: _scaffoldKey,

      drawer: const CatalogDrawer(),

      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: AppTheme.surfaceDark,
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: AppTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Minha Lista',
          ),
        ],
      ),
    );
  }
}

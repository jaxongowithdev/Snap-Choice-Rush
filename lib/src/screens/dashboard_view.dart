import 'package:flutter/material.dart';
import 'home_view.dart';
import 'container_list_view.dart';
import 'favorites_view.dart';
import 'transfer_log_view.dart';
import 'config_view.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  const DashboardView({super.key, required this.onSettingsChanged});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeView(),
      const ContainerListView(),
      const FavoritesView(),
      const TransferLogView(),
      ConfigView(onSettingsChanged: widget.onSettingsChanged),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.local_bar_outlined), selectedIcon: Icon(Icons.local_bar), label: 'Rail'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Carts'),
          NavigationDestination(icon: Icon(Icons.local_drink_outlined), selectedIcon: Icon(Icons.local_drink), label: 'Pour'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Log'),
          NavigationDestination(icon: Icon(Icons.wine_bar_outlined), selectedIcon: Icon(Icons.wine_bar), label: 'Cellar'),
        ],
      ),
    );
  }
}

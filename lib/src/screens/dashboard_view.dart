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
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories), label: 'Nest'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox), label: 'Trays'),
          NavigationDestination(icon: Icon(Icons.push_pin_outlined), selectedIcon: Icon(Icons.push_pin), label: 'Pin'),
          NavigationDestination(icon: Icon(Icons.history_edu_outlined), selectedIcon: Icon(Icons.history_edu), label: 'Trace'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Desk'),
        ],
      ),
    );
  }
}

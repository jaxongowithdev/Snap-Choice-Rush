import 'package:flutter/material.dart';
import '../widgets/binder_chrome.dart';
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
      body: BinderShell(
        child: Column(
          children: [
            BinderTabs(
              index: _selectedIndex,
              onSelect: (i) => setState(() => _selectedIndex = i),
            ),
            Expanded(child: IndexedStack(index: _selectedIndex, children: _screens)),
          ],
        ),
      ),
    );
  }
}

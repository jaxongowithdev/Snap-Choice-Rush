import 'package:flutter/material.dart';
import '../widgets/cosmo_chrome.dart';
import 'home_view.dart';
import 'container_list_view.dart';
import 'drill_view.dart';
import 'analytics_view.dart';
import 'config_view.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  const DashboardView({super.key, required this.onSettingsChanged});

  @override
  State<DashboardView> createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  void go(int index) => setState(() => _selectedIndex = index);

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeView(onJump: go),
      const ContainerListView(),
      const DrillView(),
      const AnalyticsView(),
      ConfigView(onSettingsChanged: widget.onSettingsChanged),
    ];
  }

  @override
  void didUpdateWidget(DashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onSettingsChanged != widget.onSettingsChanged) {
      _screens[4] = ConfigView(onSettingsChanged: widget.onSettingsChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperGrain(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _screens),
            ),
            DeskRail(index: _selectedIndex, onSelect: go),
          ],
        ),
      ),
    );
  }
}

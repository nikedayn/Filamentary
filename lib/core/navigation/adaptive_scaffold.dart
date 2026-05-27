import 'package:flutter/material.dart';
import 'package:filamentary/features/inventory/presentation/inventory_screen.dart';
import 'package:filamentary/features/printers/presentation/printers_screen.dart';
import 'main_navigation_drawer.dart'; 

class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final String currentRoute;
  final String title;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.currentRoute,
    required this.title,
  });

  int _getSelectedIndex() {
    switch (currentRoute) {
      case 'inventory':
        return 0;
      case 'printers':
        return 1;
      default:
        return 0;
    }
  }

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == _getSelectedIndex()) return;

    Widget nextScreen;
    if (index == 0) {
      nextScreen = const InventoryScreen();
    } else {
      nextScreen = const PrintersScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Визначаємо десктопний режим за шириною екрана
        final isDesktop = constraints.maxWidth >= 640;

        return Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blueGrey.shade700,
            foregroundColor: Colors.white,
          ),
          
          // ФІКС СВАЙПУ: Збільшуємо зону захоплення до 100px та активуємо жест свайпу вправо
          drawerEdgeDragWidth: isDesktop ? null : 100.0,
          drawerEnableOpenDragGesture: !isDesktop,
          
          drawer: isDesktop ? null : MainNavigationDrawer(currentRoute: currentRoute),
          body: Row(
            children: [
              if (isDesktop) _buildDesktopNavigationRail(context),
              Expanded(
                child: SelectionArea(
                  child: body,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Десктопна вертикальна панель навігації
  Widget _buildDesktopNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: _getSelectedIndex(),
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      extended: true, 
      
      // ФІКС ДЕСКТОП МЕНЮ: Збільшено до 260 для безболісного рендеру кирилиці
      minExtendedWidth: 260,
      
      backgroundColor: Colors.blueGrey.shade50,
      selectedLabelTextStyle: TextStyle(color: Colors.blueGrey.shade900, fontWeight: FontWeight.bold),
      unselectedLabelTextStyle: TextStyle(color: Colors.blueGrey.shade700),
      selectedIconTheme: IconThemeData(color: Colors.blueGrey.shade900),
      unselectedIconTheme: IconThemeData(color: Colors.blueGrey.shade600),
      indicatorColor: Colors.blueGrey.withAlpha(35),
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filamentary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            SizedBox(height: 2),
            Text(
              'Local-First 3D Print',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.layers_outlined),
          selectedIcon: Icon(Icons.layers),
          label: Text('Інвентар матеріалів'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.print_outlined),
          selectedIcon: Icon(Icons.print),
          label: Text('3D Принтери'),
        ),
      ],
      trailing: const Expanded(
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('v1,0,0 Core', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ),
        ),
      ),
    );
  }
}
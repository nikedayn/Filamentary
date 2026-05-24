import 'package:flutter/material.dart';
// Фікс: імпорт для rootScaffoldMessengerKey
import 'package:filamentary/features/inventory/presentation/inventory_screen.dart';
import 'package:filamentary/features/printers/presentation/printers_screen.dart';

class MainNavigationDrawer extends StatelessWidget {
  final String currentRoute;
  

  const MainNavigationDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey.shade700),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Filamentary',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Local-First 3D Print Ecosystem',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.layers_outlined),
            title: const Text('Інвентар матеріалів', style: TextStyle(fontWeight: FontWeight.w600)),
            selected: currentRoute == 'inventory',
            // Фікс: використовуємо withAlpha замість зношеного з роками withOpacity
            selectedTileColor: Colors.blueGrey.withAlpha(25), 
            selectedColor: Colors.blueGrey.shade800,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'inventory') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const InventoryScreen()),
                );
              }
            },
          ),
          ListTile(
            // Фікс: замінено на універсальну іконку Icons.print без const-конфліктів
            leading: const Icon(Icons.print),
            title: const Text('3D Принтери', style: TextStyle(fontWeight: FontWeight.w600)),
            selected: currentRoute == 'printers',
            selectedTileColor: Colors.blueGrey.withAlpha(25),
            selectedColor: Colors.blueGrey.shade800,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != 'printers') {
                // ВИПРАВЛЕНО: Тепер відкриваємо справжній екран принтерів замість SnackBar
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PrintersScreen()),
                );
              }
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('v1.0.0+1 Core Engine', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
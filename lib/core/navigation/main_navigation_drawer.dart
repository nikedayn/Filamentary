import 'package:flutter/material.dart';
import 'package:filamentary/features/inventory/presentation/inventory_screen.dart';
import 'package:filamentary/features/printers/presentation/printers_screen.dart';

class MainNavigationDrawer extends StatelessWidget {
  final String currentRoute;

  const MainNavigationDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Робимо колір фону меню злегка м'яким, без грубих білих ліній
      backgroundColor: const Color(0xFFF8F9FA), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. СИМЕТРИЧНИЙ ЛЕГКИЙ ЗАГОЛОВОК (Замість важкого DrawerHeader)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filamentary',
                    style: TextStyle(
                      color: Colors.blueGrey.shade800, 
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Local-First 3D Print',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200, height: 1),
                ],
              ),
            ),
          ),

          // 2. ІДЕАЛЬНО ВИРІВНЯНІ ПУНКТИ МЕНЮ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _buildNavigationTile(
                  context: context,
                  icon: Icons.layers_outlined,
                  activeIcon: Icons.layers,
                  label: 'Інвентар матеріалів',
                  isSelected: currentRoute == 'inventory',
                  onTap: () => _navigateTo(context, const InventoryScreen(), 'inventory'),
                ),
                const SizedBox(height: 4),
                _buildNavigationTile(
                  context: context,
                  icon: Icons.print_outlined,
                  activeIcon: Icons.print,
                  label: '3D Принтери',
                  isSelected: currentRoute == 'printers',
                  onTap: () => _navigateTo(context, const PrintersScreen(), 'printers'),
                ),
              ],
            ),
          ),

          const Spacer(),
          
          // 3. НИЖНІЙ СИМЕТРИЧНИЙ ФУТЕР
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'v1,0,0 Core Engine', // Кома замість крапки згідно з вимогами звітності
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ОПТИМІЗОВАНИЙ КОНСТРУКТОР ПУНКТІВ МЕНЮ З СУВОРОЮ СИМЕТРІЄЮ
  Widget _buildNavigationTile({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        // Замість овалу навколо іконки підсвічуємо весь рядок м'яким радіусом
        color: isSelected ? Colors.blueGrey.withAlpha(15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        // Задаємо чіткий фіксований відступ між іконкою та текстом
        horizontalTitleGap: 12, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? Colors.blueGrey.shade800 : Colors.blueGrey.shade600,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
            color: isSelected ? Colors.blueGrey.shade900 : Colors.blueGrey.shade700,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen, String routeName) {
    Navigator.pop(context); // Закриваємо меню
    if (currentRoute != routeName) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/di/injection.dart';
// Імпортуємо наш головний Дроуер
import 'package:filamentary/core/navigation/main_navigation_drawer.dart'; 
import 'printers_bloc.dart';
import 'widgets/printer_card.dart';
import 'widgets/add_printer_dialog.dart';

class PrintersScreen extends StatelessWidget {
  const PrintersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PrintersBloc>()..add(WatchPrinters()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('3D Принтери', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.blueGrey.shade100, 
              elevation: 2,
              // МИ ПРИБРАЛИ ВСІ ХАКОВІ LEADING. 
              // Flutter сам автоматично створить робочу кнопку меню, бо знизу оголошено drawer!
            ),
            // ПІДКЛЮЧАЄМО ШТОРКУ ДЛЯ ЦЬОГО ЕКРАНА
            drawer: const MainNavigationDrawer(currentRoute: 'printers'), 
            body: BlocBuilder<PrintersBloc, PrintersState>(
              builder: (context, state) {
                if (state is PrintersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PrintersLoaded) {
                  if (state.printers.isEmpty) {
                    return Center(
                      child: Text(
                        'Принтери не додані', 
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: state.printers.length,
                    itemBuilder: (context, index) {
                      return PrinterCard(printer: state.printers[index]);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Colors.blueGrey.shade600,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Додати принтер', style: TextStyle(color: Colors.white)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AddPrinterDialog(printersBloc: context.read<PrintersBloc>()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
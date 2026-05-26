import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/di/injection.dart';
import 'package:filamentary/core/navigation/main_navigation_drawer.dart';
import 'printers_bloc.dart';
import 'widgets/printer_card.dart';
import 'widgets/add_printer_dialog.dart'; // Припустимо, що є діалог додавання

class PrintersScreen extends StatelessWidget {
  const PrintersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PrintersBloc>()..add(WatchPrintersEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мої 3D-Принтери', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueGrey.shade100,
          elevation: 2,
        ),
        drawer: const MainNavigationDrawer(currentRoute: 'printers'),
        body: BlocBuilder<PrintersBloc, PrintersState>(
          builder: (context, state) {
            if (state is PrintersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PrintersFailure) {
              return Center(child: Text('Помилка завантаження: ${state.error}'));
            }

            if (state is PrintersLoaded) {
              if (state.printers.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print_disabled_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Жодного принтера не додано', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                );
              }

              // ФІКС: Додано оператор return, крапку з комою в кінці та state.printers замість сирого printers
              return Padding(
                padding: const EdgeInsets.all(16.0), // Додаємо відступ навколо сітки, щоб картки не липли до країв екрана
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 колонки для десктопу
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    // Завдяки пропорції 0.75 комірка сітки витягується по вертикалі, 
                    // даючи картинці бути квадратом, а тексту знизу — мати комфортне місце без оверфлоу.
                    childAspectRatio: 0.75, 
                  ),
                  itemCount: state.printers.length,
                  itemBuilder: (context, index) {
                    return PrinterCard(printer: state.printers[index]);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              backgroundColor: Colors.blueGrey.shade700,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.print_outlined),
              label: const Text('Додати принтер'),
              onPressed: () {
                final printersBloc = context.read<PrintersBloc>();
                showDialog(
                  context: context,
                  builder: (context) => AddPrinterDialog(printersBloc: printersBloc),
                );
              },
            );
          }
        ),
      ),
    );
  }
}
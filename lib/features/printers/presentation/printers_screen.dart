import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/di/injection.dart';
import 'package:filamentary/core/navigation/adaptive_scaffold.dart'; 
import 'printers_bloc.dart';
import 'widgets/printer_card.dart';
import 'widgets/add_printer_dialog.dart';

class PrintersScreen extends StatelessWidget {
  const PrintersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PrintersBloc>()..add(WatchPrintersEvent()),
      child: Builder(
        builder: (dialogContext) {
          return AdaptiveScaffold(
            currentRoute: 'printers',
            title: 'Мої 3D-Принтери',
            body: Scaffold(
              backgroundColor: Colors.transparent, 
              body: BlocBuilder<PrintersBloc, PrintersState>(
                builder: (context, state) {
                  if (state is PrintersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PrintersFailure) {
                    return Center(child: Text('Помилка: ${state.error}'));
                  }

                  if (state is PrintersLoaded) {
                    if (state.printers.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.print_disabled_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text('Жодного принтера не додано', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;

                        int crossAxisCount = 1;
                        if (width >= 900) {
                          crossAxisCount = 3;
                        } else if (width >= 600) {
                          crossAxisCount = 2;
                        }

                        // КОРИГУВАННЯ: Оскільки в картці тепер є квадрат 1:1,
                        // загальна пропорція картки має враховувати місце під текст.
                        double childAspectRatio = 0.85; 
                        if (crossAxisCount == 1) {
                          // Чим менше число, тим більше вертикального простору отримує картка
                          childAspectRatio = width < 380 ? 0.82 : 0.88; 
                        } else {
                          childAspectRatio = 0.85;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: childAspectRatio, 
                          ),
                          itemCount: state.printers.length,
                          itemBuilder: (context, index) {
                            return PrinterCard(printer: state.printers[index]);
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: Colors.blueGrey.shade700,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Додати принтер'),
                onPressed: () => _showAddPrinterForm(dialogContext),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddPrinterForm(BuildContext context) {
    final printersBloc = context.read<PrintersBloc>();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
          child: AddPrinterDialog(printersBloc: printersBloc),
        ),
      ),
    );
  }
}
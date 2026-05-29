import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/di/injection.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart'; 
import 'printer_detail_bloc.dart';
import 'widgets/printer_telemetry_panel.dart';
import 'widgets/printer_history_panel.dart';
import 'widgets/printer_status_badge.dart';
import 'widgets/add_manual_print_fab.dart';

class PrinterDetailScreen extends StatefulWidget {
  final AppPrinter printer; 

  const PrinterDetailScreen({super.key, required this.printer});

  @override
  State<PrinterDetailScreen> createState() => _PrinterDetailScreenState();
}

class _PrinterDetailScreenState extends State<PrinterDetailScreen> with SingleTickerProviderStateMixin {
  late final PrinterDetailBloc _bloc;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<PrinterDetailBloc>();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bloc.add(StartMonitoring(widget.printer));
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.printer.name, 
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
          backgroundColor: Colors.blueGrey.shade100,
          elevation: 1,
          actions: [
            BlocBuilder<PrinterDetailBloc, PrinterDetailState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: PrinterStatusBadge(
                    state: state.telemetry.state,
                    errorMessage: state.telemetry.errorMessage,
                  ),
                );
              },
            ),
          ],
        ),
        // ФІКС: Додаємо BlocListener для перехоплення та відображення SnackBar сповіщень
        body: BlocListener<PrinterDetailBloc, PrinterDetailState>(
          listenWhen: (previous, current) => current.snackBarMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.snackBarMessage!),
                backgroundColor: Colors.red.shade800,
                duration: const Duration(seconds: 3),
              ),
            );
            // Очищаємо стейт від повідомлення після успішного відображення
            _bloc.add(ClearSnackBarMessageEvent());
          },
          child: BlocBuilder<PrinterDetailBloc, PrinterDetailState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth >= 800;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 360,
                          child: Container(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: PrinterTelemetryPanel(
                                printer: state.printer ?? widget.printer, 
                                telemetry: state.telemetry,
                              ),
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1, thickness: 1),
                        Expanded(
                          child: PrinterHistoryPanel(
                            history: state.history,
                            allMaterials: state.materials, 
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                          color: Colors.blueGrey.shade50,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.blueGrey.shade900,
                            unselectedLabelColor: Colors.grey.shade600,
                            indicatorColor: Colors.blueGrey.shade700,
                            tabs: const [
                              Tab(icon: Icon(Icons.analytics_outlined), text: 'Телеметрія'),
                              Tab(icon: Icon(Icons.history_toggle_off), text: 'Лог друку'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: PrinterTelemetryPanel(
                                  printer: state.printer ?? widget.printer, 
                                  telemetry: state.telemetry,
                                ),
                              ),
                              PrinterHistoryPanel(
                                history: state.history,
                                allMaterials: state.materials,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            },
          ),
        ),
        floatingActionButton: BlocBuilder<PrinterDetailBloc, PrinterDetailState>(
          builder: (context, state) {
            if (state.isLoading) return const SizedBox.shrink();
            return AddManualPrintFab(printer: state.printer ?? widget.printer);
          },
        ),
      ),
    );
  }
}
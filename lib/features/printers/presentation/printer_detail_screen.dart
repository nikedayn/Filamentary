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
    // Ініціалізуємо контролер вкладок для мобільного/вузького режиму (2 вкладки)
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
          // Використовуємо академічне правило ТЗ: назва принтера відображається ТІЛЬКИ в AppBar
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
                  child: PrinterStatusBadge(state: state.telemetry.state),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<PrinterDetailBloc, PrinterDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                // Визначаємо десктопний режим (ширина >= 800 пікселів)
                final bool isWide = constraints.maxWidth >= 800;

                if (isWide) {
                  // =========================================================
                  // DESKTOP UX (Панелі відображаються поруч без дублювання)
                  // =========================================================
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ліва панель: Телеметрія та Слоти котушок (Має чіткі межі та скрол)
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
                      
                      // Універсальний роздільник без помилкових параметрів constraints
                      const VerticalDivider(width: 1, thickness: 1),
                      
                      // Права панель: Лог операцій та історія друку
                      Expanded(
                        child: PrinterHistoryPanel(
                          history: state.history,
                          allMaterials: state.materials, 
                        ),
                      ),
                    ],
                  );
                } else {
                  // =========================================================
                  // КРОСПЛАТФОРМЕНИЙ MOBILE UX (Чисті вкладки TabBar)
                  // Повністю прибирає конфлікти скролу і гарантує 100% працездатність
                  // =========================================================
                  return Column(
                    children: [
                      // Перемикач вкладок у мобільному/звуженому вікні
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
                      // Контентна область вкладок із незалежними областями скролу
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Вкладка 1: Телеметрія та Слоти котушок
                            SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: PrinterTelemetryPanel(
                                printer: state.printer ?? widget.printer, 
                                telemetry: state.telemetry,
                              ),
                            ),
                            // Вкладка 2: Історія операцій (має свій вбудований ListView)
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
        // Кнопка FloatingActionButton відображається стабільно на обох платформах
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
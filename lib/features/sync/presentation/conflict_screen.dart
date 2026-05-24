import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sync_bloc.dart';

class ConflictScreen extends StatelessWidget {
  const ConflictScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вирішення конфлікту даних'),
        backgroundColor: Colors.amber.shade700,
      ),
      body: BlocBuilder<SyncBloc, SyncState>(
        builder: (context, state) {
          if (state is SyncConflictDetected) {
            final conflict = state.conflict;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Зміни виявлено одночасно у хмарі та на цьому пристрої. Оберіть версію для збереження:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade400),
                    children: [
                      // ПРИБРАНО const звідси, бо всередині динамічний колір відтінку grey
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade200), 
                        children: const [
                          Padding(padding: EdgeInsets.all(8.0), child: Text('Параметр', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8.0), child: Text('Локальна версія', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8.0), child: Text('Хмарна версія', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(padding: EdgeInsets.all(8.0), child: Text('Тип/Виробник')),
                          Padding(padding: EdgeInsets.all(8.0), child: Text(conflict.localData['manufacturer'] ?? '-')),
                          Padding(padding: EdgeInsets.all(8.0), child: Text(conflict.cloudData['manufacturer'] ?? '-')),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(padding: EdgeInsets.all(8.0), child: Text('Версія (v)')),
                          Padding(padding: EdgeInsets.all(8.0), child: Text(conflict.localData['version'].toString())),
                          Padding(padding: EdgeInsets.all(8.0), child: Text(conflict.cloudData['version'].toString())),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100),
                    onPressed: () => context.read<SyncBloc>().add(const ResolveConflictWithChoice('local')),
                    child: const Text('Залишити локальну версію'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
                    onPressed: () => context.read<SyncBloc>().add(const ResolveConflictWithChoice('cloud')),
                    child: const Text('Замінити на хмарну версію'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => context.read<SyncBloc>().add(const ResolveConflictWithChoice('merge')),
                    child: const Text('Об\'єднати зміни (Merge)'),
                  ),
                ],
              ),
            );
          }

          if (state is SyncInProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('Конфліктів не виявлено. Усе синхронізовано!'));
        },
      ),
    );
  }
}
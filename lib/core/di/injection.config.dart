// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/inventory/data/inventory_repository.dart' as _i880;
import '../../features/inventory/presentation/inventory_bloc.dart' as _i431;
import '../../features/printers/data/printer_polling_service.dart' as _i622;
import '../../features/printers/data/printers_repository.dart' as _i275;
import '../../features/printers/presentation/printer_detail_bloc.dart' as _i716;
import '../../features/printers/presentation/printers_bloc.dart' as _i691;
import '../../features/settings/data/google_auth_service.dart' as _i761;
import '../../features/sync/data/google_drive_service.dart' as _i756;
import '../../features/sync/domain/sync_engine.dart' as _i677;
import '../../features/sync/presentation/sync_bloc.dart' as _i667;
import '../database/database.dart' as _i660;
import '../navigation/deep_link_handler.dart' as _i834;
import '../network/api_client.dart' as _i557;
import '../network/bambu_client.dart' as _i851;
import '../network/moonraker_client.dart' as _i500;
import '../services/label_print_service.dart' as _i732;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i660.AppDatabase>(() => _i660.AppDatabase());
    gh.lazySingleton<_i834.DeepLinkHandler>(() => _i834.DeepLinkHandler());
    gh.lazySingleton<_i557.ApiClient>(() => _i557.ApiClient());
    gh.lazySingleton<_i851.BambuClient>(() => _i851.BambuClient());
    gh.lazySingleton<_i500.MoonrakerClient>(() => _i500.MoonrakerClient());
    gh.lazySingleton<_i732.LabelPrintService>(() => _i732.LabelPrintService());
    gh.lazySingleton<_i622.PrinterPollingService>(
      () => _i622.PrinterPollingService(),
    );
    gh.lazySingleton<_i761.GoogleAuthService>(() => _i761.GoogleAuthService());
    gh.lazySingleton<_i880.InventoryRepository>(
      () => _i880.InventoryRepository(gh<_i660.AppDatabase>()),
    );
    gh.lazySingleton<_i275.PrintersRepository>(
      () => _i275.PrintersRepository(gh<_i660.AppDatabase>()),
    );
    gh.lazySingleton<_i677.SyncEngine>(
      () => _i677.SyncEngine(gh<_i660.AppDatabase>()),
    );
    gh.factory<_i716.PrinterDetailBloc>(
      () => _i716.PrinterDetailBloc(
        gh<_i660.AppDatabase>(),
        gh<_i622.PrinterPollingService>(),
      ),
    );
    gh.lazySingleton<_i756.GoogleDriveService>(
      () => _i756.GoogleDriveService(gh<_i761.GoogleAuthService>()),
    );
    gh.factory<_i667.SyncBloc>(() => _i667.SyncBloc(gh<_i677.SyncEngine>()));
    gh.factory<_i431.InventoryBloc>(
      () => _i431.InventoryBloc(
        gh<_i880.InventoryRepository>(),
        gh<_i660.AppDatabase>(),
      ),
    );
    gh.factory<_i691.PrintersBloc>(
      () => _i691.PrintersBloc(
        gh<_i275.PrintersRepository>(),
        gh<_i660.AppDatabase>(),
      ),
    );
    return this;
  }
}

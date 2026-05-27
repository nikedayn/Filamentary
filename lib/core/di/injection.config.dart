// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:filamentary/core/database/database.dart' as _i297;
import 'package:filamentary/core/navigation/deep_link_handler.dart' as _i136;
import 'package:filamentary/core/network/api_client.dart' as _i442;
import 'package:filamentary/core/network/bambu_client.dart' as _i285;
import 'package:filamentary/core/network/klipper_client.dart' as _i764;
import 'package:filamentary/core/services/label_print_service.dart' as _i410;
import 'package:filamentary/features/inventory/data/inventory_repository.dart'
    as _i1063;
import 'package:filamentary/features/inventory/presentation/inventory_bloc.dart'
    as _i638;
import 'package:filamentary/features/printers/data/printer_polling_service.dart'
    as _i392;
import 'package:filamentary/features/printers/data/printers_repository.dart'
    as _i481;
import 'package:filamentary/features/printers/presentation/printer_detail_bloc.dart'
    as _i56;
import 'package:filamentary/features/printers/presentation/printers_bloc.dart'
    as _i69;
import 'package:filamentary/features/settings/data/google_auth_service.dart'
    as _i694;
import 'package:filamentary/features/sync/data/google_drive_service.dart'
    as _i856;
import 'package:filamentary/features/sync/domain/sync_engine.dart' as _i152;
import 'package:filamentary/features/sync/presentation/sync_bloc.dart' as _i758;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i297.AppDatabase>(() => _i297.AppDatabase());
    gh.lazySingleton<_i136.DeepLinkHandler>(() => _i136.DeepLinkHandler());
    gh.lazySingleton<_i442.ApiClient>(() => _i442.ApiClient());
    gh.lazySingleton<_i285.BambuClient>(() => _i285.BambuClient());
    gh.lazySingleton<_i410.LabelPrintService>(() => _i410.LabelPrintService());
    gh.lazySingleton<_i392.PrinterPollingService>(
      () => _i392.PrinterPollingService(),
    );
    gh.lazySingleton<_i694.GoogleAuthService>(() => _i694.GoogleAuthService());
    gh.lazySingleton<_i1063.InventoryRepository>(
      () => _i1063.InventoryRepository(gh<_i297.AppDatabase>()),
    );
    gh.lazySingleton<_i481.PrintersRepository>(
      () => _i481.PrintersRepository(gh<_i297.AppDatabase>()),
    );
    gh.lazySingleton<_i152.SyncEngine>(
      () => _i152.SyncEngine(gh<_i297.AppDatabase>()),
    );
    gh.lazySingleton<_i764.KlipperClient>(
      () => _i764.KlipperClient(),
      instanceName: 'KlipperClient',
    );
    gh.factory<_i56.PrinterDetailBloc>(
      () => _i56.PrinterDetailBloc(
        gh<_i297.AppDatabase>(),
        gh<_i392.PrinterPollingService>(),
      ),
    );
    gh.lazySingleton<_i856.GoogleDriveService>(
      () => _i856.GoogleDriveService(gh<_i694.GoogleAuthService>()),
    );
    gh.factory<_i758.SyncBloc>(() => _i758.SyncBloc(gh<_i152.SyncEngine>()));
    gh.factory<_i638.InventoryBloc>(
      () => _i638.InventoryBloc(
        gh<_i1063.InventoryRepository>(),
        gh<_i297.AppDatabase>(),
      ),
    );
    gh.factory<_i69.PrintersBloc>(
      () => _i69.PrintersBloc(
        gh<_i481.PrintersRepository>(),
        gh<_i297.AppDatabase>(),
      ),
    );
    return this;
  }
}

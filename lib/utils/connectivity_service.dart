import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

/// Wraps connectivity_plus and exposes an online/offline stream.
///
/// Register once via [ConnectivityService.register], then access the singleton
/// with [ConnectivityService.instance].
class ConnectivityService {
  ConnectivityService._() : _connectivity = Connectivity();

  static ConnectivityService get instance => GetIt.I<ConnectivityService>();

  final Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _sub;
  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  bool _isOnline = true;

  bool get isOnline => _isOnline;

  /// Returns `true` when online. Returns `true` (optimistic) if the service
  /// has not been registered yet (e.g. in unit-test environments).
  static bool get isOnlineSafe {
    try {
      return ConnectivityService.instance.isOnline;
    } on StateError {
      return true;
    }
  }

  /// Emits `true` when online, `false` when offline.
  Stream<bool> get onlineStream => _controller.stream;

  /// Initialises the service: performs an immediate connectivity check and
  /// starts listening for changes.  Call once from main after registering.
  Future<void> initialize() async {
    final List<ConnectivityResult> initial =
        await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(initial);

    _sub = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final bool online = _hasConnection(results);
        if (online != _isOnline) {
          _isOnline = online;
          _controller.add(online);
        }
      },
    );
  }

  void dispose() {
    _sub.cancel();
    _controller.close();
  }

  static bool _hasConnection(List<ConnectivityResult> results) =>
      results.any(
        (ConnectivityResult r) => r != ConnectivityResult.none,
      );

  /// Registers [ConnectivityService] as a lazy singleton in [GetIt].
  static void register() {
    GetIt.I.registerLazySingleton<ConnectivityService>(
      ConnectivityService._,
    );
  }
}

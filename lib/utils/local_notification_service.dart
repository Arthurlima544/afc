import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import '../config/routes/router.dart';

/// Wraps FlutterLocalNotificationsPlugin and exposes typed helpers used
/// by SyncQueue to surface offline-sync status to the user.
///
/// Register once via [LocalNotificationService.register], then access the
/// singleton with [LocalNotificationService.instance].
class LocalNotificationService {
  LocalNotificationService._();

  static LocalNotificationService get instance =>
      GetIt.I<LocalNotificationService>();

  static const int _pendingId = 1001;
  static const int _successId = 1002;
  static const int _failureId = 1003;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestSoundPermission: false,
    );
    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        router.push('/pendencias');
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Shows (or updates) the persistent "N ops pending" notification.
  Future<void> showPendingOps(int count) async {
    final String body = count == 1
        ? '1 operação aguardando sincronização — toque para ver'
        : '$count operações aguardando sincronização — toque para ver';

    await _plugin.show(
      id: _pendingId,
      title: 'Sincronização pendente',
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'sync_pending',
          'Sincronização pendente',
          channelDescription:
              'Notificações sobre operações offline aguardando sync',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentBadge: true,
          presentSound: false,
        ),
      ),
    );
  }

  /// Cancels the persistent notification and shows a one-shot success toast.
  Future<void> showSyncSuccess() async {
    await _plugin.cancel(id: _pendingId);
    await _plugin.show(
      id: _successId,
      title: 'Sincronizado',
      body: 'Dados sincronizados com sucesso',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'sync_status',
          'Status de sincronização',
          channelDescription: 'Confirmações de sincronização concluída',
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  /// Shows a one-shot failure notification when ops have exceeded retry limit.
  Future<void> showSyncFailure(int count) async {
    final String body = count == 1
        ? 'Falha ao sincronizar 1 operação — verifique sua conexão'
        : 'Falha ao sincronizar $count operações — verifique sua conexão';

    await _plugin.show(
      id: _failureId,
      title: 'Falha na sincronização',
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'sync_failure',
          'Falha na sincronização',
          channelDescription: 'Alertas de falha na sincronização de dados',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Registration
  // ---------------------------------------------------------------------------

  static void register() {
    GetIt.I.registerLazySingleton<LocalNotificationService>(
      LocalNotificationService._,
    );
  }
}

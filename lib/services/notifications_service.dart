import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1) Inicializar timezones
    tz.initializeTimeZones();

    // 2) Fijar zona local (IMPORTANTÍSIMO)
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    // Canal Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'citas_channel',
      'Recordatorios de citas',
      description: 'Notificaciones para recordatorios de citas',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Para Android 12+ exact alarms (a veces es necesario)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'citas_channel',
      'Recordatorios de citas',
      channelDescription: 'Notificaciones para recordatorios de citas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      999,
      'Prueba SC Ventas',
      'Si ves esto, las notificaciones funcionan 🔥',
      details,
    );
  }

  // ✅ PROGRAMAR NOTIFICACIÓN REAL
  static Future<void> programarNotificacion({
    required int notificationId,
    required String titulo,
    required String mensaje,
    required DateTime fechaHora,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'citas_channel',
      'Recordatorios de citas',
      channelDescription: 'Notificaciones para recordatorios de citas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    final fechaTz = tz.TZDateTime.from(fechaHora, tz.local);

    await _plugin.zonedSchedule(
      notificationId,
      titulo,
      mensaje,
      fechaTz,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelarNotificacion(int notificationId) async {
    await _plugin.cancel(notificationId);
  }
}






import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // static Future<void> testScheduleIn30s() async {
  //   final when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30));

  //   print("SCHED NOW: ${tz.TZDateTime.now(tz.local)}");
  //   print("SCHED AT : $when");

  //   await _notifications.zonedSchedule(
  //     1,
  //     'TEST',
  //     'Should fire in 30 seconds',
  //     when,
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'med_channel_main', // ✅ SAME as init()
  //         'Medication Reminder',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         playSound: true,
  //         enableVibration: true,
  //       ),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    // 🔥 ADD THIS BLOCK HERE
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'med_channel_main',
      'Medication Reminder',
      description: 'Medication reminders with sound',
      importance: Importance.max,
      playSound: true,
      //sound: RawResourceAndroidNotificationSound('alarm'),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 🔽 KEEP THIS
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);
    //tz.setLocalLocation(tz.getLocation('America/New_York'));
  }

  static Future<void> scheduleNotification(
    String title,
    String body,
    int hour,
    int minute,
  ) async {
    final now = tz.TZDateTime.now(tz.local);

    final scheduledDate =
        tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        ).isBefore(now)
        ? tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day + 1,
            hour,
            minute,
          )
        : tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    print("📅 Scheduled for: $scheduledDate"); // 🔥 DEBUG
    print("NOW: ${tz.TZDateTime.now(tz.local)}");
    print("SCHEDULED: $scheduledDate");
    await _notifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel_main', // ✅ MUST MATCH CHANNEL
          'Medication Reminder',
          importance: Importance.max,
          //priority: Priority.high,
          playSound: true,
          // enableVibration: true,
          // fullScreenIntent: true,

          // largeIcon: DrawableResourceAndroidBitmap('icon'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(Duration(days: 1));
    }

    return scheduled;
  }
}

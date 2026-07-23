import 'package:home_widget/home_widget.dart';

class WidgetService {

  /// Update the home screen widget with next prayer data
  static Future<void> updateWidget({
    required String prayerName,
    required String prayerTime,
    required String countdown,
    String appTitle = 'Ezan Hatırlatıcı',
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('prayer_name', prayerName);
      await HomeWidget.saveWidgetData<String>('prayer_time', prayerTime);
      await HomeWidget.saveWidgetData<String>('countdown', countdown);
      await HomeWidget.saveWidgetData<String>('app_title', appTitle);
      await HomeWidget.updateWidget(
        name: 'PrayerWidgetReceiver',
        androidName: 'PrayerWidgetReceiver',
      );
    } catch (_) {
      // Widget may not be placed yet, silently ignore
    }
  }
}

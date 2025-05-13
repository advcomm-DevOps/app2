import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

final sharedPrefsService = SharedPrefsService();

class SharedPrefsService {
  late final SharedPreferences _prefs;
  final _selectedChannelId = signal<String?>(null);

  String? get selectedChannelId => _selectedChannelId.value;
  set selectedChannelId(String? value) => _selectedChannelId.value = value;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _selectedChannelId.value = _prefs.getString('selected_channel');

    // Auto-save when value changes
    effect(() {
      if (_selectedChannelId.value != null) {
        _prefs.setString('selected_channel', _selectedChannelId.value!);
      }
    });
  }
}

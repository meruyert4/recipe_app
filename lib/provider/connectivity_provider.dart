import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true; // Изначально можно true, _checkInitialConnection скорректирует
  late StreamSubscription<ConnectivityResult> _subscription; // Правильный тип
  Timer? _debounceTimer;

  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _initialize();
  }

  void _initialize() {
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult status) { // status - одиночный ConnectivityResult
      print('Connectivity status changed: $status. Current _isOnline: $_isOnline');

      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

      final newOnlineStatus = status != ConnectivityResult.none;

      if (newOnlineStatus != _isOnline) {
        _isOnline = newOnlineStatus;
        print('Connectivity changed immediately: isOnline = $_isOnline due to $status');
        notifyListeners();
      } else if (!newOnlineStatus && !_isOnline) {
        // Получили 'none', и уже были 'offline'. Это наш проблемный случай при включении Wi-Fi.
        print('Received $status, already offline. Scheduling a re-check.');
        _debounceTimer = Timer(Duration(seconds: 2), () async {
          print('Re-checking connectivity after delay...');
          ConnectivityResult currentActualStatus;
          try {
              currentActualStatus = await Connectivity().checkConnectivity();
          } catch (e) {
              print('Error during delayed re-check: $e');
              currentActualStatus = ConnectivityResult.none;
          }

          print('Delayed re-check status: $currentActualStatus');
          final recheckOnlineStatus = currentActualStatus != ConnectivityResult.none;
          if (recheckOnlineStatus != _isOnline) {
            _isOnline = recheckOnlineStatus;
            print('Connectivity changed after delayed re-check: isOnline = $_isOnline');
            notifyListeners();
          } else {
            print('Delayed re-check: No change in online status ($_isOnline).');
          }
        });
      } else {
         print('No change in online status ($newOnlineStatus). Status was $status.');
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    ConnectivityResult initialStatus;
    try {
        initialStatus = await Connectivity().checkConnectivity();
    } catch (e) {
        print('Error checking initial connectivity: $e');
        initialStatus = ConnectivityResult.none; // Предполагаем 'none' при ошибке
    }
    print('Initial connectivity status: $initialStatus');
    final online = initialStatus != ConnectivityResult.none;
    if (online != _isOnline) { // Сравниваем с текущим _isOnline (который может быть true по умолчанию)
      _isOnline = online;
      print('Initial check: isOnline set to $_isOnline');
      notifyListeners();
    } else {
      print('Initial check: _isOnline ($online) matches initial state ($initialStatus). No notification needed unless forced.');
      // Если _isOnline изначально был true и initialStatus тоже wifi/mobile, то уведомление не нужно.
      // Если _isOnline изначально был true, а initialStatus none, то блок if выше сработает.
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
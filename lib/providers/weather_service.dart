/*
 * FLauncher — version Edgar & Margot
 * Météo via Open-Meteo (gratuit, sans clé).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DayForecast {
  final DateTime date;
  final int code;
  final double max;
  final double min;

  const DayForecast(this.date, this.code, this.max, this.min);
}

class WeatherService extends ChangeNotifier {
  static const String cityName = 'Igny';
  static const double _latitude = 48.7385;
  static const double _longitude = 2.2253;

  double? _temperature;
  int? _code;
  bool _isDay = true;
  List<DayForecast> _forecast = const [];
  Timer? _timer;

  double? get temperature => _temperature;
  int? get code => _code;
  bool get isDay => _isDay;
  List<DayForecast> get forecast => _forecast;
  bool get hasData => _temperature != null && _code != null;

  WeatherService() {
    refresh();
    _timer = Timer.periodic(const Duration(minutes: 30), (_) => refresh());
  }

  Future<void> refresh() async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$_latitude',
      'longitude': '$_longitude',
      'current': 'temperature_2m,weather_code,is_day',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'timezone': 'Europe/Paris',
      'forecast_days': '4',
    });

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        return;
      }
      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json = jsonDecode(body);

      final current = json['current'] as Map<String, dynamic>;
      _temperature = (current['temperature_2m'] as num).toDouble();
      _code = (current['weather_code'] as num).toInt();
      _isDay = (current['is_day'] as num).toInt() == 1;

      final daily = json['daily'] as Map<String, dynamic>;
      final List times = daily['time'];
      final List codes = daily['weather_code'];
      final List maxs = daily['temperature_2m_max'];
      final List mins = daily['temperature_2m_min'];
      final List<DayForecast> days = [];
      // On saute aujourd'hui (index 0) : on affiche les 3 jours suivants.
      for (int i = 1; i < times.length && days.length < 3; i++) {
        days.add(DayForecast(
          DateTime.parse(times[i] as String),
          (codes[i] as num).toInt(),
          (maxs[i] as num).toDouble(),
          (mins[i] as num).toDouble(),
        ));
      }
      _forecast = days;
      notifyListeners();
    } catch (e) {
      debugPrint('Météo indisponible : $e');
    } finally {
      client.close(force: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Codes météo WMO -> description courte en français.
  static String describe(int code) {
    if (code == 0) return 'dégagé';
    if (code <= 2) return 'éclaircies';
    if (code == 3) return 'nuageux';
    if (code == 45 || code == 48) return 'brouillard';
    if (code >= 51 && code <= 57) return 'bruine';
    if (code >= 61 && code <= 67) return 'pluie';
    if (code >= 71 && code <= 77) return 'neige';
    if (code >= 80 && code <= 82) return 'averses';
    if (code == 85 || code == 86) return 'averses de neige';
    if (code >= 95) return 'orage';
    return 'variable';
  }

  /// Codes météo WMO -> icône.
  static IconData icon(int code, {bool isDay = true}) {
    if (code == 0) return isDay ? Icons.wb_sunny_outlined : Icons.nightlight_outlined;
    if (code <= 2) return isDay ? Icons.wb_cloudy_outlined : Icons.nights_stay_outlined;
    if (code == 3) return Icons.cloud_outlined;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 67) return Icons.water_drop_outlined;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 80 && code <= 82) return Icons.umbrella_outlined;
    if (code == 85 || code == 86) return Icons.ac_unit;
    if (code >= 95) return Icons.thunderstorm_outlined;
    return Icons.cloud_outlined;
  }

  static Color iconColor(int code, {bool isDay = true}) {
    if (code == 0 && isDay) return const Color(0xFFFF9F0A);
    if (code >= 95) return const Color(0xFF8E7CC3);
    return const Color(0xFF8E8E93);
  }
}

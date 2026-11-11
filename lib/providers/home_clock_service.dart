/*
 * FLauncher — version Edgar & Margot
 * Horloge partagée : heure, jour/soir, message d'accueil, couleurs.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'dart:async';

import 'package:flutter/material.dart';

class HomePalette {
  final Color background;
  final Color text;
  final Color secondaryText;
  final Color mutedText;
  final Color divider;

  const HomePalette({
    required this.background,
    required this.text,
    required this.secondaryText,
    required this.mutedText,
    required this.divider,
  });

  /// Journée : gris perle, texte sombre.
  static const day = HomePalette(
    background: Color(0xFFE8EAEE),
    text: Color(0xFF1C1C1E),
    secondaryText: Color(0xFF6E6E73),
    mutedText: Color(0xFF8E8E93),
    divider: Color(0xFFC7C7CC),
  );

  /// Soir : gris ardoise, texte clair.
  static const evening = HomePalette(
    background: Color(0xFF3D4656),
    text: Color(0xFFFFFFFF),
    secondaryText: Color(0xFFC3C9D4),
    mutedText: Color(0xFFAAB2C0),
    divider: Color(0xFF5A6476),
  );
}

class HomeClockService extends ChangeNotifier {
  static const String householdNames = 'Edgar et Margot';
  static const int eveningStartHour = 19;
  static const int dayStartHour = 7;

  DateTime _now = DateTime.now();
  Timer? _timer;

  HomeClockService() {
    _scheduleNextTick();
  }

  DateTime get now => _now;

  bool get isEvening => _now.hour >= eveningStartHour || _now.hour < dayStartHour;

  HomePalette get palette => isEvening ? HomePalette.evening : HomePalette.day;

  String get greeting {
    final h = _now.hour;
    final String hello;
    if (h >= 5 && h < 12) {
      hello = 'Bonjour';
    } else if (h >= 12 && h < 18) {
      hello = 'Bon après-midi';
    } else {
      hello = 'Bonsoir';
    }
    return '$hello, $householdNames';
  }

  // On se cale sur le début de chaque minute pour que l'heure change pile.
  void _scheduleNextTick() {
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    _timer = Timer(next.difference(now) + const Duration(milliseconds: 50), () {
      _now = DateTime.now();
      notifyListeners();
      _scheduleNextTick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

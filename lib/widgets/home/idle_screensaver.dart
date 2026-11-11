/*
 * FLauncher — version Edgar & Margot
 * Économiseur d'écran : grande horloge + météo après quelques minutes sans
 * utiliser la télécommande sur l'écran d'accueil. N'importe quelle touche le ferme.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'dart:async';

import 'package:flauncher/providers/home_clock_service.dart';
import 'package:flauncher/providers/weather_service.dart';
import 'package:flauncher/widgets/home/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IdleScreensaver extends StatefulWidget {
  static const Duration idleDelay = Duration(minutes: 5);

  final Widget child;

  const IdleScreensaver({super.key, required this.child});

  @override
  State<IdleScreensaver> createState() => _IdleScreensaverState();
}

class _IdleScreensaverState extends State<IdleScreensaver> with WidgetsBindingObserver {
  Timer? _idleTimer;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_onKey);
    _resetTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    HardwareKeyboard.instance.removeHandler(_onKey);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _wake();
    } else {
      // Une autre appli est au premier plan : pas d'économiseur.
      _idleTimer?.cancel();
    }
  }

  bool _onKey(KeyEvent event) {
    if (_active) {
      // La première touche sert juste à réveiller l'écran.
      if (event is KeyUpEvent) {
        _wake();
      }
      return true;
    }
    _resetTimer();
    return false;
  }

  void _wake() {
    if (_active && mounted) {
      setState(() => _active = false);
    }
    _resetTimer();
  }

  void _resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(IdleScreensaver.idleDelay, () {
      if (mounted) {
        setState(() => _active = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget.child,
          IgnorePointer(
            ignoring: !_active,
            child: AnimatedOpacity(
              opacity: _active ? 1 : 0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: const _ScreensaverContent(),
            ),
          ),
        ],
      );
}

class _ScreensaverContent extends StatelessWidget {
  const _ScreensaverContent();

  @override
  Widget build(BuildContext context) {
    final now = context.watch<HomeClockService>().now;
    final weather = context.watch<WeatherService>();

    return Container(
      color: const Color(0xFF14171D),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('HH:mm', 'fr_FR').format(now),
            style: const TextStyle(
              fontSize: 150,
              height: 1.0,
              fontWeight: FontWeight.w300,
              letterSpacing: -4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            capitalize(DateFormat('EEEE d MMMM', 'fr_FR').format(now)),
            style: const TextStyle(fontSize: 24, color: Color(0xFF9AA3B5)),
          ),
          if (weather.hasData) ...[
            const SizedBox(height: 28),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  WeatherService.icon(weather.code!, isDay: weather.isDay),
                  size: 26,
                  color: const Color(0xFFC3C9D4),
                ),
                const SizedBox(width: 10),
                Text(
                  '${weather.temperature!.round()}° · ${WeatherService.cityName}',
                  style: const TextStyle(fontSize: 22, color: Color(0xFFC3C9D4)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

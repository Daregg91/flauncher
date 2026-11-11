/*
 * FLauncher — version Edgar & Margot
 * En-tête : heure + date à gauche, météo d'Igny à droite.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'package:flauncher/providers/home_clock_service.dart';
import 'package:flauncher/providers/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final clock = context.watch<HomeClockService>();
    final palette = clock.palette;
    final now = clock.now;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm', 'fr_FR').format(now),
              style: TextStyle(
                fontSize: 64,
                height: 1.0,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.5,
                color: palette.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              capitalize(DateFormat('EEEE d MMMM', 'fr_FR').format(now)),
              style: TextStyle(fontSize: 20, color: palette.secondaryText),
            ),
          ],
        ),
        const Spacer(),
        const _WeatherBlock(),
      ],
    );
  }
}

class _WeatherBlock extends StatelessWidget {
  const _WeatherBlock();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<HomeClockService>().palette;
    final weather = context.watch<WeatherService>();

    if (!weather.hasData) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          WeatherService.icon(weather.code!, isDay: weather.isDay),
          size: 44,
          color: WeatherService.iconColor(weather.code!, isDay: weather.isDay),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${weather.temperature!.round()}°',
              style: TextStyle(fontSize: 40, height: 1.0, fontWeight: FontWeight.w500, color: palette.text),
            ),
            const SizedBox(height: 4),
            Text(
              '${WeatherService.cityName} · ${WeatherService.describe(weather.code!)}',
              style: TextStyle(fontSize: 15, color: palette.secondaryText),
            ),
          ],
        ),
        if (weather.forecast.isNotEmpty) ...[
          const SizedBox(width: 24),
          Container(width: 1, height: 56, color: palette.divider),
          const SizedBox(width: 12),
          for (final day in weather.forecast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    capitalize(DateFormat('E', 'fr_FR').format(day.date).replaceAll('.', '')),
                    style: TextStyle(fontSize: 14, color: palette.secondaryText),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    WeatherService.icon(day.code),
                    size: 24,
                    color: WeatherService.iconColor(day.code),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.max.round()}°',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: palette.text),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

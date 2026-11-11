/*
 * FLauncher — version Edgar & Margot
 * Pied de page : message d'accueil à gauche, minuteur / Wi-Fi / réglages à droite.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'package:flauncher/providers/home_clock_service.dart';
import 'package:flauncher/providers/sleep_timer_service.dart';
import 'package:flauncher/widgets/home/all_apps_dialog.dart';
import 'package:flauncher/widgets/network_widget.dart';
import 'package:flauncher/widgets/settings/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final clock = context.watch<HomeClockService>();
    final palette = clock.palette;
    final sleep = context.watch<SleepTimerService>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(clock.greeting, style: TextStyle(fontSize: 18, color: palette.mutedText)),
        const Spacer(),
        if (sleep.isActive)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              'Veille dans ${sleep.remainingLabel}',
              style: TextStyle(fontSize: 15, color: palette.secondaryText),
            ),
          ),
        HomeIconButton(
          icon: Icons.apps,
          tooltip: 'Toutes les applis',
          onPressed: () => showDialog(context: context, builder: (_) => const AllAppsDialog()),
        ),
        const SizedBox(width: 8),
        HomeIconButton(
          icon: sleep.isActive ? Icons.bedtime : Icons.bedtime_outlined,
          tooltip: 'Minuteur de veille',
          onPressed: () => showDialog(context: context, builder: (_) => const SleepTimerDialog()),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: IconTheme(
            data: IconThemeData(color: palette.mutedText, size: 26),
            child: const NetworkWidget(),
          ),
        ),
        const SizedBox(width: 8),
        HomeIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Réglages',
          onPressed: () => showDialog(context: context, builder: (_) => const SettingsPanel()),
        ),
      ],
    );
  }
}

/// Bouton rond discret, bien visible quand il a le focus de la télécommande.
class HomeIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const HomeIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed});

  @override
  State<HomeIconButton> createState() => _HomeIconButtonState();
}

class _HomeIconButtonState extends State<HomeIconButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<HomeClockService>().palette;

    return Semantics(
      button: true,
      label: widget.tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: widget.onPressed,
        onFocusChange: (f) => setState(() => _focused = f),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _focused ? palette.text : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 26,
            color: _focused ? palette.background : palette.mutedText,
          ),
        ),
      ),
    );
  }
}

class SleepTimerDialog extends StatelessWidget {
  const SleepTimerDialog({super.key});

  static const _choices = <(String, Duration)>[
    ('30 min', Duration(minutes: 30)),
    ('1 h', Duration(hours: 1)),
    ('1 h 30', Duration(minutes: 90)),
    ('2 h', Duration(hours: 2)),
  ];

  @override
  Widget build(BuildContext context) {
    final sleep = context.watch<SleepTimerService>();

    return AlertDialog(
      backgroundColor: const Color(0xFF2B3240),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Mettre en veille dans…', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (sleep.isActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Veille prévue dans ${sleep.remainingLabel}.',
                style: const TextStyle(color: Color(0xFFC3C9D4), fontSize: 15),
              ),
            ),
          for (int i = 0; i < _choices.length; i++)
            _DialogChoice(
              label: _choices[i].$1,
              autofocus: i == 0,
              onPressed: () {
                sleep.start(_choices[i].$2);
                Navigator.of(context).pop();
              },
            ),
          if (sleep.isActive)
            _DialogChoice(
              label: 'Annuler le minuteur',
              onPressed: () {
                sleep.cancel();
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

class _DialogChoice extends StatefulWidget {
  final String label;
  final bool autofocus;
  final VoidCallback onPressed;

  const _DialogChoice({required this.label, required this.onPressed, this.autofocus = false});

  @override
  State<_DialogChoice> createState() => _DialogChoiceState();
}

class _DialogChoiceState extends State<_DialogChoice> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          autofocus: widget.autofocus,
          borderRadius: BorderRadius.circular(12),
          focusColor: Colors.transparent,
          onTap: widget.onPressed,
          onFocusChange: (f) => setState(() => _focused = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _focused ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 17,
                color: _focused ? const Color(0xFF1C1C1E) : Colors.white,
              ),
            ),
          ),
        ),
      );
}

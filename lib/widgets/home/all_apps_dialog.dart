/*
 * FLauncher — version Edgar & Margot
 * Fenêtre « Toutes les applis » : grille de toutes les applis installées.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

import 'dart:typed_data';

import 'package:flauncher/models/app.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllAppsDialog extends StatelessWidget {
  const AllAppsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appsService = context.watch<AppsService>();
    final apps = appsService.applications.where((app) => !app.hidden).toList();

    return Dialog(
      backgroundColor: const Color(0xFF2B3240),
      insetPadding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Toutes les applis',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 130,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: apps.length,
                itemBuilder: (context, index) => _AppTile(app: apps[index], autofocus: index == 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTile extends StatefulWidget {
  final App app;
  final bool autofocus;

  const _AppTile({required this.app, this.autofocus = false});

  @override
  State<_AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<_AppTile> {
  bool _focused = false;
  late final Future<Uint8List> _icon;

  @override
  void initState() {
    super.initState();
    _icon = context.read<AppsService>().getAppIcon(widget.app.packageName);
  }

  @override
  Widget build(BuildContext context) => InkWell(
        autofocus: widget.autofocus,
        borderRadius: BorderRadius.circular(14),
        focusColor: Colors.transparent,
        onFocusChange: (f) => setState(() => _focused = f),
        onTap: () {
          Navigator.of(context).pop();
          context.read<AppsService>().launchApp(widget.app);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _focused ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: FutureBuilder<Uint8List>(
                  future: _icon,
                  builder: (context, snapshot) => snapshot.hasData && snapshot.data!.isNotEmpty
                      ? Image.memory(snapshot.data!, fit: BoxFit.contain)
                      : const Icon(Icons.apps, color: Colors.white54, size: 40),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.app.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _focused ? const Color(0xFF1C1C1E) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
}

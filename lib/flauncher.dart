/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


import 'package:flauncher/custom_traversal_policy.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/apps_grid.dart';
import 'package:flauncher/widgets/category_row.dart';
import 'package:flauncher/widgets/launcher_alternative_view.dart';
import 'package:flauncher/providers/home_clock_service.dart';
import 'package:flauncher/widgets/home/home_footer.dart';
import 'package:flauncher/widgets/home/home_header.dart';
import 'package:flauncher/widgets/home/idle_screensaver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'models/category.dart';

class FLauncher extends StatelessWidget {
  const FLauncher();

  @override
  Widget build(BuildContext context) => IdleScreensaver(
    child: FocusTraversalGroup(
      policy: RowByRowTraversalPolicy(),
      child: Stack(
        children: [
          Consumer2<WallpaperService, HomeClockService>(
            builder: (_, wallpaperService, clock, __) => _wallpaper(context, wallpaperService, clock)
          ),
          Consumer<LauncherState>(
            builder: (_, state, child) => Visibility(
              child: child!,
              replacement: const Center(
                child: AlternativeLauncherView()
              ),
              visible: state.launcherVisible
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(56, 36, 56, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const HomeHeader(),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Consumer<AppsService>(
                          builder: (context, appsService, _) {
                            if (appsService.initialized) {
                              return Center(
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  child: _sections(appsService.launcherSections)
                                )
                              );
                            }
                            else {
                              return _emptyState(context);
                            }
                          }
                        ),
                      ),
                      const SizedBox(height: 12),
                      const HomeFooter(),
                    ],
                  ),
                ),
              )
            )
          )
        ]
      )
    ),
  );

  Widget _sections(List<LauncherSection> sections) => Column(
    children: sections.map((section) {
      final Key sectionKey = Key(section.id.toString());
      final Widget categoryWidget;

      if (section is LauncherSpacer) {
        return SizedBox(key: sectionKey, height: section.height.toDouble());
      }

      Category category = section as Category;
      switch (category.type) {
        case CategoryType.row:
          categoryWidget = CategoryRow(
              key: sectionKey,
              category: category,
              applications: category.applications
          );
        case CategoryType.grid:
          categoryWidget = AppsGrid(
              key: sectionKey,
              category: category,
              applications: category.applications
          );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: categoryWidget
      );
    }).toList(),
  );

  Widget _wallpaper(BuildContext context, WallpaperService wallpaperService, HomeClockService clock) {
    if (wallpaperService.wallpaper != null) {
      final physicalSize = MediaQuery.sizeOf(context);
      return Image(
        image: wallpaperService.wallpaper!,
        key: const Key("background"),
        fit: BoxFit.cover,
        height: physicalSize.height,
        width: physicalSize.width
      );
    }
    else {
      // Fond uni qui suit la journée : gris perle le jour, ardoise le soir.
      return AnimatedContainer(
        key: const Key("background"),
        duration: const Duration(seconds: 2),
        color: clock.palette.background,
      );
    }
  }

  Widget _emptyState(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(localizations.loading, style: TextStyle(fontSize: 20, color: context.read<HomeClockService>().palette.secondaryText)),
        ],
      ),
    );
  }
}

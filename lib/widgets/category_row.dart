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

import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/app_card.dart';
import 'package:flauncher/widgets/category_container_common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app.dart';
import '../models/category.dart';
import '../providers/home_clock_service.dart';
import '../providers/settings_service.dart';

class CategoryRow extends StatelessWidget
{
  final Category category;
  final List<App> applications;

  CategoryRow({
    Key? key,
    required this.category,
    required this.applications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget categoryContent;
    if (applications.isEmpty) {
      categoryContent = categoryContainerEmptyState(context);
    }
    else {
      // La rangée s'adapte à la largeur de l'écran : toutes les applis
      // tiennent sur une ligne (jusqu'à 6), sans dépasser la hauteur réglée.
      categoryContent = LayoutBuilder(
        builder: (context, constraints) {
          const double gap = 16;
          final int visible = applications.length.clamp(1, 6);
          final double cardWidth = (constraints.maxWidth - 16 - gap * visible) / visible;
          final double fitHeight = cardWidth * 9 / 16 + 16;
          final double height = fitHeight < category.rowHeight ? fitHeight : category.rowHeight.toDouble();

          return SizedBox(
            height: height,
            child: Center(
              child: ListView.custom(
                shrinkWrap: true,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.all(8),
                scrollDirection: Axis.horizontal,
                childrenDelegate: SliverChildBuilderDelegate(
                  childCount: applications.length,
                  findChildIndexCallback: _findChildIndex,
                  (context, index) => Padding(
                      key: Key(applications[index].packageName),
                      padding: const EdgeInsets.symmetric(horizontal: gap / 2),
                      child: AppCard(
                        category: category,
                        application: applications[index],
                        autofocus: index == 0,
                        onMove: (direction) => _onMove(context, direction, index),
                        onMoveEnd: () => _onMoveEnd(context)
                      )
                  )
                )
              ),
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Selector<SettingsService, bool>(
          selector: (context, service) => service.showCategoryTitles,
          builder: (context, showCategoriesTitle, _) {
            if (showCategoriesTitle) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(category.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: context.watch<HomeClockService>().palette.secondaryText,
                  )
                ),
              );
            }

            return SizedBox.shrink();
          }
        ),
        categoryContent
      ],
    );
  }

  int _findChildIndex(Key key) =>
      applications.indexWhere((app) => app.packageName == (key as ValueKey<String>).value);

  void _onMove(BuildContext context, AxisDirection direction, int index) {
    int newIndex = 0;

    if (direction == AxisDirection.right && index < applications.length - 1) {
      newIndex = index + 1;
    } else if (direction == AxisDirection.left && index > 0) {
      newIndex = index - 1;
    } else {
      return;
    }

    final appsService = context.read<AppsService>();
    appsService.reorderApplication(category, index, newIndex);
  }

  void _onMoveEnd(BuildContext context) {
    final appsService = context.read<AppsService>();
    appsService.saveApplicationOrderInCategory(category);
  }
}

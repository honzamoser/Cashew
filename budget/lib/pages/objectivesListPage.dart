import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/widgetSize.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart'
    hide SliverReorderableList, ReorderableDelayedDragStartListener;
import 'package:provider/provider.dart';

class ObjectivesListPage extends StatefulWidget {
  const ObjectivesListPage({Key? key}) : super(key: key);

  @override
  State<ObjectivesListPage> createState() => ObjectivesListPageState();
}

class ObjectivesListPageState extends State<ObjectivesListPage> {
  @override
  Widget build(BuildContext context) {
    Widget addButton = Padding(
      padding: EdgeInsets.only(top: getPlatform() == PlatformOS.isIOS ? 10 : 0),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getPlatform() == PlatformOS.isIOS ? 13 : 0,
        ),
        child: AddButton(
          onTap: () {},
          openPage: AddObjectivePage(
            routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete,
          ),
          height: 150,
        ),
      ),
    );

    return PageFramework(
      dragDownToDismiss: true,
      title: "objectives".tr(),
      backButton: false,
      horizontalPadding: enableDoubleColumn(context) == false
          ? getHorizontalPaddingConstrained(context)
          : 0,
      actions: [
        IconButton(
          padding: EdgeInsets.all(15),
          tooltip: "edit-objectives".tr(),
          onPressed: () {
            pushRoute(
              context,
              EditObjectivesPage(),
            );
          },
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.edit_outlined
                : Icons.edit_rounded,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ],
      slivers: [
        StreamBuilder<List<Objective>>(
          stream: database.watchAllObjectives(),
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
              return SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 13),
                sliver: SliverToBoxAdapter(
                  child: addButton,
                ),
              );
            }
            if (snapshot.hasData) {
              return SliverPadding(
                padding: EdgeInsets.symmetric(
                  vertical: getPlatform() == PlatformOS.isIOS ? 3 : 7,
                  horizontal: getPlatform() == PlatformOS.isIOS ? 0 : 13,
                ),
                sliver: enableDoubleColumn(context)
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 600.0,
                          mainAxisExtent: 160,
                          mainAxisSpacing:
                              getPlatform() == PlatformOS.isIOS ? 0 : 10.0,
                          crossAxisSpacing:
                              getPlatform() == PlatformOS.isIOS ? 0 : 10.0,
                          childAspectRatio: 5,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (index == snapshot.data?.length) {
                              return addButton;
                            } else {
                              return ObjectiveContainer(
                                index: index,
                                objective: snapshot.data![index],
                              );
                            }
                          },
                          childCount: (snapshot.data?.length ?? 0) + 1,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (index == snapshot.data?.length) {
                              return addButton;
                            } else {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: getPlatform() == PlatformOS.isIOS
                                      ? 0
                                      : 16.0,
                                ),
                                child: ObjectiveContainer(
                                  index: index,
                                  objective: snapshot.data![index],
                                ),
                              );
                            }
                          },
                          childCount: (snapshot.data?.length ?? 0) +
                              1, //snapshot.data?.length
                        ),
                      ),
              );
            } else {
              return SliverToBoxAdapter();
            }
          },
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 50),
        ),
      ],
    );
  }
}

class ObjectiveContainer extends StatelessWidget {
  const ObjectiveContainer(
      {required this.objective, required this.index, super.key});
  final Objective objective;
  final int index;

  @override
  Widget build(BuildContext context) {
    double borderRadius = getPlatform() == PlatformOS.isIOS ? 0 : 18;
    return StreamBuilder<double?>(
      stream: database.watchTotalTowardsObjective(
        objective.objectivePk,
      ),
      builder: (context, snapshot) {
        double totalAmount = snapshot.data ?? 0;
        if (objective.income == false) {
          totalAmount = totalAmount * -1;
        }
        double percentageTowardsGoal =
            objective.amount == 0 ? 0 : totalAmount / objective.amount;
        return Column(
          children: [
            OpenContainerNavigation(
              openPage: Container(),
              borderRadius: borderRadius,
              closedColor: getStandardContainerColor(context),
              button: (openContainer()) {
                return Column(
                  children: [
                    getPlatform() == PlatformOS.isIOS && index == 0
                        ? Container(
                            height: 1.5,
                            color: getColor(context, "dividerColor"),
                          )
                        : SizedBox.shrink(),
                    Tappable(
                      onLongPress: () {
                        pushRoute(
                          context,
                          AddObjectivePage(
                            routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                            objective: objective,
                          ),
                        );
                      },
                      color: getStandardContainerColor(context),
                      onTap: () {
                        openContainer();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: getPlatform() == PlatformOS.isIOS ? 23 : 30,
                          right: getPlatform() == PlatformOS.isIOS ? 23 : 20,
                          top: 18,
                          bottom: 21,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFont(
                                        text: objective.name,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      StreamBuilder<int?>(
                                        stream: database
                                            .getTotalCountOfTransactionsInObjective(
                                                objective.objectivePk)
                                            .$1,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return TextFont(
                                              textAlign: TextAlign.left,
                                              text: snapshot.data.toString() +
                                                  " " +
                                                  (snapshot.data == 1
                                                      ? "transaction"
                                                          .tr()
                                                          .toLowerCase()
                                                      : "transactions"
                                                          .tr()
                                                          .toLowerCase()),
                                              fontSize: 15,
                                              textColor:
                                                  getColor(context, "black")
                                                      .withOpacity(0.65),
                                            );
                                          } else {
                                            return TextFont(
                                              textAlign: TextAlign.left,
                                              text: "/ transactions",
                                              fontSize: 15,
                                              textColor:
                                                  getColor(context, "black")
                                                      .withOpacity(0.65),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                CategoryIcon(
                                  categoryPk: "-1",
                                  category: TransactionCategory(
                                    categoryPk: "-1",
                                    name: "",
                                    dateCreated: DateTime.now(),
                                    dateTimeModified: null,
                                    order: 0,
                                    income: false,
                                    iconName: objective.iconName,
                                    colour: objective.colour,
                                    emojiIconName: objective.emojiIconName,
                                  ),
                                  size: 30,
                                  sizePadding: 20,
                                  borderRadius: 100,
                                  canEditByLongPress: false,
                                  margin: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 3),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: TextFont(
                                        text: getWordedDateShortMore(
                                          objective.dateCreated,
                                        ),
                                        fontSize: 15,
                                        textColor: getColor(context, "black")
                                            .withOpacity(0.65),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TextFont(
                                      fontWeight: FontWeight.bold,
                                      text: convertToMoney(
                                          Provider.of<AllWallets>(context),
                                          totalAmount),
                                      fontSize: 24,
                                      textColor: getColor(context, "black"),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 2.5),
                                      child: TextFont(
                                        text: " / " +
                                            convertToMoney(
                                                Provider.of<AllWallets>(
                                                    context),
                                                objective.amount),
                                        fontSize: 15,
                                        textColor: getColor(context, "black")
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            BudgetProgress(
                              color: HexColor(objective.colour),
                              percent: percentageTowardsGoal * 100,
                              todayPercent: -1,
                              showToday: false,
                              yourPercent: 0,
                              padding: EdgeInsets.zero,
                              enableShake: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    getPlatform() == PlatformOS.isIOS
                        ? Container(
                            height: 1.5,
                            color: getColor(context, "dividerColor"),
                          )
                        : SizedBox.shrink(),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

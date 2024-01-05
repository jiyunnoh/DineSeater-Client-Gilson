import 'package:dineseater_client_gilson/model/waiting.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import 'meal_type_viewmodel.dart';

class MealTypeView extends StackedView<MealTypeViewModel> {
  const MealTypeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MealTypeViewModel viewModel,
    Widget? child,
  ) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 60,
          toolbarHeight: 40,
          leading: TextButton(
            onPressed: () => viewModel.navigateBack(),
            child: const Text(
              'Back',
              style: backButtonStyle,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            gilsonIconSmall,
                            verticalSpaceMedium,
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: (viewModel
                                                              .selectedButton ==
                                                          0)
                                                      ? kcPrimaryColor
                                                      : kcLightGreyWithOpacity,
                                                  width: 2),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(20))),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                maxRadius: 40,
                                                backgroundColor:
                                                    (viewModel.selectedButton ==
                                                            0)
                                                        ? kcPrimaryColor
                                                        : kcLightGreyWithOpacity,
                                                child: Image.asset(
                                                  'assets/meal.png',
                                                  scale: 2,
                                                  color:
                                                      (viewModel.selectedButton ==
                                                              0)
                                                          ? Colors.white
                                                          : kcVeryLightGrey,
                                                ),
                                              ),
                                              verticalSpaceMedium,
                                              Text(
                                                'Regular Meal',
                                                style: TextStyle(
                                                    color: (viewModel
                                                                .selectedButton ==
                                                            0)
                                                        ? Colors.black
                                                        : kcVeryLightGrey,
                                                    fontSize: 17,
                                                    fontWeight: (viewModel
                                                                .selectedButton ==
                                                            0)
                                                        ? semiBoldFontWeight
                                                        : FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onTap: () => viewModel.onTapMealType(0),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: (viewModel
                                                              .selectedButton ==
                                                          1)
                                                      ? kcPrimaryColor
                                                      : kcLightGreyWithOpacity,
                                                  width: 2),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(20))),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                maxRadius: 40,
                                                backgroundColor:
                                                    (viewModel.selectedButton ==
                                                            1)
                                                        ? kcPrimaryColor
                                                        : kcLightGreyWithOpacity,
                                                child: Image.asset(
                                                  'assets/grill.png',
                                                  color:
                                                      (viewModel.selectedButton ==
                                                              1)
                                                          ? Colors.white
                                                          : kcVeryLightGrey,
                                                  scale: 2,
                                                ),
                                              ),
                                              verticalSpaceMedium,
                                              Text(
                                                'Barbecue Grill',
                                                style: TextStyle(
                                                    color: (viewModel
                                                                .selectedButton ==
                                                            1)
                                                        ? Colors.black
                                                        : kcVeryLightGrey,
                                                    fontSize: 17,
                                                    fontWeight: (viewModel
                                                                .selectedButton ==
                                                            1)
                                                        ? semiBoldFontWeight
                                                        : FontWeight.normal),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      onTap: () => viewModel.onTapMealType(1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(flex: 2, child: SizedBox())
                          ],
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.9,
                        child: ElevatedButton(
                            onPressed: viewModel.navigateToPartySizeView,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kcPrimaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                elevation: 0),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'Next',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: semiBoldFontWeight),
                              ),
                            )),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  MealTypeViewModel viewModelBuilder(
    BuildContext context,
  ) {
    Waiting waiting = ModalRoute.of(context)?.settings.arguments as Waiting;

    return MealTypeViewModel(waiting: waiting);
  }
}

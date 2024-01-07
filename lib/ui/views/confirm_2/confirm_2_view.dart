import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import 'confirm_2_viewmodel.dart';

class Confirm2View extends StackedView<Confirm2ViewModel> {
  const Confirm2View({Key? key}) : super(key: key);
  // TODO : There should be to 'back' button on this page.
  @override
  Widget builder(
    BuildContext context,
    Confirm2ViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 60,
        toolbarHeight: 40,
        leading: null,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    gilsonIconSmall,
                    Column(
                      children: [
                        Image.asset(
                          'assets/confirm2.png',
                          scale: 2.5,
                        ),
                        verticalSpaceLarge,
                        const Text('You\'re on the list!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('We\'ll text you once ready!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.9,
                      child: ElevatedButton(
                          onPressed: viewModel.navigateToHome,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kcPrimaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              elevation: 0),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'Go to Home',
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
    );
  }

  @override
  Confirm2ViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      Confirm2ViewModel();
}

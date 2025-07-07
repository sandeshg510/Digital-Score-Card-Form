import 'package:digital_score_card_form_for_inspection/core/common/widgets/basics.dart';
import 'package:digital_score_card_form_for_inspection/core/common/widgets/gradient_button.dart';
import 'package:digital_score_card_form_for_inspection/screens/coach_header_form_screen.dart';
import 'package:digital_score_card_form_for_inspection/screens/station_header_form_screen.dart';
import 'package:digital_score_card_form_for_inspection/utils/assets_paths.dart';
import 'package:flutter/material.dart';

import '../core/common/widgets/gradient_app_bar.dart';

class HomeScreen extends StatelessWidget with CommonWidgets {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: GradientAppBar(title: 'Digital Score Card App'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: SingleChildScrollView(
          child: Column(
            children: [
              verticalSpace(height: height * 0.1),

              Image.asset(
                height: height * 0.3,
                ImagePaths.instance.brandNameLogoPath,
              ),
              verticalSpace(height: height * 0.1),
              GradientActionButton(
                height: 55,
                label: 'Clean Train Station Inspection',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StationHeaderFormScreen(),
                    ),
                  );
                },
              ),
              verticalSpace(height: 25),
              GradientActionButton(
                height: 55,

                label: 'Coach Inspection',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CoachHeaderFormScreen(),
                    ),
                  );
                },
              ),
              verticalSpace(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

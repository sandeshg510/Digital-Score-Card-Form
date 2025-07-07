import 'package:flutter/material.dart';

import '../../../constants/global_variables.dart';

class GradientTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TabController tabController;
  final List<Container> tabs;
  final List<Widget>? actions;

  const GradientTabAppBar({
    super.key,
    required this.title,
    required this.tabController,
    required this.tabs,
    this.actions,
  });

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 4,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: GlobalVariables.appBarGradient,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: actions,
      bottom: TabBar(
        controller: tabController,
        isScrollable: true,
        labelColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: Colors.white60,
        ),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.2), // Semi-transparent highlight
        ),
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 5,
        tabs: tabs,
      ),
    );
  }
}

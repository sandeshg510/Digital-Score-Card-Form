import 'package:flutter/material.dart';

mixin CommonWidgets {
  SizedBox verticalSpace({required double height}) {
    return SizedBox(height: height);
  }

  SizedBox horizontalSpace({required double width}) {
    return SizedBox(width: width);
  }

  SizedBox emptyContainer() {
    return const SizedBox(height: 0, width: 0);
  }
}

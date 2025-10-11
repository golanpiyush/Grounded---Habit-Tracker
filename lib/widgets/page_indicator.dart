// page_indicator.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final double dotSize = 8.0;
  final double spacing = 12.0;

  const PageIndicatorWidget({
    Key? key,
    required this.currentPage,
    required this.pageCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: index == currentPage
                ? AppColors.primaryGreen
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: index == currentPage
                  ? AppColors.primaryGreen
                  : AppColors.borderColor,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

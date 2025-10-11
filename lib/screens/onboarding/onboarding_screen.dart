// onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/page_indicator.dart';
import 'onboarding_page_1.dart';
import 'onboarding_page_2.dart';
import 'onboarding_page_3.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({Key? key, required this.onCompleted})
    : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final int _pageCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    provider.setCurrentPage(_pageController.page!.round());
  }

  void _nextPage() {
    if (_pageController.page! < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    Provider.of<OnboardingProvider>(
      context,
      listen: false,
    ).completeOnboarding();
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = Provider.of<OnboardingProvider>(context).currentPage;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                children: const [
                  OnboardingPage1(),
                  OnboardingPage2(),
                  OnboardingPage3(),
                ],
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page Indicator
                  PageIndicatorWidget(
                    currentPage: currentPage,
                    pageCount: _pageCount,
                  ),

                  const SizedBox(height: 32),

                  // Next/Get Started Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5016),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        currentPage == _pageCount - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

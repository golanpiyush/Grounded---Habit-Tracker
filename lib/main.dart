import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:grounded/Models/dashboard_Data.dart';
import 'package:grounded/screens/welcome_intro_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/onboarding_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_choice_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/log_in_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'safety_channel',
      channelName: 'Safety Reminders',
      channelDescription: 'Harm reduction tips and safety reminders',
      defaultColor: const Color(0xFF4CAF50),
      ledColor: Colors.white,
      importance: NotificationImportance.High,
      playSound: true,
      enableVibration: true,
    ),
  ]);

  runApp(const MyApp(hasSeenOnboarding: false));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({Key? key, required this.hasSeenOnboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              OnboardingProvider()..setOnboardingCompleted(hasSeenOnboarding),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Grounded - Habit Tracker',
        // theme: ThemeProvider.lightTheme,
        home: const AppNavigator(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  @override
  Widget build(BuildContext context) {
    final onboardingCompleted = Provider.of<OnboardingProvider>(
      context,
    ).onboardingCompleted;
    final authStatus = Provider.of<AuthProvider>(context).status;

    // Show onboarding if not completed
    if (!onboardingCompleted) {
      return OnboardingScreen(onCompleted: _completeOnboarding);
    }

    // Show auth flow if not authenticated
    if (authStatus == AuthStatus.unauthenticated) {
      return AuthChoiceScreen(
        onEmailAuth: _showEmailAuth,
        onAppleAuth: _signInWithApple,
        onGoogleAuth: _signInWithGoogle,
        onGuestContinue: _continueAsGuest,
      );
    }

    // Show home screen for authenticated users
    return DashboardScreen();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Provider.of<OnboardingProvider>(
        context,
        listen: false,
      ).completeOnboarding();
    }
  }

  void _showEmailAuth() {
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SignUpScreen(
            onSignUpSuccess: _onAuthSuccess,
            onLoginTap: _showLogin,
          ),
        ),
      );
    }
  }

  void _showLogin() {
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LogInScreen(
            onLoginSuccess: _onAuthSuccess,
            onSignUpTap: _showEmailAuth,
            onForgotPassword: _showForgotPassword,
          ),
        ),
      );
    }
  }

  void _showForgotPassword() {
    if (mounted) {
      // Implement forgot password flow
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset Password'),
          content: const Text(
            'Password reset functionality would be implemented here.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _signInWithApple() {
    if (mounted) {
      Provider.of<AuthProvider>(context, listen: false).signInWithApple();
    }
  }

  void _signInWithGoogle() {
    if (mounted) {
      Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
    }
  }

  void _continueAsGuest() {
    if (mounted) {
      Provider.of<AuthProvider>(context, listen: false).continueAsGuest();
    }
  }

  void _onAuthSuccess() {
    if (mounted) {
      // Navigate to welcome intro screen first, then goal setup
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => WelcomeIntroScreen(onComplete: _navigateToHome),
        ),
        (route) => false,
      );
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => DashboardScreen()),
        (route) => false,
      );
    }
  }
}

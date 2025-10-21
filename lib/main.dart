import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grounded/providers/userDB.dart';
import 'package:grounded/screens/home_screen.dart';
import 'package:grounded/screens/welcome_intro_screen.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/onboarding_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_choice_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/log_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://eaogxkwnygywdbnhjlap.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVhb2d4a3dueWd5d2RibmhqbGFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5NjYxMDMsImV4cCI6MjA3NTU0MjEwM30.OV7uGd-UkoG3LQ0rdUqnBAgFbaQr33QeVzdCSRSmk2o',
  );
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
  const MyApp({Key? key, required bool hasSeenOnboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MaterialApp(
          title: 'Grounded - Habit Tracker',
          home: const AppNavigator(),
          debugShowCheckedModeBanner: false,
        ),
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
  bool _isChecking = true;
  bool _hasAccount = false;

  @override
  void initState() {
    super.initState();
    _checkAccountStatus();
  }

  Future<void> _checkAccountStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAccount = prefs.getBool('hasAccount') ?? false;

    setState(() {
      _hasAccount = hasAccount;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authProvider = provider.Provider.of<AuthProvider>(context);
    final authStatus = authProvider.status;

    // App Start Logic
    if (!_hasAccount) {
      return OnboardingScreen(onCompleted: _completeOnboarding);
    }

    // Always show Auth Choice if not authenticated
    if (authStatus != AuthStatus.authenticated) {
      return AuthChoiceScreen(
        onEmailAuth: _showEmailAuth,
        onAppleAuth: _signInWithApple,
        onGoogleAuth: _signInWithGoogle,
        onGuestContinue: _continueAsGuest,
      );
    }

    // User is authenticated - handle navigation
    return _handleAuthenticatedUser(authProvider);
  }

  Widget _handleAuthenticatedUser(AuthProvider authProvider) {
    // For guest users - go to welcome screen
    if (authProvider.authMethod == AuthMethod.guest) {
      return WelcomeIntroScreen(onComplete: _navigateToDashboard);
    }

    // For email login - go directly to dashboard
    if (authProvider.authMethod == AuthMethod.email &&
        !authProvider.isNewUser!) {
      return const DashboardScreen();
    }

    // For OAuth users - try to check data, but on error go to auth choice
    return FutureBuilder<bool>(
      future: _checkUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If there's an error or no data, go back to auth choice
        if (snapshot.hasError || !(snapshot.data ?? false)) {
          print('Error or no user data, returning to auth choice');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _goToAuthChoice();
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Has data - go to dashboard
        return const DashboardScreen();
      },
    );
  }

  void _goToAuthChoice() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => AuthChoiceScreen(
          onEmailAuth: _showEmailAuth,
          onAppleAuth: _signInWithApple,
          onGoogleAuth: _signInWithGoogle,
          onGuestContinue: _continueAsGuest,
        ),
      ),
      (route) => false,
    );
  }

  // MARK: - Navigation Methods

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAccount', true);

    setState(() {
      _hasAccount = true;
    });
  }

  void _showEmailAuth() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignUpScreen(
          onSignUpSuccess: _onSignUpSuccess,
          onLoginTap: _showLogin,
        ),
      ),
    );
  }

  void _showLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LogInScreen(
          onLoginSuccess: _onLoginSuccess,
          onSignUpTap: _showEmailAuth,
          onForgotPassword: _showForgotPassword,
        ),
      ),
    );
  }

  Future<void> _signInWithApple() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAccount', true);

    final authProvider = provider.Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    await authProvider.signInWithApple();
  }

  Future<void> _signInWithGoogle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAccount', true);

    final authProvider = provider.Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    await authProvider.signInWithGoogle();
  }

  Future<void> _continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAccount', true);

    await provider.Provider.of<AuthProvider>(
      context,
      listen: false,
    ).continueAsGuest();

    // Navigate to welcome screen for guest users
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            WelcomeIntroScreen(onComplete: _navigateToDashboard),
      ),
      (route) => false,
    );
  }

  // MARK: - Success Handlers

  Future<void> _onSignUpSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAccount', true);

    // New user - go to welcome screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            WelcomeIntroScreen(onComplete: _navigateToDashboard),
      ),
      (route) => false,
    );
  }

  Future<void> _onLoginSuccess() async {
    // Existing user - go directly to dashboard
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  void _showForgotPassword() {
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

  Future<bool> _checkUserData() async {
    try {
      final authProvider = provider.Provider.of<AuthProvider>(
        context,
        listen: false,
      );
      return await authProvider.checkUserHasData();
    } catch (e) {
      print('Error checking user data: $e');
      return false; // Return false on error to trigger auth choice
    }
  }
}

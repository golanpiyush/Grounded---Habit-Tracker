import 'package:Grounded/providers/theme_provider.dart'; // ADDED
import 'package:Grounded/screens/auth/goal_setup_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/screens/home_screen.dart';
import 'package:Grounded/screens/welcome_intro_screen.dart';
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

  // PRE-LOAD SharedPreferences BEFORE running app
  final prefs = await SharedPreferences.getInstance();
  print('📦 SharedPreferences loaded: ${prefs.getString('app_theme_mode')}');

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

  // WRAP ProviderScope WITH OVERRIDE AT THE TOP LEVEL
  runApp(
    ProviderScope(
      overrides: [
        // Override the sharedPreferencesProvider with the pre-loaded instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // NO ProviderScope here - it's already at the top in main()
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Grounded - Habit Tracker',
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
  bool _isChecking = true;
  bool _hasSeenOnboarding = false;
  bool? _hasOnboardingData;
  bool _isCheckingOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;
    setState(() {
      _hasSeenOnboarding = hasSeenOnboarding;
      _isChecking = false;
    });
  }

  Future<void> _checkUserOnboardingData(AuthProvider authProvider) async {
    if (_isCheckingOnboarding || _hasOnboardingData != null) return;

    setState(() {
      _isCheckingOnboarding = true;
    });

    final hasData = await authProvider.checkUserHasOnboardingData();

    if (!mounted) return;
    setState(() {
      _hasOnboardingData = hasData;
      _isCheckingOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('\n🔄 AppNavigator.build() called');
    print('  - _isChecking: $_isChecking');
    print('  - _hasSeenOnboarding: $_hasSeenOnboarding');

    if (_isChecking) {
      print('  → Showing loading (checking onboarding status)');
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authProvider = provider.Provider.of<AuthProvider>(context);
    final authStatus = authProvider.status;

    print('  - authStatus: $authStatus');
    print('  - authMethod: ${authProvider.authMethod}');
    print('  - isNewUser: ${authProvider.isNewUser}');
    print('  - userId: ${authProvider.userId}');

    if (!_hasSeenOnboarding) {
      print('  → Showing OnboardingScreen (not seen before)');
      return OnboardingScreen(onCompleted: _completeOnboarding);
    }

    if (authStatus == AuthStatus.unauthenticated ||
        authStatus == AuthStatus.loading) {
      print('  → Showing AuthChoiceScreen (not authenticated)');
      return AuthChoiceScreen(
        onEmailAuth: _showEmailAuth,
        onAppleAuth: _signInWithApple,
        onGoogleAuth: _signInWithGoogle,
        onGuestContinue: _continueAsGuest,
      );
    }

    print('  → Calling _handleAuthenticatedUser');
    return _handleAuthenticatedUser(authProvider);
  }

  Widget _handleAuthenticatedUser(AuthProvider authProvider) {
    print('\n🔍 _handleAuthenticatedUser called');
    print('  - authMethod: ${authProvider.authMethod}');
    print('  - isNewUser: ${authProvider.isNewUser}');
    print('  - _hasOnboardingData (cached): $_hasOnboardingData');

    if (authProvider.authMethod == AuthMethod.guest) {
      print('  → Guest user: showing WelcomeIntroScreen');
      return WelcomeIntroScreen(onComplete: _navigateToGoalSetup);
    }

    if (authProvider.authMethod == AuthMethod.email &&
        authProvider.isNewUser == true) {
      print('  → New email user: showing WelcomeIntroScreen');
      return WelcomeIntroScreen(onComplete: _navigateToGoalSetup);
    }

    if (authProvider.authMethod == AuthMethod.email) {
      print(
        '  → Email user (isNewUser=${authProvider.isNewUser}): checking onboarding data...',
      );

      if (_hasOnboardingData == null && !_isCheckingOnboarding) {
        print('  → First time checking, triggering database query...');
        _checkUserOnboardingData(authProvider);
      }

      if (_hasOnboardingData == null) {
        print('  → Showing loading (checking data)');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (_hasOnboardingData == true) {
        print('  → Has onboarding data: showing Dashboard');
        return const DashboardScreen();
      } else {
        print('  → No onboarding data: showing WelcomeIntroScreen');
        return WelcomeIntroScreen(onComplete: _navigateToGoalSetup);
      }
    }

    if (authProvider.authMethod == AuthMethod.apple ||
        authProvider.authMethod == AuthMethod.google) {
      print('  → OAuth user: checking onboarding data...');

      if (_hasOnboardingData == null && !_isCheckingOnboarding) {
        print('  → First time checking, triggering database query...');
        _checkUserOnboardingData(authProvider);
      }

      if (_hasOnboardingData == null) {
        print('  → Showing loading (checking data)');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (_hasOnboardingData == true) {
        print('  → Has onboarding data: showing Dashboard');
        return const DashboardScreen();
      } else {
        print('  → No onboarding data: showing WelcomeIntroScreen');
        return WelcomeIntroScreen(onComplete: _navigateToGoalSetup);
      }
    }

    print('  ⚠️ Fallback: showing AuthChoiceScreen (authMethod unknown)');
    return AuthChoiceScreen(
      onEmailAuth: _showEmailAuth,
      onAppleAuth: _signInWithApple,
      onGoogleAuth: _signInWithGoogle,
      onGuestContinue: _continueAsGuest,
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;
    setState(() {
      _hasSeenOnboarding = true;
    });
  }

  void _showEmailAuth() {
    if (!mounted) return;
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
    if (!mounted) return;
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
    final authProvider = provider.Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    await authProvider.signInWithApple();
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = provider.Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    await authProvider.signInWithGoogle();
  }

  Future<void> _continueAsGuest() async {
    final authProvider = provider.Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    await authProvider.continueAsGuest();
  }

  Future<void> _onSignUpSuccess() async {
    print('🎯 _onSignUpSuccess called');
    print('  - mounted: $mounted');

    if (!mounted) {
      print('  ⚠️ Widget not mounted, returning');
      return;
    }

    final authProvider = provider.Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    print('  - Auth status: ${authProvider.status}');
    print('  - Auth method: ${authProvider.authMethod}');
    print('  - Is new user: ${authProvider.isNewUser}');
    print('  - User ID: ${authProvider.userId}');

    _hasOnboardingData = null;

    print('  - Clearing navigation stack...');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AppNavigator()),
      (route) => false,
    );
    print('  ✅ Navigation cleared, AppNavigator will rebuild');
  }

  Future<void> _onLoginSuccess() async {
    print('🎯 _onLoginSuccess called');
    print('  - mounted: $mounted');

    if (!mounted) {
      print('  ⚠️ Widget not mounted, returning');
      return;
    }

    final authProvider = provider.Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    print('  - Auth status: ${authProvider.status}');
    print('  - Auth method: ${authProvider.authMethod}');
    print('  - Is new user: ${authProvider.isNewUser}');
    print('  - User ID: ${authProvider.userId}');

    _hasOnboardingData = null;

    print('  - Clearing navigation stack...');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AppNavigator()),
      (route) => false,
    );
    print('  ✅ Navigation cleared, AppNavigator will rebuild');
  }

  void _navigateToGoalSetup() {
    print('\n🎯 _navigateToGoalSetup called');
    print('  - mounted: $mounted');

    if (!mounted) {
      print('  ⚠️ Widget not mounted, returning');
      return;
    }

    print('  - Navigating to Goal Setup Screen...');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => GoalSetupScreen(onComplete: _onGoalSetupComplete),
      ),
      (route) => false,
    );
    print('  ✅ Navigation to Goal Setup complete');
  }

  void _onGoalSetupComplete() {
    print('\n🎉 _onGoalSetupComplete called');
    print('  - Goal setup completed, navigating to Dashboard');

    if (!mounted) {
      print('  ⚠️ Widget not mounted, returning');
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
    print('  ✅ Navigated to Dashboard');
  }

  void _showForgotPassword() {
    if (!mounted) return;
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

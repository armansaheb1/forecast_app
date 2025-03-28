import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forecast_app/index.dart' as my_index;
import 'package:forecast_app/coffee.dart';
import 'package:forecast_app/horoscope.dart';
import 'package:forecast_app/login.dart';
import 'package:forecast_app/register.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

bool isSelected = false;
bool isAuthenticated = false;

Future<void> select() async {
  isSelected = true;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isSelected', true);
}

Future<void> getData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  isSelected = prefs.getBool('isSelected') ?? false;
  // isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize(); // Initialize Google Ads SDK
  await getData();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

String selectedLanguage = 'en';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fa', 'IR'),
      ],
    );
  }
}

/// Use ShellRoute to wrap screens with a persistent BottomNavigationBar
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => SignInPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const SignUpPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => my_index.HomePage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => my_index.HomePage(),
        ),
        GoRoute(
          path: '/coffee-reading',
          builder: (context, state) => const CoffeeReadingScreen(),
        ),
        GoRoute(
          path: '/horoscope',
          builder: (context, state) => const Horoscope(),
        ),
      ],
    ),
  ],
);

/// MainScreen includes BottomNavigationBar and the AdMob Banner below it.
class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const List<String> _widgetPaths = ['/home', '/history', '/profile'];

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3940256099942544/6300978111', // Replace with your ad unit id
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    )..load();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    GoRouter.of(context).go(_widgetPaths[index]);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main content of the screen
      body: widget.child,
      // Combined bottom navigation bar and ad banner
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bottom Navigation Bar
            BottomNavigationBar(
              backgroundColor: Colors.black,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.history),
                  label: AppLocalizations.of(context)!.history,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.account_circle),
                  label: AppLocalizations.of(context)!.profile,
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              unselectedItemColor: Colors.white,
              onTap: _onItemTapped,
            ),
            // Ad banner below the bottom navigation bar
            if (_isAdLoaded && _bannerAd != null)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

/// WelcomeScreen with Language Selection

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await getData();
    _checkNavigation();
  }

  void _checkNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isSelected) {
        if (isAuthenticated) {
          GoRouter.of(context).go('/home');
        } else {
          GoRouter.of(context).go('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.welcome,
              style: const TextStyle(fontSize: 24, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fa', child: Text('فارسی')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedLanguage = newValue;

                    Locale newLocale = Locale(newValue);
                    MyApp.of(context)?.setLocale(newLocale);
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                select();
                GoRouter.of(context).go('/login');
              },
              child: Text(AppLocalizations.of(context)!.enterApp),
            ),
          ],
        ),
      ),
    );
  }
}

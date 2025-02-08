import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppLocalizations.of(context)!.fortuneTeller,
      theme: ThemeData(
        brightness: Brightness.dark, // حالت تیره
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.fortuneTeller),
        centerTitle: true,
        backgroundColor: Colors.grey.shade700,
      ),
      // drawer: Drawer(
      //   child: Container(
      //     color: Colors.deepPurple.shade900,
      //     child: ListView(
      //       padding: EdgeInsets.zero,
      //       children: [
      //         DrawerHeader(
      //           decoration: BoxDecoration(
      //             gradient: LinearGradient(
      //               colors: [Colors.deepPurple, Colors.black],
      //             ),
      //           ),
      //           child: Text(
      //             'Menu',
      //             style: TextStyle(color: Colors.white, fontSize: 24),
      //           ),
      //         ),
      //         _buildDrawerItem(Icons.coffee, 'Coffee Reading', context,
      //             route: '/coffee-reading'),
      //         _buildDrawerItem(Icons.star, 'Horoscope', context,
      //             route: '/horoscope'),
      //         _buildDrawerItem(Icons.question_answer, 'AI Chat', context,
      //             route: '/ai-chat'),
      //         _buildDrawerItem(Icons.book, 'Tarot & I-Ching', context,
      //             route: '/tarot-iching'),
      //       ],
      //     ),
      //   ),
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade800, Colors.black], // رنگ زمینه
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // بنر بالای صفحه
            // Container(
            //   height: 200,
            //   width: double.infinity,
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: AssetImage(
            //           'assets/images/banner.jpg'), // بنر جنگل یا تم جادویی
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            //   child: Center(
            //     child: Text(
            //       AppLocalizations.of(context)!.fortuneTeller,
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 24,
            //         fontWeight: FontWeight.bold,
            //         shadows: [
            //           Shadow(color: Colors.black, blurRadius: 10),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // بخش گزینه‌ها
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                padding: EdgeInsets.all(10),
                children: [
                  _buildOptionCard(
                      context,
                      AppLocalizations.of(context)!.coffeeReading,
                      Icons.coffee,
                      Colors.brown,
                      route: '/coffee-reading'),
                  _buildOptionCard(
                      context,
                      AppLocalizations.of(context)!.horoscope,
                      Icons.star,
                      Colors.blue,
                      route: '/horoscope'),
                  _buildOptionCard(
                      context,
                      AppLocalizations.of(context)!.aiChat,
                      Icons.chat,
                      Colors.green,
                      route: '/ai-chat'),
                  _buildOptionCard(
                      context,
                      AppLocalizations.of(context)!.tarotIChing,
                      Icons.book,
                      Colors.purple,
                      route: '/tarot-iching'),
                ],
              ),
            ),
            // تبلیغات پایین صفحه
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      BuildContext context, String title, IconData icon, Color color,
      {String? route}) {
    return GestureDetector(
      onTap: () {
        context.go(route!);
      },
      child: Card(
        color: Colors.black54, // رنگ کارت‌ها
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

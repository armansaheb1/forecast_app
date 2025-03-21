import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:forecast_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

Future<void> unselect() async {
  isSelected = false;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isSelected', false);
}

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown[100]),
          onPressed: () {
            unselect();
            isSelected = false;
            context.go('/');
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.login,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.loginNow,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(AppLocalizations.of(context)!.pleaseLogin),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password,
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.visibility_off),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                AppLocalizations.of(context)!.forgotPassword,
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  AppLocalizations.of(context)!.login,
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.dontHaveAccount,
                ),
                TextButton(
                  onPressed: () => GoRouter.of(context).go('/register'),
                  child: Text(
                    AppLocalizations.of(context)!.register,
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
            SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.orConnectWith),
            SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/apple.png',
                      width: 40,
                      height: 40,
                    ),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon:
                        Image.asset('assets/google.png', width: 40, height: 40),
                    iconSize: 40,
                    onPressed: () async {
                      var user = await _authService.signInWithGoogle();
                      if (user != null) {
                        print("Signed in as: ${user.displayName}");
                        context.go('/');
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Image.asset('assets/facebook.png',
                        width: 40, height: 40),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown[100]),
          onPressed: () => context.go('/login'),
        ),
        title: Text(
          AppLocalizations.of(context)!.register,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Sign up now",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text("Please fill the details and create account"),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.fullName,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
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
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password must be 8 characters",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("Sign Up"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  SizedBox(width: 5),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              Text("Or connect"),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset(
                      'assets/google.png',
                      width: 40,
                      height: 40,
                    ),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Image.asset(
                      'assets/facebook.png',
                      width: 40,
                      height: 40,
                    ),
                    iconSize: 40,
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

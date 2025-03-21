// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Horoscope extends StatefulWidget {
  const Horoscope({super.key});

  @override
  _HoroscopeState createState() => _HoroscopeState();
}

class _HoroscopeState extends State<Horoscope> {
  final List<File?> _selectedImages = [null, null, null];

  // Variables for Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  double level = 1;
  String content = '';
  List buttons = [];
  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _onAnalyzeButtonPressed(); // Run the analyze button pressed action by default
  }

  /// Load an interstitial ad using the test ad unit ID.
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-3940256099942544/1033173712', // Test interstitial ad id
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _onAnalyzeButtonPressed() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint("Interstitial ad dismissed.");
          ad.dispose();
          _loadInterstitialAd(); // Preload the next ad.
          _analyzeImagesAction();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint("Failed to show interstitial ad: $error");
          ad.dispose();
          _loadInterstitialAd();
          _analyzeImagesAction();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
    } else {
      _analyzeImagesAction();
    }
  }

  Future<void> _analyzeImagesAction() async {
    var uri = Uri.parse(
        'https://allinone.wiki/api/v1/horoscope'); // Update with your actual endpoint
    var request = http.MultipartRequest('POST', uri)
      ..fields['profile_id'] = '2';

    try {
      var response = await request.send();
      if (!mounted) return; // Check if widget is still active

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse is Map) {
          content = decodedResponse['result'];
          buttons = decodedResponse['next'];
          level = 2;
          setState(
            () {},
          );
        } else {
          debugPrint("Error: Unexpected response format: $decodedResponse");
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to analyze images.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // Select an image from the gallery for the given index.
  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImages[index] = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown[100]),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          AppLocalizations.of(context)!.horoscope,
          style: TextStyle(color: Colors.brown[100]),
        ),
        backgroundColor: const Color.fromARGB(255, 193, 100, 74),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/horoscope.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  if (level == 2 || level == 3)
                    Container(
                      padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: MediaQuery.of(context).size.height * 0.20,
                          bottom: 16),
                      child: Directionality(
                        textDirection:
                            AppLocalizations.of(context)!.language == 'fa'
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'نتیجه هوروسکوپ امروز شما',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              content,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (level == 2)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        children: [
                          for (String item in buttons)
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  fixedSize: Size(94, 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  debugPrint('Button pressed: $item');
                                },
                                child: Center(
                                  child: Text(item,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                      )),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CoffeeReadingScreen extends StatefulWidget {
  const CoffeeReadingScreen({super.key});

  @override
  _CoffeeReadingScreenState createState() => _CoffeeReadingScreenState();
}

class _CoffeeReadingScreenState extends State<CoffeeReadingScreen> {
  final List<File?> _selectedImages = [null, null, null];

  // Variables for Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  double level = 1;
  String content = '';
  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
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

  /// Called when the user taps the "Analyze Images" button.
  /// If an interstitial ad is ready, it is shown first. Once the ad is dismissed (or if the ad is not ready),
  /// the image analysis action runs.
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

  /// Actual image analysis action.
  /// Checks if all images are uploaded and shows a SnackBar accordingly.
  Future<void> _analyzeImagesAction() async {
    if (_selectedImages.any((image) => image == null)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload all three images.")),
        );
      }
      return;
    }

    var uri = Uri.parse(
        'https://allinone.wiki/api/v1/coffee-reading'); // Update with your actual endpoint
    var request = http.MultipartRequest('POST', uri);

    try {
      for (int i = 0; i < _selectedImages.length; i++) {
        if (_selectedImages[i] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
                'images', _selectedImages[i]!.path),
          );
        }
      }

      var response = await request.send();
      if (!mounted) return; // Check if widget is still active

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse is String) {
          content = decodedResponse;
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
          AppLocalizations.of(context)!.coffeeReadingTitle,
          style: TextStyle(color: Colors.brown[100]),
        ),
        backgroundColor: const Color.fromARGB(255, 193, 100, 74),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (level == 1)
                Text(
                  AppLocalizations.of(context)!.uploadInstructions,
                  style: TextStyle(fontSize: 16, color: Colors.grey[100]),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              if (level == 1)
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _pickImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.brown[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color.fromARGB(255, 193, 100, 74),
                              width: 2,
                            ),
                          ),
                          child: _selectedImages[index] != null
                              ? Image.file(
                                  _selectedImages[index]!,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.add_a_photo,
                                  color:
                                      const Color.fromARGB(255, 193, 100, 74),
                                  size: 40,
                                ),
                        ),
                      );
                    },
                  ),
                ),
              if (level == 1)
                ElevatedButton(
                  onPressed: _onAnalyzeButtonPressed,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.brown[100],
                    backgroundColor: const Color.fromARGB(255, 193, 100, 74),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.analyzeButton,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              if (level == 2)
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.brown[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color.fromARGB(255, 193, 100, 74),
                            width: 2,
                          ),
                        ),
                        child: Directionality(
                          textDirection:
                              AppLocalizations.of(context)!.language == 'fa'
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                content,
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

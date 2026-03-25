import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeIos extends StatefulWidget {
  const HomeIos({super.key});

  @override
  State<HomeIos> createState() => _HomeIosState();
}

class _HomeIosState extends State<HomeIos> {
  final MethodChannel platformChannel =
      MethodChannel('com.example.change_app_icon/change_icon');
  late final List<String> icons = Platform.isAndroid
      ? ['defaultIcon', 'secondIcon','thirdIcon']
      : [
          'AppIconBlue',
          'AppIconGreen',
          'AppIcon',
          'AppIconOrange',
          'AppIconPink',
          'AppIconPurple',
          'AppIconTeal',
          'AppIconYellow',
        ];

  // !! Not this naming convention AppIcon-Blue

  Future<void> _changeIcon(String iconName) async {
    try {
      await platformChannel.invokeMethod('changeIcon', iconName);
    } on PlatformException catch (e) {
      debugPrint('Error changing icon: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            for (var icon in icons)
              ListTile(
                onTap: () => _changeIcon(icon),
                title: Text(icon),
                leading: Image.asset(
                  'assets/$icon.png',
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_outlined),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

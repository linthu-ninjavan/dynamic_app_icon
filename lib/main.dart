import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int batchIconNumber = 0;

  String currentIconName = "?";

  bool loading = false;
  bool showAlert = true;

  TextEditingController controller = TextEditingController();
  String? _androidPackageName;

  String _platformIconName(String baseName) {
    if (Platform.isAndroid) {
      if (_androidPackageName != null && _androidPackageName!.isNotEmpty) {
        return '${_androidPackageName!}.$baseName';
      }
      return '.$baseName';
    }
    return baseName;
  }

  Future<void> _changeIcon(String? baseName) async {
    if (Platform.isAndroid &&
        (_androidPackageName == null || _androidPackageName!.isEmpty)) {
      final info = await PackageInfo.fromPlatform();
      _androidPackageName = info.packageName;
    }
    final iconName = baseName == null ? null : _platformIconName(baseName);
    try {
      final isSupported = await FlutterDynamicIconPlus.supportsAlternateIcons;
      if (!isSupported) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 4),
            content: Text("Alternate icons not supported on this device."),
          ));
        }
        return;
      }

      await FlutterDynamicIconPlus.setAlternateIconName(
        iconName: iconName,
        blacklistBrands: ['Redmi'],
        blacklistManufactures: ['Xiaomi'],
        blacklistModels: ['Redmi 200A'],
      );
      if (mounted) {
        final current = await FlutterDynamicIconPlus.alternateIconName;
        setState(() {
          currentIconName = current ?? "default";
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 6),
          content: Text("App icon changed successfully! Please restart the app or go to home screen to see the change."),
        ));
      }
    } on PlatformException catch (e) {
      if (mounted) {
        final message = [
          "Failed to change app icon.",
          if (e.code.isNotEmpty) "Code: ${e.code}",
          if (e.message != null && e.message!.isNotEmpty)
            "Message: ${e.message}",
        ].join(" ");
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(message),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 6),
          content: Text("Failed to change app icon. Error: $e"),
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      PackageInfo.fromPlatform().then((info) {
        if (mounted) {
          setState(() {
            _androidPackageName = info.packageName;
          });
        } else {
          _androidPackageName = info.packageName;
        }
      });
    }
    if (Platform.isIOS) {
      FlutterDynamicIconPlus.applicationIconBadgeNumber.then((v) {
        setState(() {
          batchIconNumber = v;
        });
      });
    }

    FlutterDynamicIconPlus.alternateIconName.then((v) {
      setState(() {
        currentIconName = v ?? "default";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Dynamic App Icon Plus'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28),
        child: ListView(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Choose your app icon:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildIconOption("Default", null, Icons.home),
                _buildIconOption("Icon Two", "second_icon", Icons.ac_unit),
                _buildIconOption("Icon Three", "third_icon", Icons.star),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Note: Icon changes may require restarting the app or refreshing the home screen to take effect.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Current Icon: $currentIconName",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Visibility(
              visible: Platform.isIOS,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Current batch number: $batchIconNumber",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            Visibility(
              visible: Platform.isIOS,
              child: TextField(
                controller: controller,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp("\\d+")),
                ],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: "Set Batch Icon Number",
                  suffixIcon: loading
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                              // strokeWidth: 2,
                              ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            if (Platform.isIOS) {
                              setState(() {
                                loading = true;
                              });
                              try {
                                await FlutterDynamicIconPlus
                                    .setApplicationIconBadgeNumber(
                                        int.parse(controller.text));
                                batchIconNumber = await FlutterDynamicIconPlus
                                    .applicationIconBadgeNumber;
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text(
                                        "Successfully changed batch number"),
                                  ));
                                }
                              } on PlatformException {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    duration: Duration(seconds: 3),
                                    content:
                                        Text("Failed to change batch number"),
                                  ));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    duration: Duration(seconds: 3),
                                    content:
                                        Text("Failed to change batch number"),
                                  ));
                                }
                              }

                              setState(() {
                                loading = false;
                              });
                            }
                          },
                        ),
                ),
              ),
            ),
            Visibility(
              visible: Platform.isIOS,
              child: const SizedBox(
                height: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconOption(String label, String? iconName, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () => _changeIcon(iconName),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

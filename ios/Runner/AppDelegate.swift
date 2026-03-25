import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    private let channelName = "com.example.change_app_icon/change_icon"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    configureIconChannel(with: engineBridge.applicationRegistrar.messenger())
  }

  private func configureIconChannel(with binaryMessenger: FlutterBinaryMessenger) {
    let methodChannel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: binaryMessenger
    )

    methodChannel.setMethodCallHandler { call, result in
      guard call.method == "changeIcon" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard let iconName = call.arguments as? String else {
        result(FlutterError(
          code: "INVALID_ARGUMENT",
          message: "Icon name is required",
          details: nil
        ))
        return
      }

      let model = Model()
      if let icon = Icon(rawValue: iconName) {
        model.setAlternateAppIcon(icon: icon)
        result(true)
      } else {
        result(FlutterError(
          code: "INVALID_ICON",
          message: "Icon not found",
          details: nil
        ))
      }
    }
  }
}


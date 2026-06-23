import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    let controller = window?.rootViewController as! FlutterViewController
    let pencilChannel = FlutterMethodChannel(
      name: "com.efiling.pencil_settings",
      binaryMessenger: controller.binaryMessenger
    )

    pencilChannel.setMethodCallHandler { call, result in
      guard call.method == "isPencilOnlyDrawingEnabled" else {
        result(FlutterMethodNotImplemented)
        return
      }
      // Only meaningful on iPad; returns false on iPhone
      guard UIDevice.current.userInterfaceIdiom == .pad else {
        result(false)
        return
      }
      if #available(iOS 14.0, *) {
        result(UIPencilInteraction.prefersPencilOnlyDrawing)
      } else {
        result(false)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

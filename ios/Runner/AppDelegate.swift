import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let notificationChannel = FlutterMethodChannel(name: "in.learningx.flutterApp/notifications",
                                                   binaryMessenger: controller.binaryMessenger)
    
    notificationChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "clearBadgeCount" {
        self.clearBadgeCount()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func clearBadgeCount() {
    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  // Handle the URL that your app is opened with (for OAuth2 redirect)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Handle the URL that your app is opened with
    if let scheme = url.scheme, scheme == "msauth.in.learningx.flutterapp" {
      // Forward the URL to the AppLinks plugin or any necessary handler
      return super.application(app, open: url, options: options)
    }
    return false
  }
}

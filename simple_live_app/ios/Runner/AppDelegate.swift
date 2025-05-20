import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var iosPipPlugin: IosPipPlugin?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      iosPipPlugin = IosPipPlugin(controller: controller)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

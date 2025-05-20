import UIKit
import Flutter
import AVFoundation

// Helper function to find AVPlayerLayer
// This is a basic recursive search. More sophisticated logic might be needed
// depending on how media_kit embeds its view.
func findAvPlayerLayer(in view: UIView) -> AVPlayerLayer? {
    if let playerLayer = view.layer as? AVPlayerLayer {
        return playerLayer
    }
    for subview in view.subviews {
        if let playerLayer = findAvPlayerLayer(in: subview) {
            return playerLayer
        }
    }
    // If media_kit uses a CALayer directly on the FlutterView or a child view's layer
    if let playerLayer = view.layer.sublayers?.first(where: { $0 is AVPlayerLayer }) as? AVPlayerLayer {
       return playerLayer
    }
    for sublayer in view.layer.sublayers ?? [] {
       if let playerLayer = sublayer as? AVPlayerLayer {
           return playerLayer
       }
       // Potentially recurse through sublayers if necessary, though less common for player layers
    }
    return nil
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  lazy var pipManager = PipManager()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .allowAirPlay)
        try AVAudioSession.sharedInstance().setActive(true)
    } catch {
        print("Failed to set audio session category for PIP.")
    }
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let pipChannel = FlutterMethodChannel(name: "com.example.simple_live_app/pip",
                                          binaryMessenger: controller.binaryMessenger)

    pipChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard let self = self else { return }
        if call.method == "enablePip" {
            // Try to find the AVPlayerLayer and start PIP
            // This is a simplified approach; error handling and more robust layer finding may be needed.
            if let flutterView = controller.view {
                if let playerLayer = findAvPlayerLayer(in: flutterView) {
                    self.pipManager.setupPipController(with: playerLayer)
                    self.pipManager.startPip() // New method in PipManager
                    result(true)
                } else {
                    print("AVPlayerLayer not found in Flutter view hierarchy.")
                    result(FlutterError(code: "UNAVAILABLE",
                                        message: "AVPlayerLayer not found.",
                                        details: nil))
                }
            } else {
                result(FlutterError(code: "UNAVAILABLE",
                                    message: "Flutter view not available.",
                                    details: nil))
            }
        } else if call.method == "disablePip" {
           self.pipManager.stopPip()
           result(true)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

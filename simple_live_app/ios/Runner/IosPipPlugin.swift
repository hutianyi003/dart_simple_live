import Foundation
import AVKit
import Flutter

class IosPipPlugin: NSObject {
  private var pipController: AVPictureInPictureController?
  private let channel: FlutterMethodChannel
  private weak var flutterController: FlutterViewController?

  init(controller: FlutterViewController) {
    self.flutterController = controller
    self.channel = FlutterMethodChannel(name: "simple_live_ios_pip", binaryMessenger: controller.binaryMessenger)
    super.init()
    self.channel.setMethodCallHandler(handle)
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAvailable":
      if #available(iOS 14.0, *) {
        result(AVPictureInPictureController.isPictureInPictureSupported())
      } else {
        result(false)
      }
    case "enable":
      startPip(result: result)
    case "disable":
      stopPip(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func startPip(result: @escaping FlutterResult) {
    guard #available(iOS 14.0, *) else {
      result(FlutterError(code: "unsupported", message: "iOS < 14", details: nil))
      return
    }
    guard let controller = flutterController else {
      result(FlutterError(code: "no_controller", message: "No FlutterViewController", details: nil))
      return
    }
    // Search for AVPlayerLayer inside Flutter view hierarchy.
    if let playerLayer = findPlayerLayer(in: controller.view.layer) {
      pipController = AVPictureInPictureController(playerLayer: playerLayer)
      pipController?.startPictureInPicture()
      result(nil)
    } else {
      result(FlutterError(code: "no_player", message: "AVPlayerLayer not found", details: nil))
    }
  }

  private func stopPip(result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      pipController?.stopPictureInPicture()
    }
    result(nil)
  }

  private func findPlayerLayer(in layer: CALayer) -> AVPlayerLayer? {
    if let playerLayer = layer as? AVPlayerLayer {
      return playerLayer
    }
    for sub in layer.sublayers ?? [] {
      if let found = findPlayerLayer(in: sub) {
        return found
      }
    }
    return nil
  }
}


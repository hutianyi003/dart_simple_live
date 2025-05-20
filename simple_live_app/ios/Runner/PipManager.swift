import Foundation
import AVKit
import AVFoundation

@available(iOS 9.0, *)
class PipManager: NSObject, AVPictureInPictureControllerDelegate {
    var pipController: AVPictureInPictureController?
    var playerLayer: AVPlayerLayer?

    override init() {
        super.init()
        // Initial setup if any (currently none beyond properties)
    }

    func setupPipController(with playerLayer: AVPlayerLayer) {
        if AVPictureInPictureController.isPictureInPictureSupported() {
            self.playerLayer = playerLayer
            // Ensure playerLayer has a player and it's ready if possible, or check before starting PIP.
            // For now, we just assign it.
            self.pipController = AVPictureInPictureController(playerLayer: playerLayer)
            self.pipController?.delegate = self
            print("PIP Controller is set up with provided playerLayer.")
        } else {
            print("Picture in Picture is not supported on this device.")
        }
    }

    func startPip() {
        guard let pipController = self.pipController, let playerLayer = self.playerLayer else {
            print("PIP Controller or PlayerLayer not initialized.")
            if AVPictureInPictureController.isPictureInPictureSupported() && self.playerLayer == nil {
                print("PlayerLayer is nil. It needs to be set via setupPipController.")
            } else if !AVPictureInPictureController.isPictureInPictureSupported() {
                print("PIP is not supported on this device.")
            }
            return
        }

        guard let player = playerLayer.player else {
            print("PlayerLayer has no associated player. Cannot start PIP.")
            return
        }

        guard player.currentItem != nil else {
            print("Player has no current item. Cannot start PIP.")
            return
        }
        
        // It's good practice to ensure the player is playing or at least not at rate 0.
        // However, forcing play here might interfere with media_kit's state management.
        // Rely on media_kit to manage playback state.
        // if player.rate == 0 {
        //    print("Player rate is 0. PIP might not start unless video is playing.")
        // }

        if pipController.isPictureInPicturePossible {
            DispatchQueue.main.async { // Ensure UI updates on main thread
               pipController.startPictureInPicture()
               print("Attempting to start PIP.")
            }
        } else {
            print("PIP is not possible at this moment.")
            if player.currentItem?.status != .readyToPlay {
                print("Player item not ready to play. Status: \(String(describing: player.currentItem?.status.rawValue))")
            }
             if player.error != nil {
                print("Player error: \(player.error!.localizedDescription)")
            }
            if pipController.isPictureInPictureActive {
                print("PIP is already active.")
            }
            // Add more diagnostics if needed
            if CMTimeGetSeconds(player.currentTime()) == 0 && CMTimeGetSeconds(player.currentItem?.duration ?? .zero) == 0 {
                 print("Player current time and duration are zero, video might not be loaded/playing.")
            }
        }
    }

    func stopPip() {
        if let pipController = self.pipController, pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
            print("PIP stopped.")
        }
    }

    // MARK: - AVPictureInPictureControllerDelegate
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP Did Start")
        // You might want to notify Flutter here
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP Did Stop")
        // You might want to notify Flutter here
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("PIP Failed to start: \(error.localizedDescription)")
        // You might want to notify Flutter here
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // This is called when PIP is stopped and the app needs to restore its UI.
        // You might need to tell Flutter to navigate back to the video player screen if it's not already visible.
        print("PIP Restore UI for stop.")
        completionHandler(true) // Call completion handler, true if UI restored.
    }
}

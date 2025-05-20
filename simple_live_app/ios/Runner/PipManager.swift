import Foundation
import AVKit
import AVFoundation

@available(iOS 9.0, *)
class PipManager: NSObject, AVPictureInPictureControllerDelegate {
    var pipController: AVPictureInPictureController?
    var playerLayer: AVPlayerLayer?

    // Removed init() and testPlayer/testPlayerLayer properties

    func setupPipController(with playerLayer: AVPlayerLayer) {
        if AVPictureInPictureController.isPictureInPictureSupported() {
            self.playerLayer = playerLayer // Ensure playerLayer is assigned
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

        // Ensure the player associated with the layer is playing and has a valid item.
        // media_kit should handle playback state. This is a safeguard.
        if playerLayer.player?.currentItem == nil {
            print("Player has no current item. Cannot start PIP.")
            return
        }
        
        // The player should be playing for PIP to start.
        // We assume media_kit handles the play state.
        // If playerLayer.player?.rate == 0 {
        //    playerLayer.player?.play() // Or signal Flutter to play
        //    print("Player was paused. Attempting to play to enable PIP.")
        // }

        if pipController.isPictureInPicturePossible {
            DispatchQueue.main.async { // Ensure UI updates on main thread
               pipController.startPictureInPicture()
               print("Attempting to start PIP.")
            }
        } else {
            print("PIP is not possible at this moment.")
            // Log reasons why it might not be possible
            if playerLayer.player?.currentItem?.status != .readyToPlay {
                print("Player item not ready to play.")
            }
            if pipController.isPictureInPictureActive {
                print("PIP is already active.")
            }
            // Add more diagnostics if needed
        }
    }

    // Removed startPipTest()

    func stopPip() {
        if let pipController = self.pipController, pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
            print("PIP stopped.")
        }
    }

    // MARK: - AVPictureInPictureControllerDelegate
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP Did Start")
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP Did Stop")
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("PIP Failed to start: \(error.localizedDescription)")
    }
}

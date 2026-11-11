# Screen Sharing Remote

Control your Mac from your iPhone over Apple's Screen Sharing protocol (Apple VNC). Connect to a remote Mac, see its screen, and drive the pointer and keyboard from the touchscreen.

Available on the iOS App Store for $0.99.

## What makes it different

Screen Sharing Remote focuses on interaction quality in direct-touch mode:

* **Exact taps.** Clicks land precisely where your finger touches, on touch down, move, and lift. An optional offset (`touchOffsetPoints`) can float the pointer above the fingertip instead; the default is 0 for exact 1:1 mapping.
* **No dropped points.** Every real intermediate touch sample is sent to the remote Mac (via coalesced touches), so fast strokes stay precise.
* **Predicted cursor.** The local cursor is drawn at UIKit's predicted touch position, about one frame ahead of your finger. Predictions are display-only and never reach the server; the next real sample always corrects them.

Both behaviors are tunable in `ScreenSharingRemote/SessionUI/ScreenInput.swift` (`touchOffsetPoints`, `touchPredictionEnabled`).

Trackpad (relative) mode, gestures, pinch, rotation, scrolling, and drag handling are unchanged.

## App Store build scope

The App Store build is a client only. It does not include a VNC server (sharing the iPhone's own screen) or dragging files from the remote Mac into other iOS apps. Those paths are compile-gated behind the `SIDELOAD` build flag and are not part of the App Store target.

## Building

Requirements: Xcode, Go.

```
make lib        # builds the Libsharing xcframework from the Go core
make build_ios  # debug build for a connected iPhone
```

Open `ScreenSharingRemote.xcodeproj` for development. Build for a real iPhone; the Simulator does not reproduce touch prediction well.

## License

This program is free software, distributed under the GNU General Public License v3. See `LICENSE` for the full text and the preserved upstream copyright notice. It is an independent, rebranded derivative of a GPLv3-licensed open-source Apple VNC client, and is not affiliated with or endorsed by the original project.

The complete corresponding source code of the shipped app is this repository.

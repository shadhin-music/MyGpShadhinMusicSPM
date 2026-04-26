# MyGpShadhinMusicSPM_iOS

Swift Package Manager (SPM) distribution of the **ShadhinGP SDK** — embed the full Shadhin Music experience into your iOS app.

---

## Requirements

| Requirement | Version |
|---|---|
| iOS | 14.0+ |
| Swift | 5.9+ |
| Xcode | 15.0+ |

---

## Installation

### Swift Package Manager

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the repository URL:
https://github.com/shadhin-music/MyGpShadhinMusicSPM
3. Select version rule **Up to Next Major** and click **Add Package**.
4. Select the **ShadhinGP** library and add it to your target.

#### Via `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/shadhin-music/MyGpShadhinMusicSPM", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "ShadhinGP", package: "MyGpShadhinMusicSPM")
        ]
    )
]
```

---

## Info.plist Permissions

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>fetch</string>
    <string>processing</string>
</array>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<key>NSPhotoLibraryUsageDescription</key>
<string>Used to select a profile picture.</string>

<key>NSCameraUsageDescription</key>
<string>Used to take a profile picture.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Used for audio features.</string>
```

---

## Setup

### 1. Initialize the SDK

**UIKit — AppDelegate:**

```swift
import ShadhinGP

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ShadhinCore.instance.initialize()
        return true
    }
}
```

**SwiftUI:**

```swift
import SwiftUI
import ShadhinGP

@main
struct MyApp: App {
    init() {
        ShadhinCore.instance.initialize()
    }
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

### 2. Launch the Music Experience

```swift
ShadhinGP.shared.gotoShadhinMusic(
    parentVC: self,
    accesToken: "YOUR_USER_ACCESS_TOKEN"
)
```

### 3. Track Events (Optional)

```swift
class MyViewController: UIViewController, ShadhinGPEventDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        ShadhinGP.shared.eventDelegate = self
    }

    func shadhinGP(didTriggerEvent payload: [String: Any]) {
        let eventName = payload["shadhin_gp_event_name"] as? String ?? ""
        print("Shadhin event: \(eventName)")
    }
}
```

### 4. Core Notifications (Optional)

```swift
class MyViewController: UIViewController, ShadhinCoreNotifications {
    override func viewDidLoad() {
        super.viewDidLoad()
        ShadhinCore.instance.addNotifier(notifier: self)
    }
    deinit { ShadhinCore.instance.removeNotifier(notifier: self) }

    func loginResponseV7(response: Tokenv7Obj?, errorMsg: String?) { }
    func profileInfoUpdated() { }
}
```

---

## Push Notifications (FCM)

```swift
ShadhinCore.instance.defaults.fcmToken = fcmToken
```

---

## Quick Reference

| API | Description |
|---|---|
| `ShadhinCore.instance.initialize()` | Bootstrap the SDK at app launch |
| `ShadhinGP.shared.gotoShadhinMusic(parentVC:accesToken:)` | Launch the music UI |
| `ShadhinGP.shared.eventDelegate` | Receive analytics event callbacks |
| `ShadhinCore.instance.addNotifier(notifier:)` | Subscribe to auth/profile callbacks |
| `ShadhinCore.instance.defaults.fcmToken` | Set FCM push token |

---

---

## Author

**MD Murad Hossain** — [muradhossainshadhinmusic@gmail.com](mailto:muradhossainshadhinmusic@gmail.com)

## Company

**[Shadhin Music Limited](https://www.linkedin.com/company/shadhin-music)**

---

## License

© Cloud 7 Limited. All rights reserved.

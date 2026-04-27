# Shadhin Music GP SDK — iOS Integration Guide

![Platform](https://img.shields.io/badge/Platform-iOS%2014.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen)
![Version](https://img.shields.io/badge/Version-1.0.1-blue)

---

## 1. SDK Information

| Property | Value |
|---|---|
| SDK Name | Shadhin_Gp |
| Platform | iOS |
| Minimum iOS Version | 14.0+ |
| Language | Objective-C, Swift |
| Package Manager | Swift Package Manager (SPM) |
| Current Version | ![Version](https://img.shields.io/github/v/tag/shadhin-music/MyGpShadhinMusicSPM?label=) |

This document provides full integration instructions for vendors implementing the Shadhin GP Music SDK in their iOS apps. It covers SPM setup, MSISDN authentication flow, API token handling, Vmax ad initialization, and UI integration.

---

## 2. Installation — Swift Package Manager

### Via Xcode UI

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL:
https://github.com/shadhin-music/MyGpShadhinMusicSPM
3. Select version rule **Up to Next Major** and click **Add Package**.
4. Select the **ShadhinGP** library and add it to your target.

### Via `Package.swift`

```swift
dependencies: [
    .package(
        url: "https://github.com/shadhin-music/MyGpShadhinMusicSPM",
        from: "1.0.1"
    )
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

### Import the Framework

```swift
import Shadhin_Gp
```

---

## 3. Info.plist Permissions

Add the following keys to your app's `Info.plist`:

```xml
<!-- Background audio playback -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>fetch</string>
    <string>processing</string>
</array>

<!-- Network access (required) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<!-- Photo library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to select a profile picture.</string>

<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Used to take a profile picture.</string>

<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>Used for audio features.</string>
```

---

## 4. SDK Initialization

> ⚠️ Call `ShadhinCore.instance.initialize()` once at app launch — before any other SDK call.

### UIKit — AppDelegate

```swift
import Shadhin_Gp

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ShadhinCore.instance.initialize()
        return true
    }
}
```

### SwiftUI

```swift
import SwiftUI
import Shadhin_Gp

@main
struct MyApp: App {
    init() { ShadhinCore.instance.initialize() }
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

---

## 5. Add ShadhinMusicView

### In Storyboard

- Drag a `UIView` onto your view controller
- Set **Class** = `ShadhinMusicView` in the Identity Inspector
- Set **Module** = `Shadhin_Gp`

### Create IBOutlet

```swift
@IBOutlet weak var gpMusicView: ShadhinMusicView!
```

---

## 6. ViewController Setup

Below is the complete ViewController implementation including delegate conformance, Vmax initialization, and analytics event handling.

```swift
import UIKit
import Shadhin_Gp
import Vmax

class ViewController: UIViewController, ShadhinMusicViewDelegate {

    @IBOutlet weak var gpMusicView: ShadhinMusicView!

    // Demo MSISDN — replace with real user MSISDN in production
    let demoMSISDN = "88017XXXXXXXX"

    override func viewDidLoad() {
        super.viewDidLoad()
        gpMusicView.gpDeletegate = self
        ShadhinGP.shared.eventDelegate = self
        gpMusicView.exPlore = {
            self.gpMusicView.gotoShadhinSDK()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - ShadhinMusicViewDelegate

    func gotoShadhinSDK(completionHandler: @escaping (UIViewController, String) -> Void) {
        // See Section 7 for loginUser() implementation
        loginUser(msisdn: demoMSISDN) { [weak self] token in
            guard let self = self else { return }
            completionHandler(self, token)
            DispatchQueue.main.async {
                ShadhinVmaxInitializer.shared.initialize(
                    vmaxAccountKey: "YOUR_VMAX_ACCOUNT_KEY",
                    vmaxAppId:      "YOUR_VMAX_APP_ID",
                    vmaxPrivateKey: "YOUR_VMAX_PRIVATE_KEY",
                    vmaxKeyId:      "YOUR_VMAX_KEY_ID",
                    delegate: self
                )
            }
        }
    }
}

// MARK: - Vmax Initialization Delegate

extension ViewController: InitializationStatusDelegate {
    func onSuccess() {
        ShadhinGP.shared.isVmaxInitialized = true
        print("✅ Vmax Initialized Successfully")
    }
    func onFailure(error: Vmax.VmaxError) {
        ShadhinGP.shared.isVmaxInitialized = false
        print("❌ Vmax Initialization Failed: \(error.localizedDescription)")
    }
}

// MARK: - Analytics Event Delegate

extension ViewController: ShadhinGPEventDelegate {
    func shadhinGP(didTriggerEvent payload: [String: Any]) {
        let eventName = payload["shadhin_gp_event_name"] as? String ?? ""
        print("Shadhin event: \(eventName)")
        // Forward to Firebase, Mixpanel, etc.
    }
}
```

---

## 7. GP Login API

Vendors must call this API to exchange the user MSISDN for an access token.

| Field | Value |
|---|---|
| Endpoint | `https://connect.shadhinmusic.com/api/v1/user/gp-login` |
| Method | `POST` |
| Header: Content-Type | `application/json; charset=utf-8` |
| Header: x-api-key | Provided by Shadhin Music |
| Header: client-secret | Provided by Shadhin Music |

### Request Body

```json
{
  "MSISDN":     "8801XXXXXXXXX",
  "vendorId":   "vendorId-<msisdn>",
  "deviceId":   "deviceId-<msisdn>",
  "deviceName": "iOS Device Name"
}
```

### Request Fields

| Field | Type | Description |
|---|---|---|
| MSISDN | String | GP user mobile number (with country code, e.g. `8801XXXXXXXXX`) |
| vendorId | String | Unique vendor identifier |
| deviceId | String | Unique device identifier |
| deviceName | String | Device model / name |

### Success Response (200 OK)

```json
{
  "message": "",
  "success": true,
  "responseCode": 1,
  "title": "SUCCESS",
  "data": {
    "accessToken": "BASE64_ENCODED_JWT_TOKEN",
    "refreshToken": {
      "username":    "8801XXXXXXXXX",
      "tokenString": "REFRESH_TOKEN_STRING",
      "expireAt":    1772096011776
    }
  },
  "error": null
}
```

| Response Field | Description |
|---|---|
| `data.accessToken` | JWT token — pass this to the SDK `completionHandler` |
| `data.refreshToken.username` | Logged-in user MSISDN |
| `data.refreshToken.expireAt` | Token expiry timestamp (milliseconds) |

### Error Response

```json
{
  "data": null,
  "message": "Invalid MSISDN",
  "success": false,
  "responseCode": 0,
  "title": "FAILED"
}
```

Common HTTP error codes:
- `400` → Bad Request
- `401` → Unauthorized
- `500` → Internal Server Error

### Swift Login Implementation

```swift
func loginUser(msisdn: String, completion: @escaping (String) -> Void) {
    let url = URL(string: "https://connect.shadhinmusic.com/api/v1/user/gp-login")!
    let json: [String: Any] = [
        "MSISDN":     msisdn,
        "vendorId":   "vendorId-\(msisdn)",
        "deviceId":   "deviceId-\(msisdn)",
        "deviceName": "testDevice-\(msisdn)"
    ]
    let jsonData = try! JSONSerialization.data(withJSONObject: json)
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("SHADHIN_PROVIDED_API_KEY",       forHTTPHeaderField: "x-api-key")
    request.setValue("SHADHIN_PROVIDED_CLIENT_SECRET", forHTTPHeaderField: "client-secret")
    request.httpBody = jsonData
    URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data else { return }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let obj   = json["data"] as? [String: Any],
           let token = obj["accessToken"] as? String {
            completion(token)
        }
    }.resume()
}
```

---

## 8. Push Notifications (FCM)

Forward the FCM device token to the SDK after receiving it:

```swift
import Shadhin_Gp

// In AppDelegate, after receiving FCM token:
ShadhinCore.instance.defaults.fcmToken = fcmToken
```

---

## 9. Integration Flow Summary

| Step | Action | Responsible |
|---|---|---|
| 1 | User taps Explore button | SDK |
| 2 | Vendor collects user MSISDN | Vendor |
| 3 | Call GP Login API with MSISDN | Vendor |
| 4 | Receive access token from API response | Vendor |
| 5 | Pass token via `completionHandler` | Vendor |
| 6 | Initialize Vmax ad SDK | Vendor |
| 7 | SDK launches full music experience | SDK |

---

## 10. Quick API Reference

| API | Description |
|---|---|
| `ShadhinCore.instance.initialize()` | Bootstrap the SDK at app launch |
| `gpMusicView.gpDeletegate = self` | Assign the music view delegate |
| `gpMusicView.exPlore = { }` | Closure triggered on Explore tap |
| `gpMusicView.gotoShadhinSDK()` | Trigger SDK launch after MSISDN is set |
| `ShadhinGP.shared.eventDelegate` | Receive analytics event callbacks |
| `ShadhinCore.instance.addNotifier(notifier:)` | Subscribe to auth/profile callbacks |
| `ShadhinCore.instance.removeNotifier(notifier:)` | Unsubscribe from callbacks |
| `ShadhinCore.instance.defaults.fcmToken` | Set FCM push token |
| `ShadhinGP.shared.isVmaxInitialized` | Flag set after Vmax init succeeds |

---

## 11. Vendor Requirements

- Target **iOS 14.0** or later
- Collect user MSISDN via your own UI
- Call the GP Login API and retrieve the access token
- Implement `ShadhinMusicViewDelegate` — specifically `gotoShadhinSDK(completionHandler:)`
- Initialize the Vmax ad SDK with credentials provided by Shadhin Music
- Add all required `Info.plist` permissions (see [Section 3](#3-infoplist-permissions))

---

## 12. Troubleshooting

| Issue | Solution |
|---|---|
| Build fails / missing xcframework symbols | **File → Packages → Reset Package Caches**, then **Product → Clean Build Folder** (`⇧⌘K`) |
| Audio does not play in background | Ensure `UIBackgroundModes` includes `audio` in `Info.plist` |
| SDK screen appears blank | Confirm `ShadhinCore.instance.initialize()` is called before `gotoShadhinSDK` |
| Token invalid / login fails | Verify `x-api-key` and `client-secret` headers are correct and non-empty |
| Vmax ads not showing | Check that `onSuccess()` fires and `isVmaxInitialized` is set to `true` |

---

## 13. Support & Contact

| | |
|---|---|
| **Author** | MD Murad Hossain |
| **Role** | iOS Developer — Shadhin Music |
| **Email** | muradhossainshadhinmusic@gmail.com |
| **Company** | Shadhin Music Limited (Cloud 7 Limited) |

---

*© Cloud 7 Limited. All rights reserved.*


## Author

**[MD Murad Hossain](https://www.linkedin.com/in/muradhossainm01)** — [muradhossainshadhinmusic@gmail.com](mailto:muradhossainshadhinmusic@gmail.com)

## Company

**[Shadhin Music Limited](https://www.linkedin.com/company/shadhin-music)**

---

## License

© Cloud 7 Limited. All rights reserved.

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
import Shadhin_Gp

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
import Shadhin_Gp

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

---

### 2. Launch the Music Experience

The SDK uses a `ShadhinMusicView` (UIView subclass) embedded in your storyboard or XIB, combined with a delegate to handle the login flow.

#### Step 1 — Add `ShadhinMusicView` to your Storyboard

Drag a `UIView` onto your view controller, set its class to `ShadhinMusicView` in the Identity Inspector, and connect it as an `@IBOutlet`.

#### Step 2 — Create an MSISDN Popup View Controller

```swift
import UIKit

class MSISDNPopupVC: UIViewController {

    @IBOutlet weak var userTxtField: UITextField!

    var setMsisdn: (String) -> Void = { _ in }

    override func viewDidLoad() {
        super.viewDidLoad()
        userTxtField.text = "8801711090920" // default for testing
    }

    @IBAction func msisdnSubmit(_ sender: Any) {
        if let msisdn = userTxtField.text {
            setMsisdn(msisdn)
            self.dismiss(animated: true)
        }
    }
}
```

#### Step 3 — Set Up Your Main View Controller

```swift
import UIKit
import Shadhin_Gp
import Vmax

class ViewController: UIViewController, ShadhinMusicViewDelegate {

    @IBOutlet weak var gpMusicView: ShadhinMusicView!

    var msisdn: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        gpMusicView.gpDeletegate = self
        ShadhinGP.shared.eventDelegate = self

        // Called when user taps "Explore" before login
        gpMusicView.exPlore = {
            self.showMsisdnPopup()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    // MARK: - MSISDN Popup

    func showMsisdnPopup() {
        let vc = MSISDNPopupVC()
        vc.setMsisdn = setMsisdn
        self.present(vc, animated: true)
    }

    func setMsisdn(msisdn: String) {
        self.msisdn = msisdn
        self.gpMusicView.gotoShadhinSDK()
    }

    // MARK: - ShadhinMusicViewDelegate

    func gotoShadhinSDK(completionHandler: @escaping (UIViewController, String) -> Void) {
        guard let msisdn = self.msisdn else { return }

        loginUser(msisdn: msisdn) { [weak self] token in
            guard let self = self else { return }
            completionHandler(self, token)
            DispatchQueue.main.async {
                ShadhinVmaxInitializer.shared.initialize(
                    vmaxAccountKey: "YOUR_VMAX_ACCOUNT_KEY",
                    vmaxAppId: "YOUR_VMAX_APP_ID",
                    vmaxPrivateKey: "YOUR_VMAX_PRIVATE_KEY",
                    vmaxKeyId: "YOUR_VMAX_KEY_ID",
                    delegate: self
                )
            }
        }
    }

    // MARK: - Login API

    func loginUser(msisdn: String, completion: @escaping (String) -> Void) {
        let url = URL(string: "https://connect.shadhinmusic.com/api/v1/user/gp-login")!

        let json: [String: Any] = [
            "MSISDN": msisdn,
            "vendorId": "vendorId-\(msisdn)",
            "deviceId": "deviceId-\(msisdn)",
            "deviceName": "testDevice-\(msisdn)"
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("YOUR_API_KEY", forHTTPHeaderField: "x-api-key")
        request.setValue("YOUR_CLIENT_SECRET", forHTTPHeaderField: "client-secret")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { print("Error: \(error)"); return }
            guard let data = data else { print("No data"); return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataObj = json["data"] as? [String: Any],
                   let accessToken = dataObj["accessToken"] as? String {
                    completion(accessToken)
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }.resume()
    }
}

// MARK: - Vmax Initialization Delegate

extension ViewController: InitializationStatusDelegate {
    func onSuccess() {
        ShadhinGP.shared.isVmaxInitialized = true
        print("✅ Vmax Initialized Successfully")
    }

    func onFailure(error: VmaxError) {
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

### 3. Push Notifications (FCM)

Forward the FCM device token to the SDK after receiving it:

```swift
import Shadhin_Gp

ShadhinCore.instance.defaults.fcmToken = fcmToken
```

---

## Quick Reference

| API | Description |
|---|---|
| `ShadhinCore.instance.initialize()` | Bootstrap the SDK at app launch |
| `gpMusicView.gpDeletegate = self` | Assign the music view delegate |
| `gpMusicView.exPlore` | Closure triggered when user taps Explore |
| `gpMusicView.gotoShadhinSDK()` | Trigger SDK launch after MSISDN is set |
| `ShadhinGP.shared.eventDelegate` | Receive analytics event callbacks |
| `ShadhinCore.instance.addNotifier(notifier:)` | Subscribe to auth/profile callbacks |
| `ShadhinCore.instance.defaults.fcmToken` | Set FCM push token |

---

## Author

**[MD Murad Hossain](https://www.linkedin.com/in/muradhossainm01)** — [muradhossainshadhinmusic@gmail.com](mailto:muradhossainshadhinmusic@gmail.com)

## Company

**[Shadhin Music Limited](https://www.linkedin.com/company/shadhin-music)**

---

## License

© Cloud 7 Limited. All rights reserved.

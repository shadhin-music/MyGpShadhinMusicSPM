# Shadhin Music GP SDK — iOS Integration Guide

![Platform](https://img.shields.io/badge/Platform-iOS%2014.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen)
![Version](https://img.shields.io/github/v/tag/shadhin-music/MyGpShadhinMusicSPM?label=)

---

## 1. SDK Information

| Property | Value |
|---|---|
| SDK Name | Shadhin_Gp |
| Platform | iOS |
| Minimum iOS Version | 14.0+ |
| Language | Swift, Objective-C |
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
        from: "2.1.3"
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
</array>

<!-- Network access (required) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<!-- TabBar Glass Effect OFF -->
<key>UIDesignRequiresCompatibility</key>
<true/>
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
    private var shadhinMusicView = ShadhinMusicView()

```

---

## 6. ViewController Setup

Below is the complete ViewController implementation including delegate conformance, Vmax initialization, and analytics event handling.

```swift
import UIKit
import Shadhin_Gp
import Vmax

class ViewController: UIViewController, ShadhinMusicViewDelegate {

    private var shadhinMusicView = ShadhinMusicView()
    
    // Demo MSISDN — replace with real user MSISDN in production
    let demoMSISDN = "88017XXXXXXXX"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupShadhinMusicView()
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Setup
    
    private func setupShadhinMusicView() {
        self.shadhinMusicView.frame = self.view.bounds
        self.shadhinMusicView.backgroundColor = .white
        self.view.backgroundColor = .white
        self.view.addSubview(shadhinMusicView)
        NSLayoutConstraint.activate([
            shadhinMusicView.topAnchor.constraint(equalTo: view.topAnchor),
            shadhinMusicView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            shadhinMusicView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shadhinMusicView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupDelegates() {
        shadhinMusicView.gpDeletegate = self
        ShadhinGP.shared.eventDelegate = self
        shadhinMusicView.exPlore = { [weak self] in
            self?.shadhinMusicView.gotoShadhinSDK()
        }
    }

    // MARK: - ShadhinMusicViewDelegate

     /*  MARK: - RC Code Example
       -------------Home----------------
       Library: MApMWQ==
       Podcast: MApQRA==
       Audiobook: MApCSw==
       Shorts: MApTVg==
       -------------Details--------------
       Album: MzU1MzkKUgpudWxsCnRydWUKbnVsbA==
       Song: MTE1OTk4ClMKbnVsbAp0cnVlCm51bGw=
       Podcast Episode: Mjc2OApQREJDCkVQSVNPREUKdHJ1ZQpudWxs
       Playlist: MTAwMDYKUApudWxsCnRydWUKbnVsbA==
       AI Playlist: MTcwNTUKUApBSQp0cnVlCm51bGw=
       User Create Playlist: MTY4NzUKUApVQwp0cnVlCm51bGw=
       Audiobook Details: MTI2CkJLCkFVRElPQk9PSwp0cnVlCm51bGw=
       Audiobook NARRATOR: MTAzCkJLCk5BUlJBVE9SCnRydWUKbnVsbA==
       Audiobook AUTHOR: MTA2CkJLCkFVVEhPUgp0cnVlCm51bGw=
       Audiobook VOICE_ARTIST: MTA0CkJLClZPSUNFX0FSVElTVAp0cnVlCm51bGw=
       Shorts Audio: MzA0ClNBClNIT1JUU19BVURJTwp0cnVlCjIx
       Shorts Video: Nzk0ClNWClNIT1JUU19WSURFTwp0cnVlCjM3
       Shorts Playlist: MTMKU1AKU0hPUlRTX1BMQVlMSVNUCnRydWUKMzAKNTA5
       Shorts Channel: MTMKQwpDSEFOTkVMCnRydWU=
    */

     func gotoShadhinSDK(completionHandler: @escaping (_ parentVC: UIViewController, _ accessToken: String, _ rcCode: String?, _ navController: UINavigationController?)-> Void) {
         guard let msisdn = self.msisdn else {
             dprint("⚠️ MSISDN is nil")
             return
         }
         
         loginUser(msisdn: msisdn) { [weak self] token in
             guard let self = self else { return }
             
             DispatchQueue.main.async {
                 #if DEBUG
                 // If you want to test with an RC code, pass the RC code as the third parameter.
                 // Example:
                 // completionHandler(self, token, "YOUR_RC_CODE", self.navigationController)
                 //
                 // If RC code is not required, pass `nil` instead.
                 completionHandler(self, token, "Mjc2OApQREJDCkVQSVNPREUKdHJ1ZQpudWxs", self.navigationController)
                 #else
                 // Production: Pass `nil` when RC code is not used.
                 completionHandler(self, token, nil, self.navigationController)
                 #endif
                 
                // Vmax Init
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
    
    // Need RefreshToken
    func shadhinSDKRefreshAccessToken(completion: @escaping (String?) -> Void) {
        guard let msisdn = msisdn else {
            completion(nil)
            return
        }
        loginUser(msisdn: msisdn) { token in
            completion(token)
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

 // MARK: - ShadhinGPEventDelegate
 extension ViewController: ShadhinGpEventCallback {
     
     func onEvent(_ event: ShadhinGpAnalyticsEvent) {
         switch event {

         case let .trackItemClick(title, contentId, contentType):
             print("Track Click:", title, contentId, contentType)

         case let .patchItemClick(title, contentId, contentType):
             print("Patch Click:", title, contentId, contentType)

         case let .shortsItemClick(title, contentId, contentType):
             print("Shorts Click:", title, contentId, contentType)

        case let .playPauseMusicClick(currentTime, isPlaying, title, contentId, contentType):
            print("currentTime:", currentTime, "isPlaying:", isPlaying, title, contentId, contentType)

         case .previousMusicClick:
             print("Previous Music Click")

         case .nextMusicClick:
             print("Next Music Click")
             
         case .sliderDidClick:
             print("Slider Did Click")

         case .logoClick:
             print("Logo Click")

        case .discoverBtnClick:
            print("Discover Button Click")
            
        case let .shadhinVmaxEvent(name, params):
            print("Event_Name: \(name), Parameters: \(params)")
             
         default:
             break
         }
     }
 }
```
---

## 7. UI Customization Options
 
`ShadhinMusicView` exposes several public properties so host apps can re-skin the widget to match their own brand — without needing SDK-side changes. All properties below are safe to set any time after the view is added to the hierarchy; the recommended place is `viewDidLayoutSubviews()`, so values re-apply correctly on rotation/trait changes.
 
> ⚠️ **Set these AFTER `shadhinMusicView` has been added as a subview.** Setting them before `addSubview()` has no effect since the underlying outlets are not yet loaded.
 
### Discover CTA Button — Border, Radius, Text
 
Customize the appearance and label of the "Discover" call-to-action button:
 
```swift
        
shadhinMusicView.onStyleSetup = { musicView in
    musicView.discoverCTABtnView.layer.borderColor = UIColor.red.cgColor
    musicView.discoverCTABtnView.layer.cornerRadius = 0
    musicView.discoverCTABtnLbl.textColor = .red
    musicView.discoverCTABtnLbl.text = "Home"
}
```
 
### Main Container Shadow
 
Remove or adjust the drop shadow applied to the widget's main background container:
 
```swift
shadhinMusicView.onStyleSetup = { musicView in
    // Main container border shadow
      musicView.mainBgView.layer.masksToBounds = false
      musicView.mainBgView.layer.shadowColor = UIColor.clear.cgColor
      musicView.mainBgView.layer.shadowOffset = .zero
      musicView.mainBgView.layer.shadowOpacity = 0
      musicView.mainBgView.layer.shadowRadius = 0
}
```
 
### Corner Radius
 
Override the widget's default corner radius (applied to the main container and related masked views):
 
```swift
shadhinMusicView.onStyleSetup = { musicView in
    // Corner radius
      musicView.mainBgViewCornerRadius = 0
}
```
 
### Dynamic Height Closure
 
`ShadhinMusicView`'s content height varies based on network state, available patches, and content availability. Since the widget is typically embedded inside a `UICollectionViewCell` or a stack view, host apps need the actual rendered height at runtime rather than a fixed design-time value — the `onContentHeightUpdate` closure reports this whenever it changes:
 
```swift
shadhinMusicView.onContentHeightUpdate = { height in
    print("ShadhinMusicView Height: \(height)")
    // Use this value to update your cell/row height and
    // call collectionView.performBatchUpdates / invalidateLayout
}
```
 
> ⚠️ **Do not hardcode a static height** for `ShadhinMusicView` in your layout (e.g. from Interface Builder's canvas preview). Interface Builder's canvas height can differ from the runtime-resolved height by a small margin depending on safe-area context. Always size your container using the value delivered by `onContentHeightUpdate`.
 
### Full Reference — `viewDidLayoutSubviews()`
 
A consolidated view of all customization points in context:
 
```swift
// UI Override Closer
shadhinMusicView.onStyleSetup = { musicView in

    // Discover CTA button — radius, border color, text color, title text
      musicView.discoverCTABtnView.layer.borderColor = UIColor.red.cgColor
      musicView.discoverCTABtnView.layer.cornerRadius = 0
      musicView.discoverCTABtnLbl.textColor = .red
      musicView.discoverCTABtnLbl.text = "Home"
            
    // Main container border shadow
      musicView.mainBgView.layer.masksToBounds = false
      musicView.mainBgView.layer.shadowColor = UIColor.clear.cgColor
      musicView.mainBgView.layer.shadowOffset = .zero
      musicView.mainBgView.layer.shadowOpacity = 0
      musicView.mainBgView.layer.shadowRadius = 0

    // Corner radius
      musicView.mainBgViewCornerRadius = 0
}

 // Dynamic height
 shadhinMusicView.onContentHeightUpdate = { height in
     print("ShadhinMusicView Height: \(height)")
}
```
 
| Property / Closure | Purpose | Default |
|---|---|---|
| `discoverCTABtnView.layer.*` | Border color & corner radius of the Discover CTA | System gray border, pill radius |
| `discoverCTABtnLbl.textColor` / `.text` | CTA label color & title | Default label color, `"Discover"` |
| `mainBgView.layer.shadow*` | Drop shadow on the main container | Enabled (label-color shadow, offset 3,3, opacity 0.5, radius 5) |
| `mainBgViewCornerRadius` | Corner radius applied to the main container | `16.0` |
| `onStyleSetup` | Single closure to apply all UI style overrides together (CTA button, shadow, corner radius) in one pass | `nil` (not observed) |
| `onContentHeightUpdate` | Reports live content height for dynamic sizing | `nil` (not observed) |

---


## 8. RC_CODE Routing Mechanism

RC_CODE is an encoded routing string used by the Host Application to navigate users directly to a specific destination within the SDK.

The Host Application only needs to pass the RC_CODE to the SDK. The SDK automatically decodes the value, validates the routing parameters, and navigates to the appropriate screen.

**Benefits**
- Simple integration
- Backward-compatible routing
- Flexible navigation
- Easily extensible for future enhancements

### RC_CODE Values

The following are sample RC_CODE values used to navigate to specific landing pages within the SDK.

| Destination | RC_CODE |
|---|---|
| Library | `MApMWQ==` |
| Podcast | `MApQRA==` |
| Audiobook | `MApCSw==` |
| Shorts | `MApTVg==` |

> **Note:** These RC_CODE values are intended only for navigating to the corresponding landing pages or tabs. The RC_CODE used for opening a specific content details page is different.

### Content Details Routing

To navigate directly to a content details page, use the RC_CODE provided for that specific content.

**Example**

| Field | Value |
|---|---|
| Content Title | Boishakhi Sur |
| RC_CODE | `MjAwMjcKUAp0cnVl` |

```swift
completionHandler(self, token, "MjAwMjcKUAp0cnVl", self.navigationController)
```

Passing this RC_CODE to the SDK will open the details page for **Boishakhi Sur**.

### Opening the Home/Discover Page

If you want the SDK to open on the default Home/Discover page, simply pass `nil` as the RC_CODE.

**Example**

```swift
rcCode = nil
completionHandler(self, token, nil, self.navigationController)
```

In this case, the SDK will launch and display the Home/Discover page by default.


### Deep Link Routing

To navigate directly to a content details page, use the RC_CODE provided for that specific content.
If you want the SDK to open on the default Home/Discover page, simply pass nil as the RC_CODE.
  
```swift

  ShadhinGP.shared.gotoShadhinMusic(parentVC: self, accesToken: token,  rcCode: "MjAwMjcKUAp0cnVl", nav: self.navigationController)
  
```


---

## 9. GP Login API

Vendors must call this API to exchange the user MSISDN for an access token.

| Field | Value |
|---|---|
| Endpoint | Provided by Shadhin Music |
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
    let url = URL(string: "SHADHIN_PROVIDED_API")!
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

## 10. Integration Flow Summary

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

## 11. Quick API Reference

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

## 12. Vendor Requirements

- Target **iOS 14.0** or later
- Collect user MSISDN via your own UI
- Call the GP Login API and retrieve the access token
- Implement `ShadhinMusicViewDelegate` — specifically `gotoShadhinSDK(completionHandler:)`
- Initialize the Vmax ad SDK with credentials provided by Shadhin Music
- Add all required `Info.plist` permissions (see [Section 3](#3-infoplist-permissions))

---

## 13. Troubleshooting

| Issue | Solution |
|---|---|
| Build fails / missing xcframework symbols | **File → Packages → Reset Package Caches**, then **Product → Clean Build Folder** (`⇧⌘K`) |
| Audio does not play in background | Ensure `UIBackgroundModes` includes `audio` in `Info.plist` |
| SDK screen appears blank | Confirm `ShadhinCore.instance.initialize()` is called before `gotoShadhinSDK` |
| Token invalid / login fails | Verify `x-api-key` and `client-secret` headers are correct and non-empty |
| Vmax ads not showing | Check that `onSuccess()` fires and `isVmaxInitialized` is set to `true` |

---

## Author

**[MD Murad Hossain](https://www.linkedin.com/in/muradhossainm01)** — [muradhossain@shadhinmusic.com](mailto:muradhossain@shadhinmusic.com)

## Company

**[Shadhin Music Limited](https://www.linkedin.com/company/shadhin-music)**

---

## License

*© Cloud 7 Limited. All rights reserved.*

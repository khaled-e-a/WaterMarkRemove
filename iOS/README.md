# How to Run the App

Since I have generated the source files in a folder, you need to set up an Xcode project to run them.

## Step 1: Create Xcode Project
1.  Open **Xcode**.
2.  Select **Create New Project**.
3.  Choose **iOS** -> **App**.
4.  Product Name: `GeminiWatermarkRemover`
5.  Interface: **SwiftUI**
6.  Language: **Swift**
7.  Save it anywhere (you can save it next to the generated `iOS` folder).

## Step 2: Import Files
1.  Delete the default `ContentView.swift` and `GeminiWatermarkRemoverApp.swift` created by Xcode.
2.  Open the folder containing the files I generated (`/Users/khaledea/data/elm/WaterMarkRemove/iOS`).
3.  **Drag and drop** the following into your Xcode project navigator (make sure "Copy items if needed" is CHECKED):
    -   `Components` (Folder)
    -   `GeminiWatermarkRemoverApp.swift`
    -   `homeView.swift`
    -   `GalleryView.swift`
    -   `MainTabView.swift`
    -   `SubscriptionManager.swift`
    -   `HistoryManager.swift`
    -   `WatermarkRemover.swift`
    -   `WatermarkRemover.swift`
    -   `Configuration.storekit`

## [IMPORTANT] Step 3.5: Add Photo Library Permission
**To prevent a crash when saving images, you MUST add a privacy key:**
1.  In Xcode, click on your **Project** (blue icon at top left).
2.  Select the **Target** (`GeminiWatermarkRemover`).
3.  Go to the **Info** tab.
4.  Right-click anywhere in the list -> **Add Row**.
5.  Key: `Privacy - Photo Library Additions Usage Description`.
6.  Value: `Save cleaned images to your gallery.`
    *(Without this, the app will crash instantly when you tap Save).*

## Step 3: Setup Assets
1.  In Xcode, open **Assets** (Asset Catalog).
2.  Drag `bg_48.png` and `bg_96.png` from the `Assets` folder I created into the Xcode Asset Catalog.
3.  **Important**: Rename them in the catalog to `bg_48` and `bg_96` (drop the .png extension in the name) so `UIImage(named: "bg_48")` works.

## Step 4: Configure Capabilities
1.  Select your project target in Xcode.
2.  Go to **Signing & Capabilities**.
3.  Click **+ Capability**.
4.  Add **In-App Purchase**.

## Step 5: Setup Configuration for StoreKit
1.  Go to **Product** -> **Scheme** -> **Edit Scheme**.
2.  Select **Run** on the left.
3.  Go to the **Options** tab.
4.  Change **StoreKit Configuration** to `Configuration.storekit`.

## Step 6: Run
-   Select a Simulator (e.g., iPhone 15 Pro).
-   Press **Cmd+R** to run.

---

# Gemini Watermark Remover iOS App - Implementation Plan

## Goal Description
Create a native iOS application using SwiftUI to remove Gemini watermarks from photos. The application will replicate the logic from the user-provided repository (which uses a Reverse Alpha Blending algorithm) and include a monetization model (1 free removal/day, subscription for unlimited).

> [!NOTE]
> **Repository Clarification**: The provided repository (`journey-ad/gemini-watermark-remover`) is written in **JavaScript**, not Python. To ensure the best performance and "direct use" of the logic on iOS, I will **port the algorithm components** (`alphaMap.js`, `blendModes.js`) directly to Swift. This preserves the exact mathematical logic (`original = (watermarked - alpha * 255) / (1 - alpha)`) while running natively. I will also use the exact asset files (`bg_48.png`, `bg_96.png`) from the repository.

## User Review Required
- **Language Port**: Confirming that porting the JS logic to Swift is acceptable (it is the only performant way to "use the code" on iOS without a web view).
- **Subscription Testing**: A `Configuration.storekit` file will be created to simulate purchases in the Simulator.
- **UI Design**: The app will use a "Sleek" aesthetic with dark mode, gradients, and glassmorphism. A **Gallery View** will be added to show past conversions.

## Proposed Changes

### Project Structure
The application will be structured as a standard SwiftUI project with MVVM.

#### [NEW] [GeminiWatermarkRemoverApp.swift](file:///Users/khaledea/data/elm/WaterMarkRemove/iOS/GeminiWatermarkRemoverApp.swift)
- App entry point.
- Sets up `SubscriptionManager` and `HistoryManager`.

#### [NEW] [MainTabView.swift](file:///Users/khaledea/data/elm/WaterMarkRemove/iOS/MainTabView.swift)
- Root container.
- Tab bar with two tabs: "Remove" (Home) and "Gallery".
- Uses a custom blurred tab bar for the "sleek" look.

#### [NEW] [HomeView.swift](file:///Users/khaledea/data/elm/WaterMarkRemove/iOS/HomeView.swift)
- **Main Remover UI**:
    - **Design**: Dark theme, deep purple/blue gradient background (reminiscent of Gemini branding).
    - **Interactions**:
        - Large, animated "Drop/Select Image" area.
        - "Magic Remove" button with processing animation.
        - Before/After toggle view for results.
    - **Monetization**:
        - Subtle "Pro" badge if subscribed.
        - Paywall sheet presentation if limit reached.

#### [NEW] [GalleryView.swift](file:///Users/khaledea/data/elm/WaterMarkRemove/iOS/GalleryView.swift)
- **History UI**:
    - Masonry or Grid layout of processed images.
    - Tap to view full screen and share/save.
    - Stored locally in `Documents/subfolder`.

#### [NEW] [HistoryManager.swift](file:///Users/khaledea/data/elm/WaterMarkRemove/iOS/HistoryManager.swift)
- **Responsibilities**:
    - Persist processed images to disk.
    - Maintain a JSON index of processed files (date, path).
    - Clean up old files (optional, but good practice).


#### [NEW] [WatermarkRemover.swift](file:///Users/khaledea/data/elm/WaterMarkRemove/iOS/WatermarkRemover.swift)
- **Core Logic**:
    - `calculateAlphaMap(from: UIImage) -> [Float]`
    - `removeWatermark(image: UIImage, pos: Point, alphaMap: [Float]) -> UIImage`
    - `detectConfig(width, height)`
- **Logic Port**:
    - Replicates `watermarkEngine.js`, `alphaMap.js`, `blendModes.js` using Swift's `CoreGraphics` and pointer manipulation for pixel access (for performance).

#### [NEW] [SubscriptionManager.swift](file:///Users/khaledea/data/elm/WaterMarkRemove/iOS/SubscriptionManager.swift)
- **Responsibilities**:
    - Tracks daily usage using `UserDefaults` (dates).
    - Interfaces with `StoreKit 2` for IAP.
    - Exposes state: `isSubscribed`, `remainingFreeRemovals`.
- **Products**:
    - `com.gemini.remover.monthly` ($1.99).

#### [NEW] [Assets](file:///Users/khaledea/data/elm/WaterMarkRemove/iOS/Assets)
- `bg_48.png` (Copied from repo)
- `bg_96.png` (Copied from repo)

#### [NEW] [Configuration.storekit](file:///Users/khaledea/data/elm/WaterMarkRemove/iOS/Configuration.storekit)
- Local StoreKit configuration for testing the subscription flow.

## Verification Plan

### Automated Tests
- None (Visual verification required for image processing).

### Manual Verification
1.  **Usage Limit**:
    - Create a fresh install.
    - Process 1 image. Succeed.
    - Try processing a 2nd image. Verify blocked with "Limit Reached" UI.
2.  **Watermark Removal**:
    - Load a sample Gemini image.
    - Run removal.
    - Verify watermark is gone (using the `bg_*.png` logic).
3.  **Subscription**:
    - Click "Subscribe".
    - Use Xcode's StoreKit testing to "Purchase".
    - Verify app unlocks unlimited usage.

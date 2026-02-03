# App Store Connect Setup Guide

To test your subscription on a real device (TestFlight) or release the app, you must set up the "Apple Side" in App Store Connect.

## Pre-requisites
-   Apple Developer Account (Enrolled in the Developer Program).
-   Agreement, Tax, and Banking information accepted in App Store Connect.

## Step 1: Create App ID
1.  Go to [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list).
2.  Click **+** to create a new Identifier.
3.  Choose **App IDs**.
4.  Type: **App**.
5.  Description: `Gemini Watermark Remover`.
6.  Bundle ID: **Explicit**. Enter `com.yourname.geminiwatermarkremover` (Replace `yourname` with your actual identifier part, and **UPDATE your Xcode project** to match this Bundle ID).
7.  Enable Capabilities: Default is usually fine. **In-App Purchase** is enabled by default for all App IDs now.
8.  Register.

## Step 2: Create App in App Store Connect
1.  Go to [App Store Connect](https://appstoreconnect.apple.com/).
2.  Go to **My Apps**.
3.  Click **+** -> **New App**.
4.  Platform: **iOS**.
5.  Name: `Gemini Watermark Remover` (Must be unique on the store).
6.  Primary Language: English.
7.  Bundle ID: Select the one you created in Step 1.
8.  SKU: `GEMINI_REMOVER_001` (Or any internal ID you like).
9.  Create.

## Step 3: Setup In-App Purchase (Subscription)
1.  In your App page, looking at the sidebar.
2.  Under **Monetization**, click **Subscriptions**.
3.  **Subscription Group**:
    -   Click **Create**.
    -   Name: `Premium Access`.
4.  **Subscription**:
    -   Click **Create** in the group.
    -   Reference Name: `Monthly Premium`.
    -   **Product ID**: `elm.GeminiWatermarkRemover.subscription.monthly`
        -   **CRITICAL**: This MUST match the `productId` in `SubscriptionManager.swift` exactly.
    -   Click Create.
5.  **Configure Duration**:
    -   Select **1 Month**.
6.  **Configure Price**:
    -   Click **Add Price**.
    -   Select **USD 0.99** (or equivalent).
    -   Follow prompts to set for all countries.
7.  **Localizations**:
    -   Add English (U.S.).
    -   Display Name: `Premium Monthly`.
    -   Description: `Unlimited watermark removals`.
    -   Save.
8.  **Review Information**:
    -   Upload a screenshot (you can take one from the Simulator) showing the Paywall.
    -   (You can do this later before submission).

## Step 4: Sandbox Testers
To test "Real" In-App Purchases without paying:
1.  Go to App Store Connect main dashboard -> **Users and Access**.
2.  Go to **Sandbox Testers** (Left sidebar).
3.  Click **+**.
4.  Create a test user (needs a fresh email address that is NOT a real Apple ID).
    -   Tip: using specific alias emails works well (e.g. `you+test1@gmail.com`).
5.  Set a password.

## Step 5: Testing on Device
1.  Build the app to your real iPhone.
2.  Go to iPhone Settings -> **App Store**.
3.  Scroll down to **SANDBOX ACCOUNT**.
4.  Sign in with the Sandbox Tester credentials you created.
5.  Open the App.
6.  Tap Subscribe.
7.  The system prompt should say `[Environment: Sandbox]`.
8.  Complete purchase.

> [!IMPORTANT]
> **If you are testing in Simulator**: You do NOT need the steps above. You only need the `Configuration.storekit` file (which is already set up).

## Step 6: Prepare for Release (Xcode)
1.  **App Icon**:
    -   Make sure you have added all icon sizes in `Assets.xcassets/AppIcon`.
    -   You can use online generators (like "App Icon Generator") to create the full set from your logo.
2.  **Versioning**:
    -   In Xcode -> Target -> General tab.
    -   Set **Version** to `1.0`.
    -   Set **Build** to `1`.
3.  **Signing**:
    -   In Xcode -> Target -> Signing & Capabilities tab.
    -   Ensure **Automatically manage signing** is checked.
    -   Team: Select your Team.

## Step 7: Archive and Upload
1.  Select **Any iOS Device (arm64)** as the build target (Top bar near the Play button).
2.  Go to Menu **Product** -> **Archive**.
3.  Wait for the build to finish. The **Organizer** window will open.
4.  Select the latest archive.
5.  Click **Distribute App**.
6.  Select **TestFlight & App Store** -> **Next**.
7.  Select **Upload** -> **Next**.
8.  Keep default options checked (Manage Version and Build Number, etc.) -> **Next**.
9.  Click **Upload** and wait.

## Step 8: Submission (App Store Connect)
1.  Go back to [App Store Connect](https://appstoreconnect.apple.com/).
2.  Go to your App -> **TestFlight** tab.
    -   Wait for the build to appear (Can take 10-20 minutes to process).
    -   Once "Ready to Submit", add missing compliance info (Encryption: Usually "No" if using standard https).
3.  **Deploy to Store**:
    -   Go to **App Store** tab -> **1.0 Prepare for Submission**.
    -   **Build**: Click (+) and select the build you uploaded.
    -   **Screenshots**: Upload screenshots for iPhone (6.5" and 5.5").
    -   **Description**: Write your marketing text.
    -   **Keywords**: `watermark remover, ai photo editor, magic eraser` etc.
    -   **Support URL**: Link to a simple website or Github page issue tracker.
    -   **Copyright**: `2024 Your Name`.

## Step 9: Marketing Copy

### Promotional Text (Max 170 characters)
*Option 1 (Direct benefit):*
"Instantly remove Gemini watermarks with AI! Restore your images to their original quality in seconds. Private, secure, and easy to use. Try it free!"

*Option 2 (Feature focused):*
"The ultimate AI tool to erase Gemini watermarks. Clean up your generated images effortlessly. High-quality results with just one tap."

*Option 3 (Short & punchy):*
"Remove Gemini watermarks like magic! AI-powered cleaning for perfect images. 100% private, runs on-device. Unlock your photos today."



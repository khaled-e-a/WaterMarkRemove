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
> **If you are testing on Real Device (Debug/TestFlight)**: You NEED the steps above.

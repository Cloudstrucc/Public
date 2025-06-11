# Aries Bifold Wallet - iOS Setup Guide

## 🚀 Overview

This project is a fork of Aries Bifold Wallet configured for iOS development using Xcode. It uses React Native, Aries Framework JavaScript (AFJ), and other libraries to enable self-sovereign identity (SSI) wallets.

---

## 📦 Prerequisites

* macOS with Xcode installed
* Node.js (>=18)
* Yarn (v1 or v3+)
* CocoaPods (`sudo gem install cocoapods`)
* Xcode Command Line Tools
* Xcode Simulator (iOS 16 or later)

---

## 📂 Project Setup

```bash
git clone https://github.com/hyperledger/aries-mobile-agent-react-native bifold-wallet-ios
cd bifold-wallet-ios

# Install packages
yarn install

# Navigate to iOS app folder
cd samples/app/ios
pod install
```

---

## 🛠 Building the App

```bash
# Go to root of sample app
cd ../../app

# Run Metro bundler
yarn start

# In another terminal: run iOS build
npx react-native run-ios
```

---

## 🧪 Troubleshooting

### ❌ Library 'swiftWebKit' not found

**Fix:**

1. Open the `.xcodeproj` in Xcode.
2. Go to Build Phases > Link Binary With Libraries.
3. If `libswiftWebKit.tbd` exists but causes issues:

   * Remove it.
   * Add it again via: `Add Other… > /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/lib/swift/libswiftWebKit.tbd`
4. Clean build folder and re-run.

### ❌ Could not connect to the server (Metro/JS bundle)

**Fix:**

* Ensure `yarn start` is running.
* Ensure no firewall blocks `localhost:8081`.
* In `AppDelegate.mm`, make sure `jsCodeLocation` points to the correct dev server.

---

## 📡 Mediation Timeout Fix

If you see logs like:

```
Timeout has occurred
Request was aborted due to timeout...
```

This means the Aries agent sent a mediation request but received no response.

### Causes:

* Mediator does not support return routing
* Your app has no inbound transport configured

### Fixes:

* Run a mediator with inbound transport or polling
* Use `HttpInboundTransport` if port exposed
* Use `ngrok` to expose local port
* Enable:

```ts
autoAcceptConnections: AutoAcceptConnection.Always,
autoAcceptMediationRequests: true,
```

### Dev Tip:

Use [AFJ Mediator](https://github.com/hyperledger/aries-framework-javascript/blob/main/docs/guides/mediator.md) for local testing

---

## ✅ Status

✅ App builds and launches in iOS Simulator
✅ Metro bundler serves app
✅ Mediation request sent successfully
⚠️ Awaiting inbound transport or mediator response

---

## 📚 References

* [AFJ Framework](https://aries.js.org)
* [Aries Bifold GitHub](https://github.com/hyperledger/aries-mobile-agent-react-native)
* [Apple Xcode CLI Tools](https://developer.apple.com/xcode/resources/)
* [CocoaPods Setup](https://guides.cocoapods.org/using/getting-started.html)

---

## 📎 License

[Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0)

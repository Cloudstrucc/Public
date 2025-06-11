---

# Bifold Wallet – iOS Setup Guide (macOS ARM64 – M1/M2)

This guide walks through how to successfully build and run the Bifold wallet on macOS ARM64 (e.g., M1/M2) with Xcode. It also includes key fixes for common issues and is tailored for developers using the [Bifold Wallet project](https://github.com/openwallet-foundation/bifold-wallet).

---

## ✅ Prerequisites

* macOS ARM64 (M1/M2)
* Xcode ≥ 15
* Homebrew
* Node.js (v18 LTS preferred)
* Yarn
* Cocoapods (installed via Homebrew)
* `Rosetta 2` installed (`softwareupdate --install-rosetta`)

---

## 📦 Project Bootstrap

```bash
# Clone the repo
$ git clone https://github.com/openwallet-foundation/bifold-wallet.git
$ cd bifold-wallet

# Install dependencies and bootstrap
$ yarn install
$ yarn bootstrap
```

---

## ⚙️ iOS Build Setup

### 1. Install CocoaPods

```bash
sudo arch -x86_64 gem install ffi
arch -x86_64 pod install --project-directory=./packages/legacy/core/ios
```

If you're using ARM64 (`M1/M2`):

```bash
cd packages/legacy/core/ios
sudo arch -x86_64 gem install cocoapods
arch -x86_64 pod install
```

### 2. Build with Xcode

* Open: `packages/legacy/core/ios/legacy.xcworkspace`
* Select target: `legacy`
* Use iOS Simulator (e.g. iPhone 14)
* Press ▶️ to build and run

---

## 🧠 Common Troubleshooting

### 🧩 1. `Library 'swiftWebKit' not found`

This can happen on ARM Macs. To resolve:

```bash
sudo xcode-select --switch /Applications/Xcode.app
sudo xcodebuild -runFirstLaunch
```

Ensure Xcode command line tools are selected:

```bash
xcode-select --install
```

If still unresolved:

* Clean Derived Data in Xcode
* Delete `ios/Pods` and run `pod install` again

---

## 🔄 Forcing DIDComm v1 Mode (Indicio Mediator Compatibility)

If you're using **Indicio’s public mediator**, you must set the Aries agent to **DIDComm v1 mode**.

### 🔧 Modify the Agent Configuration

Edit `packages/core/src/hooks/useBifoldAgentSetup.ts` inside the `createNewAgent` function:

#### ✏️ Before:

```ts
config: {
  label: store.preferences.walletName || 'Aries Bifold',
  walletConfig: {
    id: walletSecret.id,
    key: walletSecret.key,
  },
  logger,
  autoUpdateStorageOnStartup: true,
},
```

#### ✅ After:

```ts
config: {
  label: store.preferences.walletName || 'Aries Bifold',
  walletConfig: {
    id: walletSecret.id,
    key: walletSecret.key,
  },
  logger,
  autoUpdateStorageOnStartup: true,
  useDidCommV2: false, // ← Force compatibility with DIDComm v1
},
```

---

## ✅ Final Steps

```bash
# Clean & Rebuild
$ yarn clean
$ yarn bootstrap
$ yarn ios
```

Or rebuild from Xcode:

* Clean Build Folder (Shift + Cmd + K)
* Rebuild

---

## 📚 References

* [Official Bifold Developer Guide](https://github.com/openwallet-foundation/bifold-wallet/blob/main/DEVELOPER.md)
* [Credo TS Docs](https://credo.js.org/)
* [Aries Framework JavaScript](https://aries.js.org/)

---


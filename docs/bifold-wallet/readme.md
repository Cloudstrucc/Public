# 🛠️ Bifold Wallet iOS Setup Guide (macOS ARM64)

This guide walks you through setting up and compiling the [Bifold Wallet](https://github.com/openwallet-foundation/bifold-wallet) for iOS on **macOS ARM64 (M1/M2/M3)**. It includes updated instructions for **Yarn 4+, Corepack, CocoaPods, and monorepo workspace issues**.

---

## ✅ Prerequisites

### Install Tooling

Make sure you have the following installed:

- **Node.js** `>= 18.x` (recommended: via [Volta](https://volta.sh) or `nvm`)
- **Xcode** + CLI tools
- **CocoaPods**
  ```bash
  sudo arch -x86_64 gem install ffi
  sudo arch -x86_64 gem install cocoapods
  ```

> ✅ Recommended macOS setup is Xcode 14+ and macOS Monterey or later.

---

## 📦 Install Yarn 4 using Corepack

Ensure Yarn is **not installed via `npm` or `brew`**:

```bash
npm uninstall -g yarn
brew uninstall yarn
```

Now activate Yarn 4 using Corepack:

```bash
corepack enable
corepack prepare yarn@4.9.2 --activate
yarn --version  # should show 4.9.2
```

If `yarn --version` still shows `1.22.x`, remove the global yarn binary:

```bash
which yarn  # if this points to /usr/local/bin/yarn, remove it
sudo rm -f $(which yarn)
```

---

## 📁 Clone and Set Up the Monorepo

```bash
git clone https://github.com/openwallet-foundation/bifold-wallet.git
cd bifold-wallet
```

> This repo uses Yarn workspaces — **do not install dependencies with `npm`**.

---

## 🧼 Fix Any Broken Config

Edit `package.json` (root) and ensure you **do not have** this line:

```json
"yarn": "4.9.2"
```

Delete it if present under `devDependencies`.

Then clear caches and artifacts:

```bash
rm -rf .yarn/cache .yarn/install-state.gz .pnp.*
yarn cache clean
```

---

## 📥 Install Dependencies

```bash
yarn install
```

If peer dependency warnings show up (`YN0002`, `YN0086`), you can ignore them **unless build fails**.

---

## 📱 iOS Build Preparation

### 1. Navigate to the iOS app workspace

```bash
cd samples/app
```

Ensure `react-native` is available:

```bash
yarn workspace bifold-app add react-native
```

### 2. Verify Podfile and Dependencies

Ensure this exists (from `samples/app/ios`):

```bash
ls ../node_modules/react-native/scripts/react_native_pods.rb
```

### 3. Install iOS Pods

```bash
cd ios
pod install
```

> ❌ Do **not** run `pod install` with `sudo`. It will fail due to root user check in CocoaPods.

---

## ▶️ Run the App

In Xcode:
- Open `samples/app/ios/AriesBifold.xcworkspace`
- Set the scheme to `AriesBifold`
- Target a simulator (e.g. iPhone 14)
- Click **Run**

OR via CLI:

```bash
cd samples/app
npx react-native run-ios
```

---

## 💡 Troubleshooting Summary

| Issue | Fix |
|------|-----|
| `yarn: command not found` or wrong version | Use `corepack prepare yarn@4.9.2 --activate` |
| `Couldn't find install state` | Run `yarn install` from root |
| `Podfile: cannot load such file -- react_native_pods` | Ensure `node_modules/react-native/scripts/` exists |
| `Pod::Command.ensure_not_root_or_allowed!` | Never run `pod install` with `sudo` |
| Yarn workspace peer deps warnings (YN0002) | Safe to ignore unless build breaks |
| `pod install` missing deps | Run `yarn workspace bifold-app add react-native` and then retry |

---

## ✅ Resources

- [Official Bifold README](https://github.com/openwallet-foundation/bifold-wallet)
- [React Native Environment Setup](https://reactnative.dev/docs/environment-setup)
- [Corepack Docs](https://yarnpkg.com/corepack)
- [CocoaPods Setup](https://guides.cocoapods.org/using/getting-started.html)

---

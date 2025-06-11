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

### 🧩 2. Yarn version mismatch

If your project fails due to a `packageManager` version mismatch:

```bash
# Enable corepack if not already
corepack enable

# Activate the correct Yarn version defined in package.json
corepack prepare yarn@4.9.2 --activate

# Confirm version
yarn --version  # should be 4.9.2
```

To avoid repeating this, add to your shell profile:

```bash
echo "corepack enable && corepack prepare yarn@4.9.2 --activate" >> ~/.zshrc
source ~/.zshrc
```

Or if using bash:

```bash
echo "corepack enable && corepack prepare yarn@4.9.2 --activate" >> ~/.bash_profile
source ~/.bash_profile
```

---

## 🔄 Forcing DIDComm v1 Mode (Indicio Mediator Compatibility)

If you're using **Indicio’s public mediator**, you must set the Aries agent to **DIDComm v1 mode**.

### 🔧 Modify the Agent Configuration

Edit `packages/core/src/hooks/useBifoldAgentSetup.ts` inside the `createNewAgent` function:

#### ✏️ Before

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

#### ✅ After

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

### 🔁 Use Custom Mediator Invite

Update your mediator invitation URL to use Indicio’s updated mediator testing service:

```ts
mediatorInvitationUrl: "https://indicio-tech.github.io/mediator/",
```

You can update this in `getAgentModules` call inside the `createNewAgent` function in `useBifoldAgentSetup.ts`.

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
* [Indicio Mediator Testing Tool](https://indicio-tech.github.io/mediator/)

---


# 🎨 Customizing Bifold Wallet UI

This guide outlines how to modify the **visual style**, **text**, and **assets** in the Bifold Wallet iOS project.

---

## 🧱 Project Structure

| Component      | Purpose                     | Location                                               |
| -------------- | --------------------------- | ------------------------------------------------------ |
| Theme / Colors | Color palette and fonts     | `packages/core/src/theme.ts`                           |
| Images / Logos | Logos, splash screen, icons | `packages/core/src/assets/` and `ios/Assets.xcassets/` |
| Text / Labels  | UI strings and labels       | `packages/core/src/localization/` and `constants/`     |
| Navigation UI  | Screen layouts and headers  | `packages/core/src/navigators/`                        |
| App Metadata   | Name, identifiers (iOS)     | `ios/AriesBifold/Info.plist`                           |

---

## 🎨 Update Theme Colors

📄 **File:** `packages/core/src/theme.ts`

```ts
export const theme = {
  ColorPallet: {
    primary: {
      main: '#00ADEF', // ← Change this to your primary brand color
      dark: '#0074A2',
      light: '#66CFFF',
    },
    secondary: {
      main: '#FF6600',
    },
    background: {
      default: '#F5F5F5',
      paper: '#FFFFFF',
    },
    text: {
      primary: '#000000',
      secondary: '#666666',
    },
  },
  ...
}
```

---

## 🖼️ Replace Images and Icons

📁 **Folder:** `packages/core/src/assets/`

Replace:

* `logo.png`
* `splash.png`
* `bifold-icon.png`

📁 **iOS Assets:**

```
samples/app/ios/AriesBifold/Assets.xcassets/
```

Replace:

* `AppIcon` → iOS app icon
* `LaunchImage` or storyboard splash screen assets

✅ Maintain naming and size conventions or update references in `Info.plist` and `.pbxproj` if changed.

---

## 📝 Customize Text and Labels

📁 **Text Locations:**

* `packages/core/src/localization/`
* `packages/core/src/constants/`
* `packages/core/src/screens/`

To modify:

* Welcome messages
* Error strings
* Button text
* Onboarding labels

✅ Use `i18n` key translations for multilingual support or hardcoded values for static strings.

---

## 🧭 Modify Navigation and Layout

📁 **Files:** `packages/core/src/navigators/`

* `MainStack.tsx` → Main navigation routes
* `OnboardingStack.tsx` → Onboarding screens
* `defaultStackOptions.ts` → Header styling
* `defaultLayoutOptions.ts` → Global screen layout

---

## 📲 Change App Name, Display, and Identifiers (iOS)

📄 **File:** `samples/app/ios/AriesBifold/Info.plist`

🔧 Edit:

```xml
<key>CFBundleDisplayName</key>
<string>Vanguard Wallet</string>
```

🛠 You can also update:

* `CFBundleIdentifier`
* `NSCameraUsageDescription`, etc.


## ✅ Summary Checklist

| Task                     | Status |
| ------------------------ | ------ |
| Theme colors updated     | ☐      |
| Logo and splash replaced | ☐      |
| Text customized          | ☐      |
| Navigation styled        | ☐      |
| App name/ID set          | ☐      |



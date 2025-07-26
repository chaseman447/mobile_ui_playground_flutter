# 🧠 Flutter UI Playground

**Talk to your UI. Watch it change. Powered by AI.**

---

## 📌 Overview

Welcome to the **Flutter UI Playground**, a cutting-edge demo app that blends **Flutter** with the power of a **Large Language Model (LLM)**. This project turns your natural language into live, dynamic UI updates—whether you're tweaking widgets, building new ones, or resetting the entire screen layout.

This isn't just a playground—it's a showcase of **advanced Flutter skills**, **stateful architecture**, **LLM integration**, and **human-friendly UX**.

---

## 🚀 Features

### ✨ Natural Language Commands

* `Change profile card background to blue`
* `Add a color box`
* `Make the button text Submit`
* `Turn the switch off`

### 🔧 Dynamic Widgets

* Profile Card (image, name, title, bio)
* Color Box
* Buttons
* Sliders
* Switches
* Progress Indicators
* Image Gallery (with autoplay)
* Static Text Fields

### 🧠 LLM-Powered

* Parses your text input via an integrated AI model
* Maps commands to structured JSON instructions
* Applies changes in real-time

### ↻ Smart State Handling

* Save and reload custom layouts as presets
* Navigate through command history
* Reset or clear screen instantly

### 🖼️ Responsive UI

* Looks great on mobile, tablet, and web
* Auto-adapts to different screen sizes

---

## 🛠️ Tech Stack

| Tech                | Purpose                                |
| ------------------- | -------------------------------------- |
| Flutter + Dart      | Cross-platform UI & state management   |
| shared\_preferences | Local persistence for layouts/history  |
| LLM API (custom)    | AI brain to parse and process commands |

---

## 🔧 Getting Started

1. **Clone the Repo**

   ```bash
   git clone https://github.com/YOUR_USERNAME/flutter_ui_playground.git
   cd flutter_ui_playground
   ```

2. **Install Packages**

   ```bash
   flutter pub get
   ```

3. **Configure Your LLM API**
   Open `lib/llm_api_service.dart` and replace:

   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   ```

   with your actual API key.

4. **Run the App**

   ```bash
   flutter run
   ```

   Or for web:

   ```bash
   flutter run -d chrome
   ```

---

## 🎮 Command Examples

```text
Change button background to red
Set slider value to 0.75
Make profile picture round
Hide the progress bar
Start image auto play
Save layout as “My UI”
Load layout “My UI”
Reset UI
```

---

## 🧠 How It Works

When you type a command, it’s sent to the LLM which returns structured instructions like:

```json
{
  "component": "slider",
  "property": "value",
  "value": 0.5
}
```

The app uses this info to update its widgets live—no rebuilds, no redeploys.

---

## 🧼 Troubleshooting Tips

If you get this error:

```
type 'int' is not a subtype of type 'String'
```

👉 Just clear the app data:

* **Android**: Long-press app > Storage > Clear Storage
* **iOS Simulator**: Device > Erase All Content
* **Web**: Open DevTools > Application > Clear local storage

---

## 🔮 What’s Next?

* 🎤 Voice input support
* ↩ Undo / Redo history stack
* 🧹 AI-generated custom widgets
* 🗂 Layout manager with grid control
* 🎨 Animated LLM response effects


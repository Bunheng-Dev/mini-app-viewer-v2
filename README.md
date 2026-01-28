# 📱 Mini App Viewer v2

A powerful Flutter application that allows developers to preview and test web-based mini apps with mobile layouts directly in the app. Perfect for testing mini apps designed for platforms like Telegram, ABA, Wing, and ACLEDA during development.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.7.2+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.7.2+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

---

## ✨ Features

### 🌐 **Universal Web Viewer**
- View any web URL in a mobile layout within the app
- Seamless WebView integration with advanced controls
- Support for HTTPS and HTTP protocols

### 🎨 **Dynamic Customization**
- **Custom Headers**: Change header title dynamically via JavaScript or meta tags
- **Custom Colors**: Modify header colors on-the-fly to match your app's theme
- **Flexible Theming**: Support for hex color codes and theme customization

### 🏦 **Pre-configured Platform Templates**
Built-in support for popular mini app platforms:

- **📱 Telegram Mini Apps** - Full Telegram WebApp API support with authentication
- **💳 ABA Bank** - Pre-configured for ABA mini app development
- **🦅 Wing Bank** - Ready-to-use Wing mini app testing
- **🏦 ACLEDA Bank** - ACLEDA mini app development environment

### 🔐 **Telegram Authentication**
- Static user authentication for Telegram mini apps
- Automatic credential injection
- Access to user data (ID, username, name, photo, language)
- No login required for testing

### 🛠️ **Developer Tools**
- JavaScript Bridge API for instant updates
- Auto-detection of `document.title` changes (500ms monitoring)
- Auto-detection of `meta theme-color` changes
- History tracking for recently accessed URLs
- React, Vue, and vanilla JavaScript support

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK 3.7.2 or higher
- Android Studio / VS Code with Flutter extensions
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Bunheng-Dev/mini-app-viewer-v2.git
   cd mini-app-viewer-v2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build for production**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

---

## 📖 Usage

### Basic Usage

1. Launch the Mini App Viewer app
2. Select a platform template (Telegram, ABA, Wing, ACLEDA) or enter a custom URL
3. Your web app will load in mobile view with full customization support

### For Web Developers

#### 🎯 Change Header Title

**Method 1: JavaScript Bridge (Instant)**
```javascript
window.FlutterApp.setTitle('Shopping Cart');
```

**Method 2: Document Title (Auto-detected)**
```javascript
document.title = 'Home Page';
```

**Method 3: React Example**
```javascript
import { useEffect } from 'react';

useEffect(() => {
  window.FlutterApp.setTitle('Profile Page');
}, []);
```

#### 🎨 Change Header Color

**Method 1: JavaScript Bridge (Instant)**
```javascript
window.FlutterApp.setHeaderColor('#FF5733');
```

**Method 2: Meta Tag (Auto-detected)**
```javascript
const meta = document.createElement('meta');
meta.name = 'theme-color';
meta.content = '#FF5733';
document.head.appendChild(meta);
```

**Method 3: React Dynamic Colors**
```javascript
import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

function App() {
  const location = useLocation();
  
  useEffect(() => {
    const colors = {
      '/': '#2196F3',
      '/profile': '#EA5B6F',
      '/settings': '#9C27B0'
    };
    
    const color = colors[location.pathname] || '#2196F3';
    window.FlutterApp.setHeaderColor(color);
  }, [location]);
}
```

#### 🔐 Access Telegram User Data

```javascript
const user = window.Telegram.WebApp.initDataUnsafe.user;

console.log(user.id);           // 123456789
console.log(user.username);     // "johnwick"
console.log(user.first_name);   // "John"
console.log(user.last_name);    // "Wick"
console.log(user.photo_url);    // Profile image URL
console.log(user.language_code); // "en"
```

---

## 🎯 Complete React Integration Example

```javascript
import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

function App() {
  const location = useLocation();
  
  useEffect(() => {
    // Initialize Telegram user
    if (window.Telegram?.WebApp) {
      const user = window.Telegram.WebApp.initDataUnsafe.user;
      console.log('Logged in as:', user.username);
    }
  }, []);
  
  useEffect(() => {
    // Update header based on route
    const routes = {
      '/': { title: 'Home', color: '#2196F3' },
      '/profile': { title: 'Profile', color: '#EA5B6F' },
      '/cart': { title: 'Cart', color: '#4CAF50' }
    };
    
    const route = routes[location.pathname] || routes['/'];
    
    window.FlutterApp.setTitle(route.title);
    window.FlutterApp.setHeaderColor(route.color);
  }, [location]);
  
  return <div>Your App</div>;
}
```

---

## 📋 API Reference

### FlutterApp Bridge API

```javascript
// Set header title
window.FlutterApp.setTitle(title: string)

// Set header color (hex format)
window.FlutterApp.setHeaderColor(color: string)
```

### Telegram WebApp Object

```javascript
window.Telegram.WebApp.initDataUnsafe.user = {
  id: number,              // User ID
  username: string,        // @username
  first_name: string,      // First name
  last_name: string,       // Last name
  photo_url: string,       // Profile photo URL
  language_code: string    // Language code (e.g., "en")
}
```

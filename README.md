# EnRoute 

A modern, full-stack transit management and ticketing ecosystem designed specifically for Kerala's private and KSRTC bus networks.

> **Created by Sahl Saleem & Fathima Riyas**

---

## 🌟 Overview

**EnRoute** unifies all three critical transit stakeholders into a cohesive, real-time application:

1. **Bus Owner Portal**:
   - Multi-tenant fleet management, live revenue analytics, and bus registration.
   - Dynamic stop route configuration and time-ordered timetable scheduling.
   - Conductor credential generation and staff management.
   - Profile management with secure account deletion.

2. **Conductor Portal**:
   - Hardware camera QR scanning (`mobile_scanner`) with direct passenger account syncing.
   - Manual passenger ID fallback input.
   - **Manual Stop Override**: 1-tap stop setting and fast-forward if GPS drifts or signal is weak.
   - Dynamic distance & stage-based fare calculator with instant digital ticketing.
   - Live GPS broadcasting toggle (turns active on trip start, inactive by default).
   - Real-time scoped transaction history and daily collections dashboard.

3. **Passenger Portal**:
   - Unique permanent passenger QR code for contactless digital boarding.
   - Live running bus search with autocomplete stop search and bus number/name filters.
   - Interactive timeline showing actual bus time schedules and real-time transit status.
   - In-app wallet with instant recharge and tamper-evident digital ticket ledger.
   - Multi-tenant data isolation with secure local persistence.

4. **Settings, Themes & Accessibility**:
   - **Bilingual Localization**: Seamlessly switch between **English** and **മലയാളം (Malayalam)**.
   - **Dynamic Dark & Light Modes**: Choose between daylight clarity and midnight slate dark mode.
   - **Community Tools**: Share App with deep-link invite, interactive 5-star Rate Us, Report Issue, and Feature Suggestion.
   - **Interactive User Guide**: Tabbed guide explaining passenger, conductor, and owner workflows.

5. **Backend & Data Management Portal**:
   - Express & TypeScript server with Socket.IO for real-time GPS and ticketing broadcasts.
   - Built-in visual Data Management Portal at `http://localhost:5001/data` for live CRUD operations on Owners, Buses, Conductors, Passengers, and Tickets.
   - Dual-layer persistence (in-memory fast cache + auto-syncing `backend/data/smartbus_state.json` disk storage).

---

## 🏗️ Architecture & Tech Stack

```
smartbus_kerala/
├── backend/                  # Node.js + Express + TypeScript + Socket.IO
│   ├── src/
│   │   ├── server.ts         # REST API, Socket.IO gateway, Web Data Portal
│   │   └── routes/           # CRUD data portal & endpoints
│   ├── data/
│   │   └── smartbus_state.json
│   └── package.json
├── mobile/                   # Flutter application (Android, iOS, Web, macOS)
│   ├── lib/
│   │   ├── services/         # FleetState, Storage, Socket, AppSettingsService
│   │   ├── widgets/          # AppCreatorFooter, AppSettingsSection
│   │   ├── features/
│   │   │   ├── auth/         # Multi-role authentication & registration
│   │   │   ├── owner/        # Fleet, timetable, conductor management
│   │   │   ├── conductor/    # Camera scanner, ticketing pad, GPS & manual stop override
│   │   │   └── passenger/    # QR code, wallet, live bus timeline, search
│   │   └── main.dart
│   └── pubspec.yaml
└── docs/                     # Specifications and architectural plans
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19+ recommended)
- [Node.js](https://nodejs.org/) (v18+ recommended) & `npm`

---

### 1. Start the Backend Server

```bash
cd backend
npm install
npm run build
npm start
```

- Server will start on `http://localhost:5001`.
- Access the **Visual Data Management Portal** at: `http://localhost:5001/data`
- REST API endpoint: `http://localhost:5001/api/data/json`

---

### 2. Run the Flutter Mobile / Web App

Open a new terminal window:

```bash
cd mobile
flutter pub get
```

#### Run on Chrome (Web):
```bash
flutter run -d chrome
```

#### Run on Android / iOS device:
```bash
flutter run
```

---

## 🧪 Testing

To run the full suite of automated verification tests:

```bash
cd mobile
flutter test
```

---

## 👥 Authors & Credits
Designed and Developed with ❤️ by **Sahl Saleem** & **Fathima Riyas**.

---

## 📄 License
MIT License. Free for educational and commercial use.

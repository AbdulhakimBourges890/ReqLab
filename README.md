# ReqLab

**A lightweight REST API testing tool built with Flutter.**

ReqLab lets you send HTTP requests, inspect server responses, and keep track of your API testing history — all from a simple mobile interface.

## Features

- **HTTP Methods:** Send `GET`, `POST`, `PUT`, `PATCH`, and `DELETE` requests.
- **Request Configuration:** Add custom query parameters, headers, and request bodies.
- **Response Inspection:** View response status, response time, body size, headers, and response body.
- **JSON Formatting:** Automatically format JSON responses for easier reading.
- **Request History:** Automatically save requests, including failed requests, and review their details later.
- **History Management:** Delete individual requests or clear the entire history.
- **Appearance Settings:** Choose light mode, dark mode, or system theme.
- **Accent Colors:** Customize the application's accent color.
- **Error Handling:** Get clear error messages for connection problems, timeouts, and invalid URLs.

## Tech Stack

- **Flutter** — Cross-platform application framework.
- **Dart** — Programming language.
- **Material UI** — User interface components.
- **HTTP** — Network requests.
- **Shared Preferences** — Local settings and request history storage.
- **Font Awesome** — Additional icons.

## Getting Started

### Prerequisites

Make sure you have installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio or another supported IDE.

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/AbdulhakimBourges890/ReqLab.git
   ```

2. Navigate to the project directory:

   ```bash
   cd ReqLab
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

## Project Structure

```text
ReqLab/
├── android/             # Android platform configuration
├── assets/
│   └── images/          # Application images and branding
├── lib/
│   ├── screens/         # Application screens
│   ├── services/        # API, history, and settings services
│   ├── theme/           # Application theme
│   ├── widgets/         # Reusable UI components
│   └── main.dart        # Application entry point
├── test/                # Flutter tests
├── pubspec.yaml         # Dependencies and project configuration
└── README.md
```

## Contributing

Contributions, suggestions, and bug reports are welcome.

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Submit a pull request.

## Developer

**Abdulhakim Bourges**

GitHub: [@AbdulhakimBourges890](https://github.com/AbdulhakimBourges890)

---

*Built with Flutter.*

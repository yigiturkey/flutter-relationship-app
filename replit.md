# Overview

This is a Flutter-based mobile application for relationship analysis and personal development, designed to run on both Android and iOS platforms. The app focuses on providing relationship advice, flirting tips, and self-improvement guidance through a modular, scalable architecture built with Dart and Flutter framework.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
- **Framework**: Flutter with Dart programming language
- **Platform Support**: Cross-platform mobile application targeting both Android and iOS
- **UI Structure**: Modular component-based architecture with reusable widgets
- **Theme System**: Centralized theming with dedicated files for colors, fonts, and overall app theme
- **Navigation**: Likely uses Flutter's built-in navigation system for screen transitions

## Backend Architecture
- **Service Layer**: Modular service architecture with dedicated services for different functionalities
- **Authentication**: Dedicated auth service for user management and session handling
- **Data Management**: Firebase integration for backend services and data storage
- **Analytics**: Built-in analytics service for user behavior tracking
- **Storage**: Local and cloud storage management through dedicated storage service

## Code Organization
- **Modular Structure**: Clean separation of concerns with dedicated folders for core utilities, services, and UI components
- **Reusable Components**: Custom widgets for buttons, text fields, and loading indicators
- **Utilities**: Centralized validation logic and constants management
- **Scalable Design**: Architecture designed to accommodate future feature additions and modifications

## Development Environment
- **IDE**: Microsoft Visual Studio Code
- **Build System**: Flutter's standard build system for cross-platform compilation
- **Project Structure**: Organized with clear separation between core functionality, services, and UI components

# External Dependencies

## Firebase Integration
- **Firebase Services**: Full Firebase integration for backend functionality
- **Authentication**: Firebase Auth for user registration and login
- **Database**: Likely Firebase Firestore for data persistence
- **Push Notifications**: Firebase Cloud Messaging for user engagement
- **Analytics**: Firebase Analytics for user behavior tracking

## Flutter Framework
- **Core Framework**: Flutter SDK for cross-platform mobile development
- **Dart Language**: Programming language for application logic
- **Material Design**: Flutter's material design components for UI consistency

## Platform Dependencies
- **Android SDK**: Required for Android app compilation and deployment
- **iOS SDK**: Required for iOS app compilation and deployment
- **Platform Channels**: For accessing native device features when needed

## Development Tools
- **VS Code Extensions**: Flutter and Dart extensions for development environment
- **Flutter DevTools**: For debugging and performance monitoring
- **Package Management**: Pub.dev packages for additional functionality
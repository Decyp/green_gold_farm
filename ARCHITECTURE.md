# 🏗️ Green Gold Farms - Technical Architecture (School Project)

## 📋 Table of Contents
1. [System Overview](#system-overview)
2. [Architecture Patterns](#architecture-patterns)
3. [Data Flow](#data-flow)
4. [Key Components](#key-components)


## 🎯 System Overview

The Green Gold Farms app is built using **Flutter** for the mobile interface and **Firebase** for the backend services. 

### Simple Architecture Diagram
```
┌─────────────────────────────────────┐
│           Mobile App (Flutter)      │
│         - Customer Interface        │
│         - Admin Interface           │
├─────────────────────────────────────┤
│           Business Logic            │
│         - Services                  │
│         - State Management          │
├─────────────────────────────────────┤
│           Firebase Backend          │
│         - Database (Firestore)      │
│         - Authentication            │
│         - Storage                   │
└─────────────────────────────────────┘
```

### Why This Architecture?
- **Simple to Understand**: Clear separation between app and backend
- **Easy to Learn**: Firebase handles complex backend operations
- **Scalable**: Can grow as I learn more
- **Real-world**: Similar to how many apps are built

## 🏛️ Architecture Patterns

### 1. Layered Architecture
I organized the code into three main layers:

#### Presentation Layer (UI)
- **Screens**: What users see and interact with
- **Widgets**: Reusable UI components like buttons, cards, etc.
- **Theme**: Consistent styling across the app

#### Business Logic Layer
- **Services**: Handle business operations (login, data fetching)
- **Models**: Define data structures (Product, Order, User)
- **Providers**: Manage app state and data flow

#### Data Layer
- **Firebase Services**: Cloud database, authentication, storage
- **Local Storage**: Save data on the device for offline use

### 2. Provider Pattern for State Management
I used the Provider pattern to manage app state:

```dart
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners(); // Tell UI to update
    
    try {
      _products = await FirebaseService().getProducts();
    } catch (e) {
      // Handle errors
    } finally {
      _isLoading = false;
      notifyListeners(); // Tell UI to update again
    }
  }
}
```

**Why Provider?**
- **Simple**: Easy to understand and implement
- **Efficient**: Only rebuilds UI when data actually changes
- **Flutter-friendly**: Works well with Flutter's widget system

### 3. Repository Pattern
I organized data access through service classes:

```dart
class FirebaseService {
  // Handle all Firebase operations
  Future<List<Product>> getProducts() async {
    // Get products from Firestore
  }
  
  Future<void> addProduct(Product product) async {
    // Add product to Firestore
  }
}
```



## 🔄 Data Flow

### How Data Moves Through the App

```
1. User Action (e.g., taps "View Products")
   ↓
2. UI calls Provider method
   ↓
3. Provider calls Firebase Service
   ↓
4. Firebase Service fetches data from Firestore
   ↓
5. Data flows back through the chain
   ↓
6. UI updates to show new data
```

### Real-time Updates with Streams
I used Firebase streams for live data updates:

```dart
StreamBuilder<List<Order>>(
  stream: FirebaseService().getOrders(), // Live data stream
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

**What This Means:**
- **Automatic Updates**: UI updates when data changes in database
- **Real-time**: Users see changes immediately
- **Efficient**: Only rebuilds when necessary

## 🧩 Key Components

### 1. Authentication System
```dart
class AuthService {
  Future<UserCredential> signIn(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  Future<bool> isUserAdmin() async {
    // Check if current user has admin role
  }
}
```

**Features:**
- **Secure Login**: Email/password authentication
- **Role-based Access**: Different interfaces for customers vs. admins
- **Session Management**: Users stay logged in

### 2. Data Models
```dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final int stockQuantity;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stockQuantity,
  });
  
  // Convert to/from Firestore data
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      stockQuantity: data['stockQuantity'] ?? 0,
    );
  }
}
```

**Why This Design?**
- **Type Safety**: Dart's strong typing prevents errors
- **Easy Conversion**: Simple to work with Firebase data
- **Maintainable**: Clear structure for product information

### 3. Navigation Structure
```
Main App
├── Customer Interface
│   ├── Home Screen
│   ├── Products Screen
│   ├── Cart Screen
│   ├── Machinery Screen
│   └── Profile Screen
└── Admin Interface
    ├── Dashboard
    ├── Product Management
    ├── Order Management
    └── User Management
```







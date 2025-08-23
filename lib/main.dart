import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/produce_screen.dart';
import 'screens/customer/machinery_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'models/cart_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize notification service
    await NotificationService().initialize();
  } catch (e) {
    // Fallback if Firebase fails to initialize
    // print('Firebase initialization failed: $e');
  }

  runApp(const GreenGoldFarmsApp());
}

class GreenGoldFarmsApp extends StatelessWidget {
  const GreenGoldFarmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseService>(
      create: (_) => FirebaseService(),
      child: MaterialApp(
        title: 'Green Gold Farms',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: AppTheme.primaryGreen,
          scaffoldBackgroundColor: AppTheme.lightGray,
          appBarTheme: AppBarTheme(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: AppTheme.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: AppTheme.heading2.copyWith(color: AppTheme.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: AppTheme.primaryButton,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppTheme.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading screen while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.lightGray,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                  SizedBox(height: AppTheme.paddingMedium),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: AppTheme.gray,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // User is signed in - check if admin
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<bool>(
            future: Provider.of<FirebaseService>(context, listen: false)
                .isUserAdmin(),
            builder: (context, adminSnapshot) {
              // Show loading while checking admin status
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: AppTheme.lightGray,
                  body: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                );
              }

              // Show admin dashboard if user is admin, otherwise show customer app
              if (adminSnapshot.hasData && adminSnapshot.data == true) {
                return const AdminMainScreen();
              } else {
                return const MainApp();
              }
            },
          );
        } else {
          // User is not signed in
          return const LoginScreen();
        }
      },
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProduceScreen(),
    const MachineryScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.white,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: AppTheme.gray,
          selectedLabelStyle: AppTheme.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryGreen,
          ),
          unselectedLabelStyle: AppTheme.caption,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket),
              label: 'Produce',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.agriculture),
              label: 'Machinery',
            ),
            BottomNavigationBarItem(
              icon: StreamBuilder<List<CartItem>>(
                stream: Provider.of<FirebaseService>(context, listen: false)
                    .getCart(),
                builder: (context, snapshot) {
                  final cartItems = snapshot.data ?? [];
                  final itemCount = cartItems.fold<int>(
                      0, (sum, item) => sum + item.quantity);

                  return Stack(
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$itemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

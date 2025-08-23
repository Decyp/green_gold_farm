import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../theme/app_theme.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(),
                  const SizedBox(height: 60),
                  _buildLoginForm(),
                  const SizedBox(height: AppTheme.paddingLarge),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Farm Logo with hidden admin creation
        GestureDetector(
          onLongPress: () => _showAdminCreationDialog(),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.eco,
                    size: 60,
                    color: AppTheme.primaryGreen,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.paddingLarge),
        Text(
          'Welcome Back',
          style: AppTheme.heading1.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Text(
          'Sign in to your Green Gold Farms account',
          style: AppTheme.bodyText.copyWith(
            color: AppTheme.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign In',
              style: AppTheme.heading2.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email, color: AppTheme.gray),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: AppTheme.gray),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: AppTheme.gray,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.paddingMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : Text(
                      'Sign In',
                      style: AppTheme.bodyText.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTheme.bodyText.copyWith(color: AppTheme.white),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignupScreen(),
              ),
            );
          },
          child: Text(
            'Sign Up',
            style: AppTheme.bodyText.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        _showSnackBar('🎉 Welcome back! Successfully signed in.');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong. Please try again.';
      String title = 'Login Error';

      switch (e.code) {
        case 'user-not-found':
          message =
              'No account found with this email address.\n\nPlease check your email or create a new account.';
          title = 'Account Not Found';
          break;
        case 'wrong-password':
          message =
              'The password you entered is incorrect.\n\nPlease check your password and try again.';
          title = 'Incorrect Password';
          break;
        case 'invalid-email':
          message =
              'Please enter a valid email address.\n\nExample: yourname@example.com';
          title = 'Invalid Email';
          break;
        case 'user-disabled':
          message =
              'This account has been disabled.\n\nPlease contact support for assistance.';
          title = 'Account Disabled';
          break;
        case 'too-many-requests':
          message =
              'Too many failed login attempts.\n\nPlease wait a few minutes before trying again.';
          title = 'Too Many Attempts';
          break;
        case 'network-request-failed':
          message =
              'No internet connection.\n\nPlease check your connection and try again.';
          title = 'Connection Error';
          break;
        case 'invalid-credential':
          message =
              'Invalid email or password.\n\nPlease check your credentials and try again.';
          title = 'Invalid Credentials';
          break;
        case 'operation-not-allowed':
          message =
              'Email/password sign-in is not enabled.\n\nPlease contact support.';
          title = 'Sign-in Disabled';
          break;
        case 'weak-password':
          message =
              'The password is too weak.\n\nPlease use a stronger password.';
          title = 'Weak Password';
          break;
        case 'email-already-in-use':
          message =
              'An account with this email already exists.\n\nPlease sign in instead.';
          title = 'Email Already Exists';
          break;
        default:
          message =
              'An unexpected error occurred.\n\nPlease try again or contact support if the problem persists.';
          title = 'Login Error';
      }

      _showErrorDialog(title, message);
    } catch (e) {
      _showErrorDialog(
        'Unexpected Error',
        'Something went wrong while signing in.\n\nPlease try again or contact support if the problem persists.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: AppTheme.paddingSmall),
            Expanded(
              child: Text(
                title,
                style: AppTheme.heading3.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTheme.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTheme.bodyText.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.white,
              size: 20,
            ),
            const SizedBox(width: AppTheme.paddingSmall),
            Expanded(
              child: Text(
                message,
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        margin: const EdgeInsets.all(AppTheme.paddingMedium),
      ),
    );
  }

  // DEV ONLY: Admin Creation Feature
  // TODO: Comment out this entire method before production
  void _showAdminCreationDialog() {
    final adminNameController = TextEditingController();
    final adminEmailController = TextEditingController();
    final adminPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔧 DEV: Create Admin User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This feature is for development only.\nCreate an admin user account.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: adminNameController,
              decoration: const InputDecoration(
                labelText: 'Admin Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: adminEmailController,
              decoration: const InputDecoration(
                labelText: 'Admin Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: adminPasswordController,
              decoration: const InputDecoration(
                labelText: 'Admin Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (adminNameController.text.isEmpty ||
                  adminEmailController.text.isEmpty ||
                  adminPasswordController.text.isEmpty) {
                _showSnackBar('Please fill all fields');
                return;
              }

              try {
                // Create user in Firebase Auth
                final userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: adminEmailController.text.trim(),
                  password: adminPasswordController.text,
                );

                // Update display name
                await userCredential.user
                    ?.updateDisplayName(adminNameController.text.trim());

                // Create admin document in Firestore
                if (userCredential.user != null) {
                  await firestore.FirebaseFirestore.instance
                      .collection('users')
                      .doc(userCredential.user!.uid)
                      .set({
                    'uid': userCredential.user!.uid,
                    'name': adminNameController.text.trim(),
                    'email': adminEmailController.text.trim(),
                    'displayName': adminNameController.text.trim(),
                    'role': 'admin',
                    'isAdmin': true,
                    'createdAt': firestore.Timestamp.now(),
                    'updatedAt': firestore.Timestamp.now(),
                  });
                }

                Navigator.pop(context);
                _showSnackBar('Admin user created successfully!');
              } catch (e) {
                _showSnackBar('Error creating admin: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Create Admin'),
          ),
        ],
      ),
    );
  }
}

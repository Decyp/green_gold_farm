import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildSignupForm(),
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
        // Farm Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.eco,
                  size: 50,
                  color: AppTheme.primaryGreen,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppTheme.paddingLarge),
        Text(
          'Join Green Gold Farms',
          style: AppTheme.heading1.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Text(
          'Create your account to start farming',
          style: AppTheme.bodyText.copyWith(
            color: AppTheme.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
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
              'Create Account',
              style: AppTheme.heading2.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person, color: AppTheme.gray),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.paddingMedium),
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
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock, color: AppTheme.gray),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppTheme.gray,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
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
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
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
                      'Create Account',
                      style: AppTheme.bodyText.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Row(
              children: [
                Expanded(
                    child:
                        Divider(color: AppTheme.gray.withValues(alpha: 0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingMedium),
                  child: Text(
                    'OR',
                    style: AppTheme.caption.copyWith(color: AppTheme.gray),
                  ),
                ),
                Expanded(
                    child:
                        Divider(color: AppTheme.gray.withValues(alpha: 0.3))),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            OutlinedButton.icon(
              onPressed: _signUpWithGoogle,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                side: const BorderSide(color: AppTheme.primaryGreen),
                padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.paddingMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.g_mobiledata, size: 24),
              label: Text(
                'Sign up with Google',
                style: AppTheme.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
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
          'Already have an account? ',
          style: AppTheme.bodyText.copyWith(color: AppTheme.white),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          child: Text(
            'Sign In',
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

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Update user display name
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // Create user document in Firestore
      if (userCredential.user != null) {
        await firestore.FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'displayName': _nameController.text.trim(),
          'role': 'customer', // Default role
          'isAdmin': false,
          'createdAt': firestore.Timestamp.now(),
          'updatedAt': firestore.Timestamp.now(),
        });
      }

      if (mounted) {
        Navigator.pop(context); // Return to previous screen
        _showSnackBar(
            '🎉 Welcome to Green Gold Farms! Your account has been created successfully.');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong. Please try again.';
      String title = 'Sign Up Error';

      switch (e.code) {
        case 'weak-password':
          message =
              'Your password is too weak.\n\nPlease use a stronger password with at least 6 characters, including letters and numbers.';
          title = 'Weak Password';
          break;
        case 'email-already-in-use':
          message =
              'An account with this email already exists.\n\nPlease sign in instead or use a different email address.';
          title = 'Email Already Exists';
          break;
        case 'invalid-email':
          message =
              'Please enter a valid email address.\n\nExample: yourname@example.com';
          title = 'Invalid Email';
          break;
        case 'operation-not-allowed':
          message =
              'Email/password sign-up is not enabled.\n\nPlease contact support for assistance.';
          title = 'Sign-up Disabled';
          break;
        case 'network-request-failed':
          message =
              'No internet connection.\n\nPlease check your connection and try again.';
          title = 'Connection Error';
          break;
        case 'too-many-requests':
          message =
              'Too many sign-up attempts.\n\nPlease wait a few minutes before trying again.';
          title = 'Too Many Attempts';
          break;
        default:
          message =
              'An unexpected error occurred.\n\nPlease try again or contact support if the problem persists.';
          title = 'Sign Up Error';
      }

      _showErrorDialog(title, message);
    } catch (e) {
      _showErrorDialog(
        'Unexpected Error',
        'Something went wrong while creating your account.\n\nPlease try again or contact support if the problem persists.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Note: Google Sign-In implementation would go here
      // For now, we'll show a placeholder message
      _showSnackBar('🔧 Google Sign-Up will be available soon!');
    } catch (e) {
      _showErrorDialog(
        'Google Sign-Up Error',
        'Unable to sign up with Google at the moment.\n\nPlease try creating an account with your email and password.',
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
}

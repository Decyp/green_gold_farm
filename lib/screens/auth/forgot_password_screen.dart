import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                  _buildResetForm(),
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
        // Lock Icon
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
          child: const Icon(
            Icons.lock_reset,
            size: 50,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: AppTheme.paddingLarge),
        Text(
          'Forgot Password?',
          style: AppTheme.heading1.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Text(
          'Enter your email to reset your password',
          style: AppTheme.bodyText.copyWith(
            color: AppTheme.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResetForm() {
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
            if (!_emailSent) ...[
              Text(
                'Reset Password',
                style: AppTheme.heading2.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              Text(
                'We\'ll send you a link to reset your password',
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.gray,
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
                    borderSide: const BorderSide(
                        color: AppTheme.primaryGreen, width: 2),
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
              const SizedBox(height: AppTheme.paddingLarge),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
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
                        'Send Reset Link',
                        style: AppTheme.bodyText.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ] else ...[
              // Success State
              Icon(
                Icons.check_circle,
                size: 80,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              Text(
                'Email Sent!',
                style: AppTheme.heading2.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Text(
                'We\'ve sent a password reset link to:',
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.gray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                _emailController.text,
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              Text(
                'Please check your email and follow the instructions to reset your password.',
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.gray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _emailSent = false;
                    _emailController.clear();
                  });
                },
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
                child: Text(
                  'Send Another Email',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
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
          'Remember your password? ',
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

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email address';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'too-many-requests':
          message = 'Too many requests. Please try again later';
          break;
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

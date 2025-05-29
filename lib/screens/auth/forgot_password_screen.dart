import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;
  bool emailSent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Debug: Print the email being used
      print('Attempting to send reset email to: ${emailController.text.trim()}');

      // Simply send the password reset email
      // Firebase will handle whether the email exists or not
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      print('Password reset email request completed');

      if (mounted) {
        setState(() {
          emailSent = true;
        });
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      _showErrorDialog(_getResetPasswordErrorText(e));
    } catch (e) {
      print('General exception: $e');
      _showErrorDialog('An unexpected error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getResetPasswordErrorText(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
      case 'auth/invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'auth/user-not-found':
        return 'No account found with this email address.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
      case 'auth/too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'auth/user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Failed to send reset email. Please try again.\nError: ${e.message}';
    }
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Email Sent!'),
        content: Text(
          'If an account with ${emailController.text.trim()} exists, you will receive a password reset email.\n\nPlease check your inbox and spam folder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Test function to verify Firebase connection
  Future<void> _testFirebaseConnection() async {
    try {
      print('Testing Firebase connection...');
      final user = FirebaseAuth.instance.currentUser;
      print('Current user: $user');
      print('Firebase Auth instance: ${FirebaseAuth.instance}');

      // Try to get current user to test connection
      await FirebaseAuth.instance.authStateChanges().first;
      print('Firebase connection successful');

      _showSuccessDialog2('Firebase connection is working!');
    } catch (e) {
      print('Firebase connection error: $e');
      _showErrorDialog('Firebase connection failed: $e');
    }
  }

  Future<void> _showSuccessDialog2(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Result'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          // Debug button - remove in production
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _testFirebaseConnection,
            tooltip: 'Test Firebase Connection',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(4.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 3.h),

                // Icon
                Center(
                  child: Container(
                    padding: EdgeInsets.all(3.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 6.h,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),

                if (!emailSent) ...[
                  // Title and Description
                  Center(
                    child: Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Center(
                    child: Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Email Field
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      helperText: 'Make sure this email is registered with us',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 4.h),

                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : Text(
                        "Send Reset Link",
                        style: GoogleFonts.openSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Success State
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 8.h,
                          color: Colors.green,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Email Sent!',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Password reset email sent to:',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(2.h),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            emailController.text.trim(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Check your email and follow the instructions to reset your password.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Resend Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () {
                        setState(() {
                          emailSent = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.8.h),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Send Another Email",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 3.h),

                // Back to Login Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          "Back to Login",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Troubleshooting Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(2.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Colors.orange.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Email not arriving?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '• Check your spam/junk folder\n• Wait up to 10 minutes for delivery\n• Verify the email address is correct\n• Make sure you have an account with this email',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
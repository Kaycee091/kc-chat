import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'email_verify_modal.dart';
import 'onboarding_wizard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _rememberMe = true;
  bool _termsAccepted = false;
  bool _isLoading = false;

  final _identifierController = TextEditingController(text: 'alex.johnson@kc.app');
  final _passwordController = TextEditingController(text: 'Password123!');
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController(text: '2000-05-15');
  final _confirmPasswordController = TextEditingController();
  final String _selectedGender = 'Rather not say';

  final _otpController = TextEditingController();

  void _handleSignIn() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(_identifierController.text, _passwordController.text, _rememberMe);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success && auth.is2FAPending) {
      _show2FAVerificationDialog();
    }
  }

  void _show2FAVerificationDialog() {
    final authProvider = context.read<AuthProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Two-Factor Authentication'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 6-digit verification OTP code (Use 123456 for testing):'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '123456',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              authProvider.signOut();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final ok = await authProvider.verify2FA(_otpController.text);
              if (!ctx.mounted) return;
              if (ok) {
                navigator.pop();
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Invalid 2FA code. Try 123456')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _handleRegister() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Service to continue.')),
      );
      return;
    }
    if (_confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text != _passwordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match. Please re-enter.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text.isEmpty ? 'New User' : _nameController.text,
      username: _usernameController.text.isEmpty ? 'newuser' : _usernameController.text,
      email: _emailController.text.isEmpty ? 'newuser@kc.app' : _emailController.text,
      phone: _phoneController.text,
      dob: _dobController.text,
      gender: _selectedGender,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showEmailVerificationModal();
    }
  }

  void _showEmailVerificationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EmailVerifyModal(
        onVerified: () {
          Navigator.pop(ctx);
          _showOnboardingWizard();
        },
      ),
    );
  }

  void _showOnboardingWizard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OnboardingWizard(
        onCompleted: () {
          Navigator.pop(ctx);
          context.read<AuthProvider>().completeOnboarding();
        },
      ),
    );
  }

  Widget _buildPasswordStrengthBar(int score) {
    List<Color> colors = [
      Colors.grey.shade300,
      AppColors.destructive,
      AppColors.warning,
      Colors.blue,
      AppColors.success,
    ];
    List<String> labels = ['None', 'Weak', 'Fair', 'Good', 'Strong'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            final active = index < score;
            return Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: active ? colors[score] : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          'Password Strength: ${labels[score]}',
          style: TextStyle(fontSize: 12, color: score > 0 ? colors[score] : Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final passwordStrength = auth.calculatePasswordStrength(_passwordController.text);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.hub_rounded, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'KC APP',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Next-Gen 3D Glassmorphic Social Platform',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Auth Toggle Switch
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? AppColors.darkCard : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !_isSignUp ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !_isSignUp ? Colors.white : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _isSignUp ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isSignUp ? Colors.white : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Container Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isSignUp) ...[
                          // SIGN IN FORM
                          TextField(
                            controller: _identifierController,
                            decoration: InputDecoration(
                              labelText: 'Email / Username / Phone',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                    activeColor: AppColors.primary,
                                  ),
                                  const Text('Remember me'),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Password recovery link sent to your registered email.')),
                                  );
                                },
                                child: const Text('Forgot?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Sign In to KC App', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ] else ...[
                          // REGISTER FORM
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.alternate_email),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildPasswordStrengthBar(passwordStrength),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: _termsAccepted,
                                onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                                activeColor: AppColors.primary,
                              ),
                              const Expanded(
                                child: Text('I agree to the KC App Terms of Service & Privacy Policy', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
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

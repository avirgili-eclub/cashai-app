import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/core/styles/app_styles.dart';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import '../presentation/controllers/auth_controller.dart';

class CustomSignInScreen extends ConsumerStatefulWidget {
  const CustomSignInScreen({super.key});

  @override
  ConsumerState<CustomSignInScreen> createState() => _CustomSignInScreenState();
}

class _CustomSignInScreenState extends ConsumerState<CustomSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Handle login with our auth controller
        final response = await ref.read(authControllerProvider.notifier).login(
              email: _emailController.text,
              password: _passwordController.text,
            );

        if (context.mounted) {
          if (response != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inicio de sesión exitoso')),
            );
            // Navigate to dashboard using go_router's context extension
            context.go('/dashboard');
          } else {
            final error = ref.read(authControllerProvider).error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error ?? 'Error al iniciar sesión'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Handle registration with our auth controller
        final response =
            await ref.read(authControllerProvider.notifier).registerUser(
                  email: _emailController.text,
                  password: _passwordController.text,
                );

        if (context.mounted) {
          if (response != null) {
            // Registration successful - switch to login mode
            setState(() {
              _isLogin = true;
              // Don't clear email so user can proceed to login
              _passwordController.clear();
              _confirmPasswordController.clear();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro exitoso. Por favor inicia sesión'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // Registration failed
            final error = ref.read(authControllerProvider).error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error ?? 'Error en el registro'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ha ocurrido un error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Implementation will be added later
      await Future.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión con Google exitoso')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar sesión con Google'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fixed implementation for Apple Sign-In
      if (Platform.isIOS) {
        // Use OAuthProvider directly from Firebase Auth instead of AppleProvider from UI package
        final appleProvider = OAuthProvider('apple.com');

        try {
          // This is the correct way to use Apple sign-in with Firebase Auth
          final auth = FirebaseAuth.instance;
          final credential = await auth.signInWithProvider(appleProvider);

          // Extract user data from the credential
          final user = credential.user;
          final displayName = user?.displayName;
          final email = user?.email;

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Inicio de sesión exitoso${displayName != null ? ' como $displayName' : ''}${email != null ? ' ($email)' : ''}')),
            );
            // Here you would navigate to your app's home screen
            // Navigator.of(context).pushReplacementNamed('/dashboard');
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error con Apple Sign-In: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Show message that Apple Sign-In isn't available on this platform
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Inicio de sesión con Apple solo está disponible en dispositivos iOS'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión con Apple: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Icon
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: AppStyles.primaryColor,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Subtitle/Welcome text
                  Text(
                    _isLogin
                        ? 'Bienvenido de vuelta a CashAI'
                        : 'Únete a CashAI y comienza a ahorrar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            hintText: 'ejemplo@correo.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppStyles.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo electrónico';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Por favor ingresa un correo válido';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppStyles.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),

                        // Confirm Password Field (only for signup)
                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_showConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showConfirmPassword =
                                        !_showConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppStyles.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor confirma tu contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                        ],

                        if (_isLogin) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Implement forgot password functionality
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppStyles.primaryColor,
                              ),
                              child: const Text('¿Olvidaste tu contraseña?'),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyles.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Iniciar Sesión' : 'Registrarse',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Auth toggle button
                        TextButton(
                          onPressed: _switchAuthMode,
                          child: Text(
                            _isLogin
                                ? '¿No tienes cuenta? Regístrate'
                                : '¿Ya tienes cuenta? Inicia sesión',
                            style: TextStyle(
                              color: AppStyles.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider with "o"
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: Sizes.p8),
                        child: Text(
                          'o',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social Sign-in Buttons
                  Column(
                    children: [
                      // Google Sign In Button
                      _SocialSignInButton(
                        onPressed: _signInWithGoogle,
                        text: _isLogin
                            ? 'Iniciar sesión con Google'
                            : 'Registrarse con Google',
                        icon: const Icon(
                          Icons
                              .g_mobiledata, // Using icon instead of Image to avoid asset issues
                          color: Colors.blue,
                          size: 24.0,
                        ),
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        borderColor: Colors.grey[300]!,
                      ),
                      const SizedBox(height: 12),

                      // Apple Sign In Button - only shown on iOS
                      if (Platform.isIOS)
                        _SocialSignInButton(
                          onPressed: _signInWithApple,
                          text: _isLogin
                              ? 'Iniciar sesión con Apple'
                              : 'Registrarse con Apple',
                          icon: const Icon(
                            Icons.apple,
                            color: Colors.white,
                            size: 24,
                          ),
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          borderColor: Colors.black,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom social sign-in button widget
class _SocialSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Widget icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _SocialSignInButton({
    required this.onPressed,
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: borderColor),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Make the row take minimum space
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            // Icon with padding
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: icon,
            ),
            // Text that can wrap or be clipped if needed
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:numia/src/constants/app_sizes.dart';
import 'package:numia/src/core/styles/app_styles.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import '../../../core/auth/providers/user_session_provider.dart';
import '../../../routing/app_router.dart';
import '../presentation/controllers/auth_controller.dart';
import '../../../features/dashboard/presentation/providers/post_login_splash_provider.dart';
import '../../../widgets/app_splash_screen.dart';

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
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();

  String _selectedCountryCode = '+595';
  String _selectedCountryDialCode = '595';

  bool _isLogin = true;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _updateUsernameFromEmail(String email) {
    if (email.contains('@')) {
      final username = email.split('@')[0];
      _usernameController.text = username;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Guard against multiple submits
    if (_isLoading) return;

    // Hide keyboard immediately when submitting form
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Handle login
        developer.log('Attempting login with email: ${_emailController.text}',
            name: 'custom_sign_in_screen');

        // Set splash state before API call
        ref.read(postLoginSplashStateProvider.notifier).showSplash();
        developer.log('Splash screen activated before login attempt',
            name: 'custom_sign_in_screen');

        final loginFuture = ref.read(authControllerProvider.notifier).login(
              email: _emailController.text,
              password: _passwordController.text,
            );

        // Wait for login with timeout
        final response = await loginFuture.timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            ref.read(postLoginSplashStateProvider.notifier).hideSplash();
            throw TimeoutException(
                'La conexión ha tardado demasiado tiempo. Verifique su conexión.');
          },
        );

        // Check if still mounted after async operation
        if (!mounted) return;

        if (response != null && response.success) {
          developer.log('Login successful: ${response.message}',
              name: 'custom_sign_in_screen');

          // Check if it's the first login
          final isFirstLogin = response.data?.isFirstLogin ?? false;

          if (isFirstLogin) {
            developer.log('This is the user\'s first login',
                name: 'custom_sign_in_screen');
            // You can add special handling for first-time users here
            // Such as showing a welcome tutorial or collecting additional info
          }

          // Ensure splash is visible
          ref.read(postLoginSplashStateProvider.notifier).showSplash();
          developer.log('Splash activated again before navigation',
              name: 'custom_sign_in_screen');

          // Check mounted before UI operations
          if (!mounted) return;

          // Navigate directly to dashboard - no need for intermediate splash
          // since dashboard will show splash until data loads
          ref.invalidate(goRouterProvider);
          context.go('/dashboard');
          developer.log('Navigation to dashboard initiated with splash active',
              name: 'custom_sign_in_screen');
        } else {
          // Login failure handling
          if (!mounted) return;

          ref.read(postLoginSplashStateProvider.notifier).hideSplash();

          final error = ref.read(authControllerProvider).error;
          final errorMessage =
              response?.message ?? error ?? 'Error al iniciar sesión';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Handle registration
        final registerFuture =
            ref.read(authControllerProvider.notifier).registerUser(
                  email: _emailController.text,
                  password: _passwordController.text,
                  username: _usernameController.text,
                  celular: '$_selectedCountryDialCode${_phoneController.text}',
                  codigoIdentificador: _selectedCountryCode,
                );

        final response = await registerFuture.timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw TimeoutException(
                'La conexión ha tardado demasiado tiempo. Por favor intenta de nuevo.');
          },
        );

        if (!mounted) return;

        if (response != null) {
          setState(() {
            _isLogin = true;
            _passwordController.clear();
            _confirmPasswordController.clear();
            _phoneController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro exitoso. Por favor inicia sesión'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final error = ref.read(authControllerProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Error en el registro'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on TimeoutException catch (e) {
      ref.read(postLoginSplashStateProvider.notifier).hideSplash();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ??
              'La conexión ha tardado demasiado tiempo. Por favor intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ref.read(postLoginSplashStateProvider.notifier).hideSplash();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ha ocurrido un error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Implementation will be added later
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión con Google exitoso')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar sesión con Google'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithApple() async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      if (Platform.isIOS) {
        final appleProvider = OAuthProvider('apple.com');

        try {
          final auth = FirebaseAuth.instance;
          final credential = await auth.signInWithProvider(appleProvider);

          final user = credential.user;
          final displayName = user?.displayName;
          final email = user?.email;

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Inicio de sesión exitoso${displayName != null ? ' como $displayName' : ''}${email != null ? ' ($email)' : ''}'),
            ),
          );
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error con Apple Sign-In: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Inicio de sesión con Apple solo está disponible en dispositivos iOS'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión con Apple: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
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
                  Image.asset(
                    'assets/images/logo256.png',
                    height: 128,
                    width: 128,
                  ),
                  const SizedBox(height: 0),

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
                        : 'Únete a CashAI y comienza a controlar tus finanzas',
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
                          onChanged: (value) {
                            // Update username when email changes
                            if (!_isLogin) {
                              _updateUsernameFromEmail(value);
                            }
                          },
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

                        // Username field (only for registration)
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre de usuario',
                              prefixIcon: const Icon(Icons.person_outline),
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
                                return 'Por favor ingresa un nombre de usuario';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Phone number field with country code picker
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Country code picker
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: CountryCodePicker(
                                  onChanged: (CountryCode countryCode) {
                                    setState(() {
                                      _selectedCountryCode =
                                          countryCode.name ?? '+595';
                                      _selectedCountryDialCode =
                                          countryCode.dialCode ?? '595';
                                    });
                                  },
                                  initialSelection: 'PY',
                                  favorite: const ['PY', 'AR', 'BR'],
                                  showCountryOnly: false,
                                  showOnlyCountryWhenClosed: false,
                                  alignLeft: false,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Phone number input
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Número de celular',
                                    hintText: '9XXXXXXXX',
                                    prefixIcon: const Icon(Icons.phone_android),
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
                                      return 'Por favor ingresa tu número de celular';
                                    }
                                    if (value.length < 9) {
                                      return 'Número de celular inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],

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

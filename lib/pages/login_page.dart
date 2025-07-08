import 'package:flutter/material.dart';
import 'forgot_password_page.dart';
import '../utils//user_session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  bool _isPremium = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _usernameController.text = args['username'] ?? '';
      _emailController.text = args['email'] ?? '';
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final hasUpper = RegExp(r'[A-Z]');
    final hasLower = RegExp(r'[a-z]');
    final hasDigit = RegExp(r'\d');
    if (!hasUpper.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!hasLower.hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!hasDigit.hasMatch(value)) {
      return 'Password must contain at least one digit';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: _validateUsername,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _passwordVisible = !_passwordVisible);
                    },
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 18),
              const Text('Account Type:', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<bool>(
                title: const Text('Free'),
                value: false,
                groupValue: _isPremium,
                onChanged: (val) {
                  setState(() {
                    _isPremium = val!;
                  });
                },
              ),
              RadioListTile<bool>(
                title: const Text('Premium'),
                value: true,
                groupValue: _isPremium,
                onChanged: (val) {
                  setState(() {
                    _isPremium = val!;
                  });
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                    );
                    if (result != null && result is Map<String, String>) {
                      _emailController.text = result['email'] ?? '';
                      _passwordController.text = result['newPassword'] ?? '';
                    }
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    UserSession.setUser(
                      id: 1,
                      name: _usernameController.text.trim(),
                      mail: _emailController.text.trim(),
                      isPremium: _isPremium,
                    );

                    Navigator.pushReplacementNamed(
                      context,
                      '/home',
                      arguments: {
                        'username': _usernameController.text.trim(),
                        'email': _emailController.text.trim(),
                        'premium': _isPremium,
                      },
                    );
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
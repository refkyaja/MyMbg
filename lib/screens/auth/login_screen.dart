import 'package:flutter/material.dart';

import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _error = '';
  bool _obscurePassword = true;

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool success = widget.appState.loginAdmin(
      username: _username.trim(),
      password: _password,
    );

    if (!success) {
      setState(() {
        _error = 'Username atau password salah!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECFDF5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SectionCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: widget.appState.goToRoleSelection,
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text('Batal'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Login Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Dashboard Pengelola MyMbg',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            if (_error.isNotEmpty) ...<Widget>[
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.redSoft,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Username atau password salah!',
                                  style: TextStyle(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                            const Text(
                              'Username',
                              style: TextStyle(
                                color: AppColors.slate700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outline_rounded),
                                hintText: 'Masukkan username',
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username wajib diisi';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                setState(() {
                                  _username = value;
                                  _error = '';
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Password',
                              style: TextStyle(
                                color: AppColors.slate700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                hintText: 'Masukkan password',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password wajib diisi';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                setState(() {
                                  _password = value;
                                  _error = '';
                                });
                              },
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              label: 'Login',
                              onPressed: _submit,
                              expanded: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

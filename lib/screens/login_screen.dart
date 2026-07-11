import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().login(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString(), style: TextStyle(color: Colors.white)), backgroundColor: context.colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDark,
      body: Stack(
        children: [
          // Animated gradient blobs for background
          Positioned(
            top: -150, left: -100,
            child: _GlowBlob(color: context.colors.accent.withOpacity(0.3), size: 400),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).moveY(end: 50, duration: 4.seconds),
          Positioned(
            bottom: -150, right: -100,
            child: _GlowBlob(color: context.colors.accentViolet.withOpacity(0.2), size: 500),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).moveX(end: -50, duration: 5.seconds),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: context.colors.bgCard.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [context.colors.primaryStart, context.colors.primaryEnd],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 24),
                          
                          Text('Welcome Back', 
                              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                          const SizedBox(height: 8),
                          Text('Login to generate viral clips',
                              style: GoogleFonts.inter(color: context.colors.textSecondary, fontSize: 15)),
                          
                          const SizedBox(height: 40),
                          
                          // Email Input
                          TextField(
                            controller: _emailCtrl,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: TextStyle(color: context.colors.textMuted),
                              prefixIcon: Icon(Icons.email_outlined, color: context.colors.textMuted),
                              filled: true,
                              fillColor: context.colors.bgDark.withOpacity(0.5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.primary)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Password Input
                          TextField(
                            controller: _passwordCtrl,
                            style: const TextStyle(color: Colors.white),
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: context.colors.textMuted),
                              prefixIcon: Icon(Icons.lock_outline, color: context.colors.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: context.colors.textMuted),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: context.colors.bgDark.withOpacity(0.5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.primary)),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [context.colors.primaryStart, context.colors.primaryEnd],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: _isLoading 
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                      : Text('Login', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Sign up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account? ", style: GoogleFonts.inter(color: context.colors.textSecondary)),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                                child: Text('Sign up', style: GoogleFonts.inter(color: context.colors.primary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color  color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          )
        ]
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) context.go('/dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Giriş başarısız');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.sidebar,
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 40)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AdminTheme.primary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AdminTheme.gold, width: 1.2),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AdminTheme.gold, size: 26),
                ),
                const SizedBox(height: 24),
                Text(
                  'HIJAPP Butik Paneli',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AdminTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Butiğinizi yönetin, ürünleri yayınlayın, denemeleri izleyin.',
                  style: GoogleFonts.inter(fontSize: 13, color: AdminTheme.textSecondary),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-posta', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) => v == null || !v.contains('@') ? 'Geçerli e-posta girin' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Şifre', prefixIcon: Icon(Icons.lock_outlined)),
                  validator: (v) => v == null || v.length < 6 ? 'En az 6 karakter' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_error!, style: GoogleFonts.inter(color: AdminTheme.error, fontSize: 13)),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AdminTheme.cream, strokeWidth: 2))
                        : Text('Giriş Yap', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: AdminTheme.border, height: 1),
                const SizedBox(height: 16),
                Text(
                  'Butik ortağı olmak için: iletisim@hijapp.com',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: AdminTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

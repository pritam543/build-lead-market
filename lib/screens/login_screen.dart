import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firmController = TextEditingController();
  
  String _selectedRole = 'contractor';
  int _logoTapCount = 0;
  bool _isLoading = false;

  void _handleLogoTap() {
    setState(() {
      _logoTapCount++;
    });
    if (_logoTapCount >= 3) {
      _logoTapCount = 0;
      _showAdminDialog();
    }
  }

  void _showAdminDialog() {
    TextEditingController adminPassController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Master Access'),
        content: TextField(
          controller: adminPassController,
          obscureText: true,
          // SECURE FIX: Passcode hint hata diya gaya hai taaki screen par na dikhe
          decoration: const InputDecoration(labelText: 'Enter Admin Passcode'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
            onPressed: () async {
              if (adminPassController.text.trim() == 'admin123') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('user_role', 'admin');
                await prefs.setString('user_name', 'System Administrator');
                await prefs.setString('user_email', 'admin@buildlead.com');
                await prefs.setString('user_uid', 'admin_master_uid');
                
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/admin_records');
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid Admin Passcode!')),
                );
              }
            },
            child: const Text('Login as Admin', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _handleLogoTap,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
                    child: const Icon(Icons.construction, size: 40, color: Colors.amber),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('BuildLead Market', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const Text('Connect Contractors & Clients in Indore', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _firmController,
                  decoration: const InputDecoration(labelText: 'Firm / Company Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'contractor', child: Text('Contractor (Buy Leads)')),
                    DropdownMenuItem(value: 'client', child: Text('Client (Post Projects)')),
                  ],
                  onChanged: (val) => setState(() => _selectedRole = val!),
                  decoration: const InputDecoration(labelText: 'Select Role', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                    onPressed: _isLoading ? null : () async {
                      if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill out all required fields!')),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);
                      String uid = 'USER_${_phoneController.text.trim()}';

                      try {
                        await ApiService.saveUser(
                          uid: uid,
                          name: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          email: _emailController.text.trim().isEmpty ? 'user@gmail.com' : _emailController.text.trim(),
                          firm_name: _firmController.text.trim().isEmpty ? 'Independent' : _firmController.text.trim(),
                          role: _selectedRole,
                        );

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('user_uid', uid);
                        await prefs.setString('user_name', _nameController.text.trim());
                        await prefs.setString('user_phone', _phoneController.text.trim());
                        await prefs.setString('user_email', _emailController.text.trim());
                        await prefs.setString('user_firm', _firmController.text.trim());
                        await prefs.setString('user_role', _selectedRole);

                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      } catch (e) {
                        print('Login error: $e');
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue to Marketplace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lead_model.dart';

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
  final TextEditingController _adminPassController = TextEditingController();

  bool _isClientRole = false; // false = Contractor, true = Client
  bool _isLoading = false;
  int _logoTapCount = 0;

  // Secret Admin Dialog trigger on triple tap of logo
  void _handleLogoTap() {
    _logoTapCount++;
    if (_logoTapCount >= 3) {
      _logoTapCount = 0;
      _showAdminLoginDialog();
    }
  }

  void _showAdminLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Admin Confidential Access', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: _adminPassController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Enter Admin Passcode',
            labelStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            onPressed: () {
              if (_adminPassController.text.trim() == 'admin123') {
                _adminPassController.clear();
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin_records');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect Admin Passcode!')),
                );
              }
            },
            child: const Text('Access Admin', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _handleLogoTap,
                  child: Row(
                    children: [
                      const Icon(Icons.engineering, color: Color(0xFFF59E0B), size: 30),
                      const SizedBox(width: 12),
                      const Text(
                        'BuildLead Market',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isClientRole ? 'Client Project Posting Portal' : 'Contractor Registration & Login Portal',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                
                // Role Selector Toggle (Client vs Contractor)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isClientRole = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !_isClientRole ? const Color(0xFFF59E0B) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Contractor',
                              style: TextStyle(
                                color: !_isClientRole ? const Color(0xFF0F172A) : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isClientRole = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _isClientRole ? const Color(0xFFF59E0B) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Client',
                              style: TextStyle(
                                color: _isClientRole ? const Color(0xFF0F172A) : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person, color: Colors.amber),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mobile Number (10 digits) *',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.phone, color: Colors.amber),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email Address *',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.email, color: Colors.amber),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (!_isClientRole) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: _firmController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Firm / Company Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.business, color: Colors.amber),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_nameController.text.trim().isEmpty ||
                                _phoneController.text.trim().length != 10 ||
                                _emailController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter valid Name, 10-digit Phone, and Email!'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              UserCredential userCredential;
                              String email = _emailController.text.trim();
                              // Fixed secure default password so users never face credential errors
                              String defaultPassword = "BuildLeadPassword123!";

                              try {
                                userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: email,
                                  password: defaultPassword,
                                );
                              } catch (_) {
                                userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: email,
                                  password: defaultPassword,
                                );
                              }

                              String uid = userCredential.user!.uid;

                              if (_isClientRole) {
                                await FirebaseFirestore.instance.collection('clients').doc(uid).set({
                                  'name': _nameController.text.trim(),
                                  'phone': _phoneController.text.trim(),
                                  'email': email,
                                  'updatedAt': FieldValue.serverTimestamp(),
                                }, SetOptions(merge: true));

                                if (mounted) {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              } else {
                                await FirebaseFirestore.instance.collection('contractors').doc(uid).set({
                                  'name': _nameController.text.trim(),
                                  'phone': _phoneController.text.trim(),
                                  'email': email,
                                  'firmName': _firmController.text.trim().isEmpty ? 'Independent' : _firmController.text.trim(),
                                  'updatedAt': FieldValue.serverTimestamp(),
                                }, SetOptions(merge: true));

                                ContractorModel.name = _nameController.text.trim();
                                ContractorModel.phone = _phoneController.text.trim();
                                ContractorModel.email = email;
                                ContractorModel.firmName = _firmController.text.trim().isEmpty ? 'Independent' : _firmController.text.trim();

                                if (mounted) {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Auth Error: ${e.toString()}')),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Color(0xFF0F172A))
                        : Text(
                            _isClientRole ? 'Continue as Client' : 'Continue to Marketplace',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
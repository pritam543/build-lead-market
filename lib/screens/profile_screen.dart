import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lead_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _displayName = '';
  String _displayFirm = '';
  String _displayPhone = '';
  String _displayEmail = '';

  // Define your official Admin Email here
  final String _adminEmail = 'hr.sbacia@gmail.com'; // Apna official admin email yahan set karein

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _displayEmail = user.email ?? 'N/A';
        
        // Fetch from Firestore 'contractors' collection
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('contractors').doc(user.uid).get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _displayName = data['name'] ?? 'Verified Professional';
            _displayFirm = data['firmName'] ?? 'Independent';
            _displayPhone = data['phone'] ?? 'N/A';
          });
        } else {
          setState(() {
            _displayName = ContractorModel.name.isEmpty ? 'Verified Professional' : ContractorModel.name;
            _displayFirm = ContractorModel.firmName.isEmpty ? 'Independent' : ContractorModel.firmName;
            _displayPhone = ContractorModel.phone.isEmpty ? 'N/A' : ContractorModel.phone;
          });
        }
      }
    } catch (e) {
      // Fallback
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _verifyAndOpenAdminPanel() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email?.trim().toLowerCase() == _adminEmail.toLowerCase()) {
      // Allowed: Open Admin Panel directly
      Navigator.pushNamed(context, '/admin_records');
    } else {
      // Denied for normal contractors/clients
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access Denied: Only authorized administrator can view confidential records!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Contractor Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(radius: 28, backgroundColor: Color(0xFFF59E0B), child: Icon(Icons.person, size: 32, color: Colors.black)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _displayName.isEmpty ? 'Not Provided' : _displayName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Firm: $_displayFirm',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📞 $_displayPhone  | ✉️ $_displayEmail',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                const Text('📍 Indore, India', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text('Verification Status: Verified Professional', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.bookmark_border, color: Color(0xFF1E293B)),
                        title: Text('My Unlocked Leads (${GlobalData.unlockedLeads.length})'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          await Navigator.pushNamed(context, '/my_leads');
                          setState(() {});
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings, color: Colors.amber),
                        title: const Text('Admin Purchase Records'),
                        subtitle: const Text('Confidential: View all UTR & marketplace logs', style: TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.lock_open, size: 16, color: Colors.green),
                        onTap: _verifyAndOpenAdminPanel,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.help_outline, color: Colors.blue),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.pushNamed(context, '/support'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Logout', style: TextStyle(color: Colors.red)),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFFF59E0B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/my_leads');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'My Leads'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
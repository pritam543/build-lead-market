import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _displayName = '';
  String _displayEmail = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _displayName = prefs.getString('user_name') ?? 'User';
        _displayEmail = prefs.getString('user_email') ?? 'N/A';
        _role = prefs.getString('user_role') ?? 'contractor';
      });
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

  @override
  Widget build(BuildContext context) {
    bool isAdmin = _role.toLowerCase() == 'admin';
    bool isClient = _role.toLowerCase() == 'client';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(isAdmin ? 'Admin Control Center' : (isClient ? 'Client Profile' : 'Contractor Profile'), style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                          CircleAvatar(
                            radius: 28, 
                            backgroundColor: isAdmin ? Colors.amber : const Color(0xFF1E293B), 
                            child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, size: 32, color: isAdmin ? Colors.black : Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAdmin ? 'System Administrator' : _displayName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAdmin ? 'Full Database Access & Master Control' : (isClient ? 'Role: Project Poster (Client)' : 'Role: Verified Contractor'),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '✉️ $_displayEmail',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text('Account Type: ${_role.toUpperCase()} | Status: Active & Secured', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      if (isAdmin) ...[
                        ListTile(
                          leading: const Icon(Icons.dashboard, color: Colors.amber, size: 24),
                          title: const Text('Open Master Data Sheets (Admin Dashboard)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          subtitle: const Text('View all Users, Posted Leads, and UTR Purchases'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.pushNamed(context, '/admin_records'),
                        ),
                        const Divider(height: 1),
                      ],
                      if (!isAdmin) ...[
                        ListTile(
                          leading: Icon(isClient ? Icons.folder_shared : Icons.bookmark_border, color: const Color(0xFF1E293B)),
                          title: Text(isClient ? 'My Posted Projects' : 'My Unlocked Leads'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            await Navigator.pushNamed(context, isClient ? '/home' : '/my_leads');
                            setState(() {});
                          },
                        ),
                        const Divider(height: 1),
                      ],
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
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
          if (index == 1 && !isAdmin) Navigator.pushReplacementNamed(context, isClient ? '/home' : '/my_leads');
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(isAdmin ? Icons.admin_panel_settings : Icons.assignment), label: isAdmin ? 'Dashboard' : 'Projects'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
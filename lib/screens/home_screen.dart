import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'All Leads';
  late Future<List<dynamic>> _leadsFuture;
  List<dynamic> _unlockedLeadIds = [];
  String _userRole = '';
  String _contractorUid = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? 'contractor';
      _contractorUid = prefs.getString('user_uid') ?? '';
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _leadsFuture = ApiService.getLeads();
    });
    if (_userRole == 'contractor' && _contractorUid.isNotEmpty) {
      final unlocked = await ApiService.getUnlockedLeads(_contractorUid);
      setState(() {
        _unlockedLeadIds = unlocked.map((lead) => lead['id']).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isClient = _userRole.toLowerCase() == 'client';
    bool isAdmin = _userRole.toLowerCase() == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BuildLead Market', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            Text(
              isAdmin ? '👑 Administrator View' : (isClient ? '🏢 Logged in as Client (Project Poster)' : '👷 Logged in as Contractor (Lead Buyer)'),
              style: const TextStyle(fontSize: 11, color: Colors.amber),
            ),
          ],
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
              tooltip: 'Admin Dashboard',
              onPressed: () => Navigator.pushNamed(context, '/admin_records'),
            ),
          if (isClient)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.amber),
              tooltip: 'Post Project',
              onPressed: () async {
                await Navigator.pushNamed(context, '/post_lead');
                _fetchData();
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchData,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, '/profile');
              setState(() {});
            },
            child: const CircleAvatar(radius: 14, backgroundColor: Colors.amber, child: Icon(Icons.person, size: 16, color: Colors.black)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All Leads'),
                  _buildFilterChip('Residential'),
                  _buildFilterChip('Commercial'),
                  _buildFilterChip('Renovation'),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _leadsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No leads available in database.', style: TextStyle(color: Colors.grey)));
                }

                List<dynamic> allLeads = snapshot.data!;
                List<dynamic> displayedLeads = allLeads.where((lead) {
                  if (selectedFilter == 'All Leads') return true;
                  String cat = lead['category'] ?? 'Residential';
                  return cat.toLowerCase() == selectedFilter.toLowerCase();
                }).toList();

                if (displayedLeads.isEmpty) {
                  return const Center(child: Text('No leads available in this category.', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayedLeads.length,
                  itemBuilder: (context, index) {
                    final lead = displayedLeads[index];
                    int leadId = lead['id'];
                    bool isUnlocked = _unlockedLeadIds.contains(leadId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(lead['category'] ?? 'Residential', style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              Text(lead['created_at'] != null ? lead['created_at'].toString().substring(0, 10) : 'New', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(lead['project_name'] ?? 'Construction Project', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 15, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 6),
                              Text('Client: ${lead['client_name'] ?? 'Verified Client'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                              const Spacer(),
                              const Icon(Icons.location_on, size: 15, color: Colors.redAccent),
                              const SizedBox(width: 4),
                              Text(lead['location'] ?? 'Indore', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Icon(Icons.square_foot, size: 16, color: Colors.blueGrey),
                                  const SizedBox(width: 6),
                                  Text('Area: ${lead['area'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                                ]),
                                Row(children: [
                                  const Icon(Icons.account_balance_wallet, size: 16, color: Colors.green),
                                  const SizedBox(width: 6),
                                  Text('Budget: ${lead['budget'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                ]),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // SIRF CONTRACTOR KE LIYE UNLOCK STATUS DIKHEGA
                          if (!isClient) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isUnlocked ? Colors.green.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isUnlocked ? Colors.green.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(isUnlocked ? Icons.check_circle : Icons.lock, size: 16, color: isUnlocked ? Colors.green : Colors.amber),
                                  const SizedBox(width: 8),
                                  Text(
                                    isUnlocked ? 'Lead Unlocked! Check "My Leads" for Contact Info.' : 'Client Contact Hidden (🔒 Unlock to View)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.green.shade800 : const Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Unlock Fee: ₹500', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                                isUnlocked
                                    ? const Chip(
                                        backgroundColor: Colors.green,
                                        label: Text('Already Unlocked', style: TextStyle(color: Colors.white, fontSize: 11)),
                                      )
                                    : ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1E293B),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                        onPressed: () async {
                                          await Navigator.pushNamed(context, '/payment', arguments: lead);
                                          _fetchData();
                                        },
                                        child: const Text('Unlock Lead', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 6),
                            const Center(
                              child: Text('Client Mode: You can post new projects from the top icon.', style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFF59E0B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) async {
          if (index == 1) {
            await Navigator.pushNamed(context, isClient ? '/home' : '/my_leads');
            setState(() {});
          } else if (index == 3) {
            await Navigator.pushNamed(context, '/profile');
            setState(() {});
          }
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

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B) : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0F172A) : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}
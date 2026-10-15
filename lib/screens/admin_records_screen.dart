import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminRecordsScreen extends StatefulWidget {
  const AdminRecordsScreen({Key? key}) : super(key: key);

  @override
  State<AdminRecordsScreen> createState() => _AdminRecordsScreenState();
}

class _AdminRecordsScreenState extends State<AdminRecordsScreen> {
  late Future<List<dynamic>> _purchasesFuture;
  late Future<List<dynamic>> _usersFuture;
  late Future<List<dynamic>> _leadsFuture;

  int _selectedTab = 0; // 0: Purchases/UTR, 1: Users, 2: Leads

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _purchasesFuture = _fetchData('admin/purchases');
      _usersFuture = _fetchData('admin/users');
      _leadsFuture = _fetchData('admin/leads');
    });
  }

  Future<List<dynamic>> _fetchData(String endpoint) async {
    try {
    final response = await http.get(Uri.parse('https://build-lead-market.onrender.com/api/$endpoint'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching $endpoint: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Admin Master Dashboard (Permanent DB Sheets)',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            tooltip: 'Refresh Data',
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Exit Admin',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAdminTab(0, 'UTR Purchases', Icons.receipt_long),
                _buildAdminTab(1, 'All Users & Counts', Icons.people),
                _buildAdminTab(2, 'All Posted Leads', Icons.assignment),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? _buildPurchasesView()
                : _selectedTab == 1
                    ? _buildUsersView()
                    : _buildLeadsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTab(int index, String label, IconData icon) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B) : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFF0F172A) : Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasesView() {
    return FutureBuilder<List<dynamic>>(
      future: _purchasesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No UTR purchase records found in database.', style: TextStyle(color: Colors.grey)));
        }
        final list = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Project: ${item['project_name'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(item['amount_paid'] ?? '₹500', style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Text('Contractor: ${item['contractor_name']} (${item['contractor_phone']})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Client Name: ${item['client_name']} | Client Phone: ${item['client_phone']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('UTR Number: ${item['utr_number']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUsersView() {
    return FutureBuilder<List<dynamic>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No registered users found in database.', style: TextStyle(color: Colors.grey)));
        }
        final list = snapshot.data!;
        
        // Count Contractors and Clients dynamically
        int contractorCount = list.where((u) => (u['role'] ?? '').toString().toLowerCase() == 'contractor').length;
        int clientCount = list.where((u) => (u['role'] ?? '').toString().toLowerCase() == 'client').length;

        return Column(
          children: [
            // Summary Counter Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Total Contractors', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('$contractorCount', style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(height: 30, width: 1, color: Colors.white24),
                  Column(
                    children: [
                      const Text('Total Clients', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('$clientCount', style: const TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final user = list[index];
                  bool isClient = (user['role'] ?? '').toString().toLowerCase() == 'client';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isClient ? Colors.blueGrey : const Color(0xFF1E293B),
                          child: Icon(isClient ? Icons.business : Icons.person, color: Colors.amber),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(user['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isClient ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      (user['role'] ?? 'contractor').toUpperCase(),
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isClient ? Colors.blue : Colors.orange.shade800),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('Firm: ${user['firm_name'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text('📞 ${user['phone']} | ✉️ ${user['email']}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeadsView() {
    return FutureBuilder<List<dynamic>>(
      future: _leadsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No leads posted in marketplace.', style: TextStyle(color: Colors.grey)));
        }
        final list = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final lead = list[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lead['project_name'] ?? 'Project', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                      Text(lead['category'] ?? 'Residential', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Location: ${lead['location']} | Budget: ${lead['budget']} | Area: ${lead['area']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('Client: ${lead['client_name']} (Phone: ${lead['phone']}, Email: ${lead['email']})', style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
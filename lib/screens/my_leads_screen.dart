import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class MyLeadsScreen extends StatefulWidget {
  const MyLeadsScreen({Key? key}) : super(key: key);

  @override
  State<MyLeadsScreen> createState() => _MyLeadsScreenState();
}

class _MyLeadsScreenState extends State<MyLeadsScreen> {
  late Future<List<dynamic>> _unlockedLeadsFuture;
  String contractorUid = '';

  @override
  void initState() {
    super.initState();
    _loadContractorData();
  }

  Future<void> _loadContractorData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      contractorUid = prefs.getString('user_uid') ?? '';
      _unlockedLeadsFuture = ApiService.getUnlockedLeads(contractorUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('My Unlocked Leads', style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _unlockedLeadsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No unlocked leads found. Unlock leads from Home screen.', style: TextStyle(color: Colors.grey)),
            );
          }

          final leads = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lead['project_name'] ?? 'Project', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 6),
                    Text('Location: ${lead['location']} | Budget: ${lead['budget']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Divider(height: 20),
                    const Text('🔓 Unlocked Client Details:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 6),
                    Text('Name: ${lead['client_name'] ?? 'N/A'}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Phone: ${lead['phone'] ?? 'N/A'}', style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Email: ${lead['email'] ?? 'client@gmail.com'}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFFF59E0B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
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
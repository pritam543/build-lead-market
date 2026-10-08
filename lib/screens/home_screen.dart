import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lead_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'All Leads';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BuildLead Market',
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              '📍 Indore, Madhya Pradesh',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.amber),
            tooltip: 'Post Lead',
            onPressed: () async {
              await Navigator.pushNamed(context, '/post_lead');
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Notifications'),
                  content: const Text('New verified construction lead posted in Indore!'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, '/profile');
              setState(() {});
            },
            child: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, size: 16, color: Colors.black),
            ),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('leads')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No leads available in Cloud Database.', style: TextStyle(color: Colors.grey)),
                  );
                }

                // Parse Firestore documents into LeadModel list
                List<LeadModel> allCloudLeads = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return LeadModel(
                    title: data['title'] ?? 'Construction Project',
                    location: data['location'] ?? 'Indore',
                    specs: data['specs'] ?? 'Not Specified',
                    budget: data['budget'] ?? 'Negotiable',
                    category: data['category'] ?? 'Residential',
                    fee: data['fee'] ?? '₹500',
                    clientName: data['clientName'] ?? 'Verified Client',
                    clientPhone: data['clientPhone'] ?? '',
                    clientEmail: data['clientEmail'] ?? '',
                    timeAgo: data['timeAgo'] ?? 'Just now',
                  );
                }).toList();

                // Apply category filter
                List<LeadModel> displayedLeads = allCloudLeads.where((lead) {
                  if (selectedFilter == 'All Leads') return true;
                  return lead.category.toLowerCase() == selectedFilter.toLowerCase();
                }).toList();

                if (displayedLeads.isEmpty) {
                  return const Center(
                    child: Text('No leads available in this category.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayedLeads.length,
                  itemBuilder: (context, index) {
                    final lead = displayedLeads[index];
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(lead.category, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              Text(lead.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lead.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 8),
                          
                          // Highlighted Client & Location Row
                          Row(
                            children: [
                              const Icon(Icons.person, size: 15, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 6),
                              Text('Client: ${lead.clientName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                              const Spacer(),
                              const Icon(Icons.location_on, size: 15, color: Colors.redAccent),
                              const SizedBox(width: 4),
                              Text(lead.location, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Area and Budget Highlight Container
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
                                Row(
                                  children: [
                                    const Icon(Icons.square_foot, size: 16, color: Colors.blueGrey),
                                    const SizedBox(width: 6),
                                    Text('Area: ${lead.specs}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.account_balance_wallet, size: 16, color: Colors.green),
                                    const SizedBox(width: 6),
                                    Text('Budget: ${lead.budget}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.lock, size: 16, color: Colors.amber),
                                SizedBox(width: 8),
                                Text(
                                  'Client Phone & Email Hidden (🔒 Unlock Lead to View)',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Unlock Fee: ${lead.fee}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E293B),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                onPressed: () async {
                                  await Navigator.pushNamed(context, '/payment', arguments: lead);
                                  setState(() {});
                                },
                                child: const Text('Unlock Lead', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ),
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
            await Navigator.pushNamed(context, '/my_leads');
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
          color: isSelected ? const Color(0xFFF50E0B) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0F172A) : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}
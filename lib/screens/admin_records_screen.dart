import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRecordsScreen extends StatelessWidget {
  const AdminRecordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Admin Confidential Database', style: TextStyle(color: Colors.white, fontSize: 16)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: 'Purchase Logs', icon: Icon(Icons.receipt_long, size: 18)),
              Tab(text: 'Contractors', icon: Icon(Icons.people, size: 18)),
              Tab(text: 'Client Leads', icon: Icon(Icons.business_center, size: 18)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Purchase Logs (StreamBuilder from Firestore 'purchases')
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('purchases')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No purchase records in database yet.', style: TextStyle(color: Colors.grey)));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    String leadTitle = data['leadTitle'] ?? 'N/A';
                    String amountPaid = data['amountPaid'] ?? '₹500';
                    String cName = data['contractorName'] ?? 'N/A';
                    String cPhone = data['contractorPhone'] ?? 'N/A';
                    String cEmail = data['contractorEmail'] ?? 'N/A';
                    String clientName = data['clientName'] ?? 'N/A';
                    String clientPhone = data['clientPhone'] ?? 'N/A';
                    String utrNumber = data['utrNumber'] ?? 'N/A';
                    String purchaseTime = data['purchaseTime'] ?? 'Just now';

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
                              Expanded(
                                child: Text(leadTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text('Fee: $amountPaid', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          const Text('👷 Contractor Details:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          Text('• Name: $cName', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('• Phone: $cPhone | Email: $cEmail', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 10),
                          const Text('👤 Client Details:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          Text('• Name: $clientName', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('• Phone: $clientPhone', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('UTR Ref: $utrNumber', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                              Text(purchaseTime, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // Tab 2: Registered Contractors List (StreamBuilder from Firestore 'contractors')
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('contractors').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No registered contractors in database.', style: TextStyle(color: Colors.grey)));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    String name = data['name'] ?? 'N/A';
                    String firm = data['firmName'] ?? 'Independent';
                    String phone = data['phone'] ?? 'N/A';
                    String email = data['email'] ?? 'N/A';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.person, color: Colors.black)),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Firm: $firm\nPhone: $phone | Email: $email', style: const TextStyle(fontSize: 12)),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),

            // Tab 3: Active Client Leads (StreamBuilder from Firestore 'leads')
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('leads').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No active leads in marketplace.', style: TextStyle(color: Colors.grey)));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    String title = data['title'] ?? 'N/A';
                    String clientName = data['clientName'] ?? 'N/A';
                    String location = data['location'] ?? 'N/A';
                    String budget = data['budget'] ?? 'N/A';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('Client Name: $clientName (Contact hidden on marketplace until unlocked)', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                          Text('Location: $location | Budget: $budget', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
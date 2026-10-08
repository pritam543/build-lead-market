import 'package:flutter/material.dart';
import '../models/lead_model.dart';

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
            // Tab 1: Purchase Logs (Contractor + Client + Project + UTR)
            GlobalData.allPurchases.isEmpty
                ? const Center(child: Text('No purchase records in database yet.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: GlobalData.allPurchases.length,
                    itemBuilder: (context, index) {
                      final record = GlobalData.allPurchases[index];
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
                                Text(record.leadTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text('Fee: ', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            const Text('👷 Contractor Details:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                            Text('• Name:  ()', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('• Phone:  | Email: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 10),
                            const Text('👤 Client Details:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                            Text('• Name: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('• Phone: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('UTR Ref: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                                Text(record.purchaseTime, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

            // Tab 2: Registered Contractors List
            GlobalData.registeredContractors.isEmpty
                ? const Center(child: Text('No registered contractors in database.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: GlobalData.registeredContractors.length,
                    itemBuilder: (context, index) {
                      final c = GlobalData.registeredContractors[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.person, color: Colors.black)),
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Firm: \nPhone:  | Email: ', style: const TextStyle(fontSize: 12)),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),

            // Tab 3: Active Client Leads
            GlobalData.allLeads.isEmpty
                ? const Center(child: Text('No active leads in marketplace.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: GlobalData.allLeads.length,
                    itemBuilder: (context, index) {
                      final l = GlobalData.allLeads[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('Client Name:  (Contact hidden on marketplace until unlocked)', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            Text('Location:  | Budget: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

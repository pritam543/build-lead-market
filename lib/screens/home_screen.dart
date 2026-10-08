import 'package:flutter/material.dart';
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
    List<LeadModel> displayedLeads = GlobalData.allLeads.where((lead) {
      if (selectedFilter == 'All Leads') return true;
      return lead.category.toLowerCase() == selectedFilter.toLowerCase();
    }).toList();

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
            child: displayedLeads.isEmpty
                ? const Center(child: Text('No leads available in this category.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
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
                            // Project Title
                            Text(
                              lead.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 6),
                            // Client Name & Location
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 14, color: Colors.blueGrey),
                                const SizedBox(width: 4),
                                Text('Client: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                Text(lead.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Project Specs (Area & Budget)
                            Row(
                              children: [
                                Text('📐 Area: ', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                const SizedBox(width: 16),
                                Text('💰 Budget: ', style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Hidden Contact Notice Box
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
                                Text('Unlock Fee: ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
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
          color: isSelected ? const Color(0xFFF59E0B) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0F172A) : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lead_model.dart';

class PostLeadScreen extends StatefulWidget {
  const PostLeadScreen({Key? key}) : super(key: key);

  @override
  State<PostLeadScreen> createState() => _PostLeadScreenState();
}

class _PostLeadScreenState extends State<PostLeadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientPhoneController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _specsController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _feeController = TextEditingController(text: '₹500');

  String _category = 'Residential';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Post Construction Lead (Client)', style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Client & Project Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Enter project requirements. Contact details will remain hidden until a verified contractor unlocks the lead.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          TextField(
            controller: _clientNameController,
            decoration: InputDecoration(
              labelText: 'Client Full Name *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.person, color: Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _clientPhoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Client Mobile Number *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.phone, color: Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _clientEmailController,
            decoration: InputDecoration(
              labelText: 'Client Email Address',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.email, color: Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Project Title (e.g. 3BHK Villa Construction) *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.title, color: Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location (e.g. Vijay Nagar, Indore) *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.location_on, color: Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _specsController,
                  decoration: InputDecoration(
                    labelText: 'Area / Specs (e.g. 1500 Sq. Ft.)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _budgetController,
                  decoration: InputDecoration(
                    labelText: 'Budget (e.g. ₹30L - 45L)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['Residential', 'Commercial', 'Renovation'].map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _feeController,
                  decoration: InputDecoration(
                    labelText: 'Unlock Fee (e.g. ₹500)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_titleController.text.trim().isEmpty ||
                          _clientNameController.text.trim().isEmpty ||
                          _clientPhoneController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill Client Name, Phone, and Project Title!')),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        String title = _titleController.text.trim();
                        String location = _locationController.text.trim().isEmpty ? 'Indore, MP' : _locationController.text.trim();
                        String specs = _specsController.text.trim().isEmpty ? 'Standard' : _specsController.text.trim();
                        String budget = _budgetController.text.trim().isEmpty ? 'Open Budget' : _budgetController.text.trim();
                        String fee = _feeController.text.trim().isEmpty ? '₹500' : _feeController.text.trim();
                        String clientName = _clientNameController.text.trim();
                        String clientPhone = _clientPhoneController.text.trim();
                        String clientEmail = _clientEmailController.text.trim().isEmpty ? 'N/A' : _clientEmailController.text.trim();

                        // 1. Save lead to Cloud Firestore Database
                        await FirebaseFirestore.instance.collection('leads').add({
                          'title': title,
                          'location': location,
                          'specs': specs,
                          'budget': budget,
                          'category': _category,
                          'fee': fee,
                          'clientName': clientName,
                          'clientPhone': clientPhone,
                          'clientEmail': clientEmail,
                          'timeAgo': 'Just now',
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        // 2. Add posted lead to local global storage list
                        GlobalData.allLeads.insert(
                          0,
                          LeadModel(
                            title: title,
                            location: location,
                            specs: specs,
                            budget: budget,
                            category: _category,
                            fee: fee,
                            clientName: clientName,
                            clientPhone: clientPhone,
                            clientEmail: clientEmail,
                            timeAgo: 'Just now',
                          ),
                        );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lead posted successfully to Cloud Marketplace!')),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error posting lead: ${e.toString()}ger')),
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
                  : const Text('Publish Lead to Marketplace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ),
          ),
        ],
      ),
    );
  }
}
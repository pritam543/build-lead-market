import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostLeadScreen extends StatefulWidget {
  const PostLeadScreen({Key? key}) : super(key: key);

  @override
  State<PostLeadScreen> createState() => _PostLeadScreenState();
}

class _PostLeadScreenState extends State<PostLeadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientPhoneController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  
  String _selectedCategory = 'Residential';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Post New Construction Project', style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Project Title / Description', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location (e.g., Vijay Nagar, Indore)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _areaController,
            decoration: const InputDecoration(labelText: 'Area (e.g., 2000 Sq. Ft.)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _budgetController,
            decoration: const InputDecoration(labelText: 'Budget (e.g., ₹30L - ₹35L)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: ['Residential', 'Commercial', 'Renovation'].map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (val) => setState(() => _selectedCategory = val!),
            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _clientNameController,
            decoration: const InputDecoration(labelText: 'Your Name (Client)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _clientPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Your Phone Number', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _clientEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Your Email Address', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
              onPressed: _isLoading ? null : () async {
                if (_titleController.text.trim().isEmpty || _clientPhoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill out required fields!')),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  final response = await http.post(
                    Uri.parse('https://build-lead-market.onrender.com/api/leads'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'project_name': _titleController.text.trim(),
                      'location': _locationController.text.trim().isEmpty ? 'Indore' : _locationController.text.trim(),
                      'area': _areaController.text.trim().isEmpty ? '1500 Sq. Ft.' : _areaController.text.trim(),
                      'budget': _budgetController.text.trim().isEmpty ? '₹25L' : _budgetController.text.trim(),
                      'category': _selectedCategory,
                      'client_name': _clientNameController.text.trim(),
                      'phone': _clientPhoneController.text.trim(),
                      'email': _clientEmailController.text.trim().isEmpty ? 'client@gmail.com' : _clientEmailController.text.trim(),
                    }),
                  );

                  if (response.statusCode == 200) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Project Posted Successfully to Marketplace!')),
                      );
                      Navigator.pop(context);
                    }
                  }
                } catch (e) {
                  print('Error posting lead: $e');
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Post Project to Marketplace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ),
          ),
        ],
      ),
    );
  }
}
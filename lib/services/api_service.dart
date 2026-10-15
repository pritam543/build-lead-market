import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Yahan apna Render ka live URL daal dein (Ending mein /api lagana zaroori hai)
  final String baseUrl = 'https://build-lead-market.onrender.com/api';

  // 1. Save User (Signup/Login)
  Future<bool> saveUser({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required String firmName,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'name': name,
          'phone': phone,
          'email': email,
          'firm_name': firmName,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // 2. Post New Lead (Client)
  Future<bool> postLead({
    required String projectName,
    required String location,
    required String area,
    required String budget,
    required String category,
    required String clientName,
    required String phone,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leads'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'project_name': projectName,
          'location': location,
          'area': area,
          'budget': budget,
          'category': category,
          'client_name': clientName,
          'phone': phone,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error posting lead: $e');
      return false;
    }
  }

  // 3. Get All Leads (Marketplace)
  Future<List<dynamic>> getLeads() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leads'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching leads: $e');
      return [];
    }
  }

  // 4. Purchase Lead (Contractor UTR Save)
  Future<bool> purchaseLead({
    required int leadId,
    required String contractorUid,
    required String contractorName,
    required String contractorPhone,
    required String utrNumber,
    required double amountPaid,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lead_id': leadId,
          'contractor_uid': contractorUid,
          'contractor_name': contractorName,
          'contractor_phone': contractorPhone,
          'utr_number': utrNumber,
          'amount_paid': amountPaid,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error purchasing lead: $e');
      return false;
    }
  }

  // 5. Get Unlocked Leads for Contractor
  Future<List<dynamic>> getUnlockedLeads(String contractorUid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/unlocked-leads?uid=$contractorUid'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching unlocked leads: $e');
      return [];
    }
  }
}
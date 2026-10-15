import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://build-lead-market.onrender.com/api';

  // 1. Save User
  static Future<bool> saveUser({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required String firm_name,
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
          'firm_name': firm_name,
          'role': role,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error saving user: $e');
    }
    return false;
  }

  // 2. Get All Marketplace Leads
  static Future<List<dynamic>> getLeads() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leads'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching leads: $e');
    }
    return [];
  }

  // 3. Post New Lead (Client Project)
  static Future<bool> postLead({
    required String clientName,
    required String projectName,
    required String area,
    required String location,
    required String budget,
    required String category,
    required String phone,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leads'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'client_name': clientName,
          'project_name': projectName,
          'area': area,
          'location': location,
          'budget': budget,
          'category': category,
          'phone': phone,
          'email': email,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      print('Error posting lead: $e');
    }
    return false;
  }

  // 4. Purchase Lead (Save UTR & Unlock Contact Details)
  static Future<bool> purchaseLead({
    required int leadId,
    required String contractorUid,
    required String contractorName,
    required String contractorPhone,
    required String utrNumber,
    required String amountPaid,
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
        return true;
      }
    } catch (e) {
      print('Error purchasing lead: $e');
    }
    return false;
  }

  // 5. Get Unlocked Leads for Contractor
  static Future<List<dynamic>> getUnlockedLeads(String uid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/unlocked-leads?uid=$uid'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching unlocked leads: $e');
    }
    return [];
  }
}
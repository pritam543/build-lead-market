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
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 2. Get All Leads
  static Future<List<dynamic>> getLeads() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leads'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 3. Get Unlocked Leads
  static Future<List<dynamic>> getUnlockedLeads(String uid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/unlocked-leads?uid=$uid'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 4. Purchase Lead
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
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
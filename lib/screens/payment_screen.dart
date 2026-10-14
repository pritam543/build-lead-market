import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _utrController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> lead = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Secure Lead Unlock & UPI Payment', style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Project: ${lead['project_name'] ?? 'Construction Project'}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 6),
                Text('📍 ${lead['location'] ?? 'Indore'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Unlock Fee:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    Text('₹500', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E293B).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Step 1: Pay via UPI App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                const SizedBox(height: 6),
                const Text('Transfer ₹500 securely using GPay, PhonePe, or Paytm.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('UPI App launched for payment of ₹500.')),
                      );
                    },
                    child: const Text('Pay ₹500 via UPI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Step 2: Enter 12-Digit UTR Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                const SizedBox(height: 6),
                const Text('Enter exact 12-digit UTR reference ID below to verify.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 14),
                TextField(
                  controller: _utrController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: InputDecoration(
                    labelText: '12-Digit UTR Number',
                    hintText: 'Enter 12 digits',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.receipt_long, color: Color(0xFF1E293B)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_utrController.text.trim().length != 12) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a valid 12-digit UTR number!')),
                              );
                              return;
                            }

                            setState(() => _isLoading = true);

                            try {
                              final prefs = await SharedPreferences.getInstance();
                              String contractorUid = prefs.getString('user_uid') ?? 'unknown_uid';
                              String cName = prefs.getString('user_name') ?? 'Contractor';
                              String cPhone = prefs.getString('user_phone') ?? 'N/A';

                              int leadId = lead['id'];
                              String utr = _utrController.text.trim();

                              bool success = await ApiService.purchaseLead(
                                leadId: leadId,
                                contractorUid: contractorUid,
                                contractorName: cName,
                                contractorPhone: cPhone,
                                utrNumber: utr,
                                amountPaid: '₹500',
                              );

                              if (success) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Lead Unlocked Successfully!')),
                                  );
                                  Navigator.pop(context);
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Purchase failed. Please check UTR or connection.')),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: ${e.toString()}')),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Verify UTR & Unlock Lead', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _utrController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? leadData;

  // Yahan apni asli UPI ID daalein aur merchant name BuildLead Market rahega
  final String merchantUpiId = '89640609281@ybl'; 
  final String merchantName = 'BuildLead Market';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      leadData = args;
    }
  }
  

  // UPI Intent / Deep Link Launch karne ka function
  Future<void> _launchUpiPayment() async {
    final String upiUrl = 'upi://pay?pa=$merchantUpiId&pn=${Uri.encodeComponent(merchantName)}&am=500.00&cu=INR&tn=LeadUnlock_${leadData?['id'] ?? 'fee'}';
    
    final Uri uri = Uri.parse(upiUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open UPI app automatically. Please pay via QR/UPI manually.')),
          );
        }
      }
    } catch (e) {
      print('Error launching UPI: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String projectName = leadData?['project_name'] ?? 'Construction Project';
    String location = leadData?['location'] ?? 'Indore';
    int leadId = leadData?['id'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Unlock Lead & Secure Payment', style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lock_open, color: Color(0xFFF59E0B), size: 28),
                    SizedBox(width: 12),
                    Text('Lead Unlock Gateway', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  ],
                ),
                const Divider(height: 24),
                Text('Project: $projectName', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text('Location: $location', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Unlock Fee:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('₹500.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Step 1: Pay via UPI Intent Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    onPressed: _launchUpiPayment,
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text('Pay ₹500 via UPI (GPay/PhonePe/Paytm)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Step 2: Enter 12-Digit UTR Number After Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                TextField(
                  controller: _utrController,
                  decoration: const InputDecoration(
                    labelText: 'Enter UTR / Transaction Reference ID',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 432156789012',
                  ),
                ),
                const SizedBox(height: 20),

                // Step 3: Submit & Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                    onPressed: _isLoading ? null : () async {
                      if (_utrController.text.trim().length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid UTR transaction number!')),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        final prefs = await SharedPreferences.getInstance();
                        String contractorUid = prefs.getString('user_uid') ?? '';
                        String contractorName = prefs.getString('user_name') ?? 'Contractor';
                        String contractorPhone = prefs.getString('user_phone') ?? 'N/A';

                        // Save purchase to MySQL Database permanently
                        bool success = await ApiService.purchaseLead(
                          leadId: leadId,
                          contractorUid: contractorUid,
                          contractorName: contractorName,
                          contractorPhone: contractorPhone,
                          utrNumber: _utrController.text.trim(),
                          amountPaid: '₹500',
                        );

                        if (success) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment Verified & Lead Unlocked Successfully! 🎉')),
                            );
                            Navigator.pushReplacementNamed(context, '/my_leads');
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to save purchase. Try again.')),
                            );
                          }
                        }
                      } catch (e) {
                        print('Payment submission error: $e');
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit & Unlock Lead Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
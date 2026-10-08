import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lead_model.dart';

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
    final LeadModel lead = ModalRoute.of(context)!.settings.arguments as LeadModel;

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
                Text('Project Lead: ${lead.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 6),
                Text('📍 ${lead.location}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Unlock Fee:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    Text(lead.fee, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
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
                Text('Transfer ${lead.fee} securely using GPay, PhonePe, or Paytm.', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('UPI App launched for payment of ${lead.fee}.')),
                      );
                    },
                    child: Text('Pay ${lead.fee} via UPI', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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

                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              User? currentUser = FirebaseAuth.instance.currentUser;
                              String contractorUid = currentUser?.uid ?? 'unknown_uid';
                              String cName = ContractorModel.name.isEmpty ? 'Verified Contractor' : ContractorModel.name;
                              String cPhone = ContractorModel.phone.isEmpty ? 'N/A' : ContractorModel.phone;
                              String cEmail = ContractorModel.email.isEmpty ? (currentUser?.email ?? 'N/A') : ContractorModel.email;
                              String cFirm = ContractorModel.firmName.isEmpty ? 'Independent' : ContractorModel.firmName;

                              // 1. Save purchase record to Firestore 'purchases' collection for Admin Panel
                              await FirebaseFirestore.instance.collection('purchases').add({
                                'leadTitle': lead.title,
                                'clientName': lead.clientName,
                                'clientPhone': lead.clientPhone,
                                'contractorUid': contractorUid,
                                'contractorName': cName,
                                'contractorPhone': cPhone,
                                'contractorEmail': cEmail,
                                'contractorFirm': cFirm,
                                'amountPaid': lead.fee,
                                'utrNumber': _utrController.text.trim(),
                                'purchaseTime': 'Just now',
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              // 2. Remove lead from Firestore 'leads' collection to maintain Exclusivity
                              final leadQuery = await FirebaseFirestore.instance
                                  .collection('leads')
                                  .where('title', isEqualTo: lead.title)
                                  .where('clientPhone', isEqualTo: lead.clientPhone)
                                  .get();

                              for (var doc in leadQuery.docs) {
                                await doc.reference.delete();
                              }

                              // 3. Update local lists
                              lead.isUnlocked = true;
                              GlobalData.unlockedLeads.add(lead);
                              GlobalData.allLeads.remove(lead);

                              if (mounted) {
                                Navigator.pushReplacementNamed(context, '/success', arguments: lead);
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error unlocking lead: ${e.toString()}ger')),
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
import 'dart:math';
import 'package:flutter/material.dart';

class LeadModel {
  final int id;
  final String title;
  final String location;
  final String specs;
  final String budget;
  final String category;
  final String fee;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String timeAgo;
  bool isUnlocked;

  LeadModel({
    required this.id,
    required this.title,
    required this.location,
    required this.specs,
    required this.budget,
    required this.category,
    required this.fee,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.timeAgo,
    this.isUnlocked = false,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? 0,
      title: json['project_name'] ?? 'Construction Project',
      location: json['location'] ?? 'Indore',
      specs: json['area'] ?? 'N/A',
      budget: json['budget'] ?? 'N/A',
      category: json['category'] ?? 'Residential',
      fee: '₹500',
      clientName: json['client_name'] ?? 'Verified Client',
      clientPhone: json['phone'] ?? json['client_phone'] ?? 'Hidden',
      clientEmail: json['email'] ?? json['client_email'] ?? 'Hidden',
      timeAgo: json['created_at'] != null ? json['created_at'].toString().substring(0, 10) : 'Just now',
      isUnlocked: false,
    );
  }
}

class RegisteredContractor {
  final String name;
  final String phone;
  final String email;
  final String firmName;
  final String registeredAt;

  RegisteredContractor({
    required this.name,
    required this.phone,
    required this.email,
    required this.firmName,
    required this.registeredAt,
  });
}

class ContractorModel {
  static String name = '';
  static String phone = '';
  static String email = '';
  static String firmName = '';
  static String location = 'Indore, Madhya Pradesh';
}

class PurchaseRecord {
  final String leadTitle;
  final String clientName;
  final String clientPhone;
  final String contractorName;
  final String contractorPhone;
  final String contractorEmail;
  final String contractorFirm;
  final String amountPaid;
  final String utrNumber;
  final String purchaseTime;

  PurchaseRecord({
    required this.leadTitle,
    required this.clientName,
    required this.clientPhone,
    required this.contractorName,
    required this.contractorPhone,
    required this.contractorEmail,
    required this.contractorFirm,
    required this.amountPaid,
    required this.utrNumber,
    required this.purchaseTime,
  });
}

class BackendRepository {
  static final Random _random = Random();
  static final List<String> _locations = ['Vijay Nagar, Indore', 'Palasia, Indore', 'AB Road, Indore', 'South Tukoganj, Indore', 'Bhawarkua, Indore', 'Super Corridor, Indore', 'Scheme No 54, Indore', 'Rau, Indore'];
  static final List<String> _projectTypes = ['3BHK Independent House Construction', 'Commercial Office Interior Setup', 'Duplex Villa Finishing & Flooring', 'Luxury Apartment Renovation', 'Retail Showroom Civil Work', 'Warehouse Flooring & Shed Fabrication', '4BHK Modern Bungalow Structure', 'Restaurant Kitchen & Dining Interior'];

  static String getRandomClientName() => 'Verified Client';
  static String getRandomPhone() => '+91 9876543210';
  static String getRandomLocation() => _locations[_random.nextInt(_locations.length)];

  static List<LeadModel> getInitialBackendLeads() {
    return List.generate(5, (index) {
      String proj = _projectTypes[_random.nextInt(_projectTypes.length)];
      String cat = (proj.contains('Commercial') || proj.contains('Showroom') || proj.contains('Warehouse') || proj.contains('Restaurant')) ? 'Commercial' : (proj.contains('Renovation') ? 'Renovation' : 'Residential');
      return LeadModel(
        id: index + 1,
        title: proj,
        location: getRandomLocation(),
        specs: '1500 Sq. Ft.',
        budget: '₹25L - ₹30L',
        category: cat,
        fee: '₹500',
        clientName: getRandomClientName(),
        clientPhone: getRandomPhone(),
        clientEmail: 'client@gmail.com',
        timeAgo: '2h ago',
      );
    });
  }
}

class GlobalData {
  static List<RegisteredContractor> registeredContractors = [];
  static List<LeadModel> allLeads = BackendRepository.getInitialBackendLeads();
  static List<LeadModel> unlockedLeads = [];
  static List<PurchaseRecord> allPurchases = [];
}
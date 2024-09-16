// lib/models/spare_part.dart
import 'package:flutter/foundation.dart';

class SparePart {
  final String id;
  final String name;
  final String partNumber;
  int quantity;
  final int minimumStockLevel;
  final String supplier;
  final String notes;

  SparePart({
    required this.id,
    required this.name,
    required this.partNumber,
    required this.quantity,
    required this.minimumStockLevel,
    required this.supplier,
    this.notes = '',
  });

  SparePart copyWith({
    String? id,
    String? name,
    String? partNumber,
    int? quantity,
    int? minimumStockLevel,
    String? supplier,
    String? notes,
  }) {
    return SparePart(
      id: id ?? this.id,
      name: name ?? this.name,
      partNumber: partNumber ?? this.partNumber,
      quantity: quantity ?? this.quantity,
      minimumStockLevel: minimumStockLevel ?? this.minimumStockLevel,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'partNumber': partNumber,
      'quantity': quantity,
      'minimumStockLevel': minimumStockLevel,
      'supplier': supplier,
      'notes': notes,
    };
  }

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      id: json['id'],
      name: json['name'],
      partNumber: json['partNumber'],
      quantity: json['quantity'],
      minimumStockLevel: json['minimumStockLevel'],
      supplier: json['supplier'],
      notes: json['notes'],
    );
  }

  @override
  String toString() {
    return 'SparePart(id: $id, name: $name, partNumber: $partNumber, quantity: $quantity, minimumStockLevel: $minimumStockLevel, supplier: $supplier, notes: $notes)';
  }

  bool get isLowStock => quantity <= minimumStockLevel;
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_repository.dart';

class   MachineSerial {
  final String serialNumber;
  final String? assignedUserId;

  MachineSerial({required this.serialNumber, this.assignedUserId});

  Map<String, dynamic> toJson() => {
    'serialNumber': serialNumber,
    'assignedUserId': assignedUserId,
  };

  factory MachineSerial.fromJson(Map<String, dynamic> json) => MachineSerial(
    serialNumber: json['serialNumber'],
    assignedUserId: json['assignedUserId'],
  );
}

class MachineSerialRepository extends BaseRepository<MachineSerial> {
  MachineSerialRepository() : super('machine_serials');

  @override
  MachineSerial fromJson(Map<String, dynamic> json) =>
      MachineSerial.fromJson(json);

  Future<bool> isSerialNumberValid(String serialNumber) async {
    final doc = await getCollection().doc(serialNumber).get();
    return doc.exists;
  }

  Future<void> addSerialNumber(String serialNumber) async {
    await add(serialNumber, MachineSerial(serialNumber: serialNumber));
  }

  Future<void> assignUserToMachine(String serialNumber, String userId) async {
    await update(serialNumber, MachineSerial(serialNumber: serialNumber, assignedUserId: userId));
  }
}
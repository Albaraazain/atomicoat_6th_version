import 'package:experiment_planner/features/machines/models/machine_serial.dart';
import 'package:experiment_planner/shared/base/base_repository.dart';

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
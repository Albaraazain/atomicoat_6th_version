

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


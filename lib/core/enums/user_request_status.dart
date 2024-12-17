enum UserRequestStatus {
  pending,
  approved,
  denied;

  String toJson() => toString().split('.').last;
}
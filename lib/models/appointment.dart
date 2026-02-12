class Appointment {
  final String name;
  final String phone;
  final String address;
  final DateTime createdAt;
  final DateTime appointmentDateTime;

  Appointment({
    required this.name,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.appointmentDateTime,
  });
}
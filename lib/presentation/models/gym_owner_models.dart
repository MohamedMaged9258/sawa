class Gym {
  String id;
  String name;
  String location;
  double pricePerMonth;
  String photo;
  DateTime createdAt;
  double? latitude;
  double? longitude;

  Gym({
    required this.id,
    required this.name,
    required this.location,
    required this.pricePerMonth,
    required this.photo,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });
}

class Coach {
  String id;
  String name;
  String experience;
  String photo;
  String specialization;
  DateTime joinedDate;

  Coach({
    required this.id,
    required this.name,
    required this.experience,
    required this.photo,
    required this.specialization,
    required this.joinedDate,
  });
}
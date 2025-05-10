class Rider {
  final String name;
  final String nationality;
  final String team;
  final int age;
  final double weight;

  Rider({
    required this.name,
    required this.nationality,
    required this.team,
    required this.age,
    required this.weight,
  });

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      name: json['name'],
      nationality: json['nationality'],
      team: json['team'],
      age: json['age'],
      weight: json['weight']?.toDouble() ?? 0.0,
    );
  }
}
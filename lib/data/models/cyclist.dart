class Cyclist {
  final String name;
  final String role;
  final int age;
  final String team;
  final String nationality;
  final double weight;
  final double height;
  final String? imageUrl;

  Cyclist({
    required this.name,
    required this.role,
    required this.age,
    required this.team,
    required this.nationality,
    required this.weight,
    required this.height,
    this.imageUrl,
  });

  factory Cyclist.fromJson(Map<String, dynamic> json) {
    return Cyclist(
      name: json['name'],
      role: json['role'],
      age: json['age'],
      team: json['team'],
      nationality: json['nationality'],
      weight: (json['weight'] ?? 70).toDouble(),
      height: (json['height'] ?? 1.75).toDouble(),
    );
  }
}
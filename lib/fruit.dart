class Fruit {
  final String label;
  final String name;
  final String harvest;
  final String weather;
  final String plant;
  final String origin;

  const Fruit(
      {required this.label,
        required this.name,
      required this.harvest,
      required this.weather,
      required this.plant,
      required this.origin});

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
        label: json["label"],
        name: json["name"],
        harvest: json["harvest"],
        weather: json["weather"],
        plant: json["plant"],
        origin: json["origin"]);
  }
}

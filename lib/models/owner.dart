class Owner {
  String id;
  String name;
  double shares;

  Owner({
    required this.id,
    required this.name,
    this.shares = 0.0,
  });

  void addShares(double amount) {
    shares += amount;
  }

  void removeShares(double amount) {
    if (shares < amount) {
      throw Exception('Insufficient shares');
    }
    shares -= amount;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shares': shares,
    };
  }

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'] as String,
      name: json['name'] as String,
      shares: json['shares'] as double,
    );
  }
}

class Owner {
  String id;
  String name;
  double shares; // 份额

  Owner({
    required this.id,
    required this.name,
    this.shares = 0,
  });

  void addShares(double amount) {
    shares += amount;
  }

  void subtractShares(double amount) {
    if (shares >= amount) {
      shares -= amount;
    } else {
      throw Exception('Insufficient shares');
    }
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
      id: json['id'],
      name: json['name'],
      shares: json['shares'],
    );
  }
}

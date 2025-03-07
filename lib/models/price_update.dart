class PriceUpdate {
  final String id;
  final String assetId;
  final double value; // Changed from price to value
  final DateTime timestamp;
  final String? note;

  PriceUpdate({
    required this.id,
    required this.assetId,
    required this.value, // Changed parameter name
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'value': value, // Changed field name
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory PriceUpdate.fromJson(Map<String, dynamic> json) {
    return PriceUpdate(
      id: json['id'],
      assetId: json['assetId'],
      value: json['value'], // Changed field name
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'],
    );
  }

  @override
  String toString() {
    return 'PriceUpdate{id: $id, assetId: $assetId, value: $value, timestamp: $timestamp, note: $note}';
  }
}

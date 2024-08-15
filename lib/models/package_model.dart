class PackageModel {
  final String recipientName;
  final String recipientAddress;
  final String recipientPhone;

  PackageModel({
    required this.recipientName,
    required this.recipientAddress,
    required this.recipientPhone,
  });

  factory PackageModel.fromMap(Map<String, dynamic> map) {
    return PackageModel(
      recipientName: map['recipientName'] as String,
      recipientAddress: map['recipientAddress'] as String,
      recipientPhone: map['recipientPhone'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientName': recipientName,
      'recipientAddress': recipientAddress,
      'recipientPhone': recipientPhone,
    };
  }
}

import 'package:map_app/models/package_model.dart';

class JobModel {
  final String? id;
  final String companyName;
  final String package;
  final num price;
  final List<PackageModel> packages;
  final String? takenBy; // İşin kim tarafından alındığı
  final String? publisherId; // İşin kim tarafından yayınlandığı
  bool isJobCompleted;

  JobModel({
    this.id,
    required this.companyName,
    required this.package,
    required this.price,
    required this.packages,
    this.takenBy,
    this.publisherId,
    this.isJobCompleted = false,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String documentId) {
    return JobModel(
      id: documentId,
      companyName: map['companyName'] as String,
      package: map['package'] as String,
      price: map['price'] as num,
      packages: List<PackageModel>.from(map['packages'].map((x) => PackageModel.fromMap(x))),
      takenBy: map['takenBy'] as String?,
      publisherId: map['publisherId'] as String?,
      isJobCompleted: map['isJobCompleted'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'package': package,
      'price': price,
      'packages': packages.map((x) => x.toMap()).toList(),
      'takenBy': takenBy,
      'publisherId': publisherId,
      'isJobCompleted': isJobCompleted,
    };
  }

  JobModel copyWith({
    String? id,
    String? companyName,
    String? package,
    num? price,
    List<PackageModel>? packages,
    String? depotAddress,
    String? takenBy,
    String? publisherId,
    bool? isJobCompleted,
  }) {
    return JobModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      package: package ?? this.package,
      price: price ?? this.price,
      packages: packages ?? this.packages,
      takenBy: takenBy ?? this.takenBy,
      publisherId: publisherId ?? this.publisherId,
      isJobCompleted: isJobCompleted ?? this.isJobCompleted,
    );
  }
}

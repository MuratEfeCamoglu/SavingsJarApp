class JarModel {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String iconStyle; // Keeping this for backward compatibility
  final String? iconPath;
  final String? status;
  final int? color;
  final bool autoSave;
  final bool locked;
  final DateTime createdAt;
  final String? userId;

  JarModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.iconStyle,
    this.iconPath,
    this.status,
    this.color,
    this.autoSave = false,
    this.locked = false,
    required this.createdAt,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'iconStyle': iconStyle,
      'iconPath': iconPath,
      'status': status,
      'color': color,
      'autoSave': autoSave,
      'locked': locked,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory JarModel.fromMap(Map<String, dynamic> map, String documentId) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value != null && value.runtimeType.toString() == 'Timestamp') {
        try {
          return value.toDate();
        } catch (_) {}
      }
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return JarModel(
      id: documentId,
      name: map['name']?.toString() ?? 'Unnamed Jar',
      targetAmount: parseDouble(map['targetAmount']),
      savedAmount: parseDouble(map['savedAmount']),
      iconStyle: map['iconStyle']?.toString() ?? 'piggy',
      iconPath: map['iconPath']?.toString(),
      status: map['status']?.toString(),
      color: map['color'] is int ? map['color'] as int : null,
      autoSave: map['autoSave'] == true,
      locked: map['locked'] == true,
      createdAt: parseDate(map['createdAt']),
      userId: map['userId']?.toString(),
    );
  }
}

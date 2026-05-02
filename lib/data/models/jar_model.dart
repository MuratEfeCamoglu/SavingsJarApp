class JarModel {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String iconStyle;
  final bool autoSave;
  final bool locked;
  final DateTime createdAt;

  JarModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.iconStyle,
    this.autoSave = false,
    this.locked = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'iconStyle': iconStyle,
      'autoSave': autoSave,
      'locked': locked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory JarModel.fromMap(Map<String, dynamic> map, String documentId) {
    return JarModel(
      id: documentId,
      name: map['name'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      savedAmount: (map['savedAmount'] ?? 0).toDouble(),
      iconStyle: map['iconStyle'] ?? 'piggy',
      autoSave: map['autoSave'] ?? false,
      locked: map['locked'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

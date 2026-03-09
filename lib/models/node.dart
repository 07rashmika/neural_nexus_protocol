enum NodeDifficulty { standard, secured, critical, boss }

class NodeModel {
  const NodeModel({
    required this.id,
    required this.nodeNumber,
    required this.difficulty,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
    this.completedAt,
  });

  final String id;
  final int nodeNumber;
  final NodeDifficulty difficulty;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final DateTime? completedAt;

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    final diffStr = json['difficulty'] as String? ?? 'standard';
    final difficulty = switch (diffStr) {
      'secured'  => NodeDifficulty.secured,
      'critical' => NodeDifficulty.critical,
      'boss'     => NodeDifficulty.boss,
      _          => NodeDifficulty.standard,
    };

    return NodeModel(
      id:          json['id'] as String,
      nodeNumber:  json['nodeNumber'] as int,
      difficulty:  difficulty,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isCurrent:   json['isCurrent'] as bool? ?? false,
      isLocked:    json['isLocked'] as bool? ?? true,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  String get difficultyLabel {
    return switch (difficulty) {
      NodeDifficulty.standard => 'Standard',
      NodeDifficulty.secured  => 'Secured',
      NodeDifficulty.critical => 'Critical',
      NodeDifficulty.boss     => 'Boss',
    };
  }
}
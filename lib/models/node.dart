enum NodeDifficulty { standard, secured, critical, boss }

class NodeModel {
  const NodeModel({
    required this.id,
    required this.nodeNumber,
    required this.difficulty,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
    required this.puzzleCount,
    required this.timerSeconds,
    required this.lives,
    this.completedAt,
  });

  final String id;
  final int nodeNumber;
  final NodeDifficulty difficulty;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final int puzzleCount;    // puzzles per node session
  final int timerSeconds;   // seconds per puzzle
  final int lives;          // wrong answers allowed (boss=1, others=0)
  final DateTime? completedAt;

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    final diffStr    = json['difficulty'] as String? ?? 'standard';
    final difficulty = switch (diffStr) {
      'secured'  => NodeDifficulty.secured,
      'critical' => NodeDifficulty.critical,
      'boss'     => NodeDifficulty.boss,
      _          => NodeDifficulty.standard,
    };

    return NodeModel(
      id:           json['id'] as String,
      nodeNumber:   json['nodeNumber'] as int,
      difficulty:   difficulty,
      puzzleCount:  json['puzzleCount'] as int? ?? 2,
      timerSeconds: json['timerSeconds'] as int? ?? 30,
      lives:        json['lives'] as int? ?? 0,
      isCompleted:  json['isCompleted'] as bool? ?? false,
      isCurrent:    json['isCurrent'] as bool? ?? false,
      isLocked:     json['isLocked'] as bool? ?? true,
      completedAt:  json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  String get difficultyLabel => switch (difficulty) {
    NodeDifficulty.standard => 'Standard',
    NodeDifficulty.secured  => 'Secured',
    NodeDifficulty.critical => 'Critical',
    NodeDifficulty.boss     => 'Boss',
  };

  // Short rule summary shown in node card
  String get rulesLabel {
    final livesText = lives > 0 ? '  ·  $lives spare' : '';
    return '$puzzleCount puzzles  ·  ${timerSeconds}s$livesText';
  }
}
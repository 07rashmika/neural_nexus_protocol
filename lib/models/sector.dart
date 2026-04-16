enum SectorStatus { available, partial, completed, locked }

class Sector {
  const Sector({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.totalNodes,
    required this.completedNodes,
    required this.status,
    this.unlockRequirement,
    this.completedAt,
  });

  final String code;
  final String name;
  final String subtitle;
  final int totalNodes;
  final int completedNodes;
  final SectorStatus status;
  final String? unlockRequirement;
  final DateTime? completedAt;

  factory Sector.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'locked';
    final status = switch (statusStr) {
      'available'  => SectorStatus.available,
      'partial'    => SectorStatus.partial,
      'completed'  => SectorStatus.completed,
      _            => SectorStatus.locked,
    };

    return Sector(
      code:               json['code'] as String,
      name:               json['name'] as String,
      subtitle:           json['subtitle'] as String,
      totalNodes:         json['totalNodes'] as int,
      completedNodes:     json['completedNodes'] as int,
      status:             status,
      unlockRequirement:  json['unlockRequirement'] as String?,
      completedAt:        json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }
}
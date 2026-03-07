class Agent {
  Agent({
    required this.id,
    required this.email,
    required this.sessionToken,
    required this.username,
    required this.avatarUrl,
    required this.intelPoints,
    required this.level,
    required this.position,
    required this.profileComplete,
    this.callsign,
    this.country,
    this.streak = 0,
    this.shieldCount = 3,
    this.chainMultiplier = 1,
    this.lastShieldLostAt,
  });

  final String id;
  final String email;
  final String sessionToken;
  final String username;
  final String avatarUrl;
  final double intelPoints;
  final int level;
  final String position;
  final bool profileComplete;
  final String? callsign;
  final String? country;
  final int streak;
  final int shieldCount;
  final int chainMultiplier;
  final DateTime? lastShieldLostAt; // ← new

  factory Agent.fromJson(Map<String, dynamic> json, {required String token}) {
    return Agent(
      id:               json['id'] as String,
      email:            json['email'] as String,
      sessionToken:     token,
      username:         json['username'] as String? ?? '',
      avatarUrl:        json['avatarUrl'] as String? ?? '',
      intelPoints:      (json['intelPoints'] as num?)?.toDouble() ?? 0.0,
      level:            json['level'] as int? ?? 1,
      position:         json['position'] as String? ?? 'Recruit',
      profileComplete:  json['profileComplete'] as bool? ?? false,
      callsign:         json['callsign'] as String?,
      country:          json['country'] as String?,
      streak:           json['streak'] as int? ?? 0,
      shieldCount:      json['shieldCount'] as int? ?? 3,
      chainMultiplier:  json['chainMultiplier'] as int? ?? 1,
      lastShieldLostAt: json['lastShieldLostAt'] != null
          ? DateTime.tryParse(json['lastShieldLostAt'] as String)
          : null,
    );
  }

  Agent copyWith({
    String? username,
    String? avatarUrl,
    String? callsign,
    String? country,
    bool? profileComplete,
    double? intelPoints,
    int? level,
    String? position,
    int? streak,
    int? shieldCount,
    int? chainMultiplier,
    DateTime? lastShieldLostAt,
    bool clearLastShieldLostAt = false,
  }) {
    return Agent(
      id:               id,
      email:            email,
      sessionToken:     sessionToken,
      username:         username ?? this.username,
      avatarUrl:        avatarUrl ?? this.avatarUrl,
      intelPoints:      intelPoints ?? this.intelPoints,
      level:            level ?? this.level,
      position:         position ?? this.position,
      profileComplete:  profileComplete ?? this.profileComplete,
      callsign:         callsign ?? this.callsign,
      country:          country ?? this.country,
      streak:           streak ?? this.streak,
      shieldCount:      shieldCount ?? this.shieldCount,
      chainMultiplier:  chainMultiplier ?? this.chainMultiplier,
      lastShieldLostAt: clearLastShieldLostAt
          ? null
          : lastShieldLostAt ?? this.lastShieldLostAt,
    );
  }
}
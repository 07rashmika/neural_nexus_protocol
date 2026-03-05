class Agent {
  Agent({
    required this.id,
    required this.email,
    required this.hashPassword,
    required this.sessionToken,
    required this.username,
    required this.intelPoints,
    required this.level,
    required this.position,
    this.streak = 0,
    this.shieldCount = 3,
    this.chainMultiplier = 1,
  });

  final int id;
  final String email;
  final String hashPassword;
  final String sessionToken;
  final String username;
  final double intelPoints;
  final int level;
  final String position;
  final int streak;
  final int shieldCount;
  final int chainMultiplier;
}

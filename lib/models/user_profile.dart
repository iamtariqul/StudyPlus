class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? gradeLevel;
  final String accountStatus;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final String? profileImageUrl;
  final String? bio;
  final List<String> studyGoals;
  final String timezone;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.gradeLevel,
    required this.accountStatus,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.profileImageUrl,
    this.bio,
    this.studyGoals = const [],
    required this.timezone,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String,
      gradeLevel: map['grade_level'] as String?,
      accountStatus: map['account_status'] as String,
      emailVerified: map['email_verified'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'] as String)
          : null,
      profileImageUrl: map['profile_image_url'] as String?,
      bio: map['bio'] as String?,
      studyGoals: map['study_goals'] != null
          ? List<String>.from(map['study_goals'] as List)
          : [],
      timezone: map['timezone'] as String? ?? 'UTC',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'grade_level': gradeLevel,
      'account_status': accountStatus,
      'email_verified': emailVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'study_goals': studyGoals,
      'timezone': timezone,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? gradeLevel,
    String? accountStatus,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    String? profileImageUrl,
    String? bio,
    List<String>? studyGoals,
    String? timezone,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      accountStatus: accountStatus ?? this.accountStatus,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      studyGoals: studyGoals ?? this.studyGoals,
      timezone: timezone ?? this.timezone,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, fullName: $fullName, role: $role, gradeLevel: $gradeLevel, accountStatus: $accountStatus, emailVerified: $emailVerified, createdAt: $createdAt, updatedAt: $updatedAt, lastLogin: $lastLogin, profileImageUrl: $profileImageUrl, bio: $bio, studyGoals: $studyGoals, timezone: $timezone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.role == role &&
        other.gradeLevel == gradeLevel &&
        other.accountStatus == accountStatus &&
        other.emailVerified == emailVerified &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastLogin == lastLogin &&
        other.profileImageUrl == profileImageUrl &&
        other.bio == bio &&
        other.studyGoals == studyGoals &&
        other.timezone == timezone;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        role.hashCode ^
        gradeLevel.hashCode ^
        accountStatus.hashCode ^
        emailVerified.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        lastLogin.hashCode ^
        profileImageUrl.hashCode ^
        bio.hashCode ^
        studyGoals.hashCode ^
        timezone.hashCode;
  }
}

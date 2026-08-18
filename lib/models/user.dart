class StudentProfile {
  final String? educationLevel;
  final int grade;
  final String? stream;
  final String? schoolName;
  final int dailyGoal;
  final String preferredNotificationTime;
  final String timezone;

  StudentProfile({
    this.educationLevel,
    required this.grade,
    this.stream,
    this.schoolName,
    required this.dailyGoal,
    required this.preferredNotificationTime,
    required this.timezone,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      educationLevel: json['education_level'],
      grade: json['grade'] ?? 3,
      stream: json['stream'],
      schoolName: json['school_name'],
      dailyGoal: json['daily_goal'] ?? 10,
      preferredNotificationTime: json['preferred_notification_time'] ?? '18:00',
      timezone: json['timezone'] ?? 'Africa/Algiers',
    );
  }

  Map<String, dynamic> toJson() => {
    'education_level': educationLevel,
    'grade': grade,
    'stream': stream,
    'school_name': schoolName,
    'daily_goal': dailyGoal,
    'preferred_notification_time': preferredNotificationTime,
    'timezone': timezone,
  };
}

class UserStreak {
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;
  final int totalReviewsCount;

  UserStreak({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.totalReviewsCount,
  });

  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastActivityDate: json['last_activity_date'],
      totalReviewsCount: json['total_reviews_count'] ?? 0,
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool isActive;
  final StudentProfile? profile;
  final UserStreak? streak;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    this.profile,
    this.streak,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'student',
      isActive: json['is_active'] ?? true,
      profile: json['profile'] != null ? StudentProfile.fromJson(json['profile']) : null,
      streak: json['streak'] != null ? UserStreak.fromJson(json['streak']) : null,
    );
  }
}

class LessonModel {
  final String id;
  final String chapterId;
  final String name;
  final String slug;
  final int order;
  final int cardsCount;

  LessonModel({
    required this.id,
    required this.chapterId,
    required this.name,
    required this.slug,
    required this.order,
    this.cardsCount = 0,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? '',
      chapterId: json['chapter_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      order: json['order'] ?? 1,
      cardsCount: json['cards_count'] ?? 0,
    );
  }
}

class ChapterModel {
  final String id;
  final String subjectId;
  final String name;
  final String slug;
  final int order;
  final List<LessonModel> lessons;

  ChapterModel({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.slug,
    required this.order,
    this.lessons = const [],
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] ?? '',
      subjectId: json['subject_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      order: json['order'] ?? 1,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((l) => LessonModel.fromJson(l))
              .toList() ??
          [],
    );
  }
}

class SubjectModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;
  final int order;
  final int chaptersCount;
  final int totalCardsCount;

  SubjectModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
    required this.order,
    this.chaptersCount = 0,
    this.totalCardsCount = 0,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      iconUrl: json['icon_url'],
      order: json['order'] ?? 1,
      chaptersCount: json['chapters_count'] ?? 0,
      totalCardsCount: json['total_cards_count'] ?? 0,
    );
  }
}

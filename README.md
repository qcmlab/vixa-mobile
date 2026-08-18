# Hafedh Mobile App (تطبيق حافظ للهواتف الذكية)

[![Flutter](https://img.shields.io/badge/Flutter-3.41+-02569B.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2.svg)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State_Management-Flutter_Riverpod_2.6-00D2B8.svg)](https://riverpod.dev)
[![Material 3](https://img.shields.io/badge/Material-3-7C3AED.svg)](https://m3.material.io)

A modern, mobile-first educational application built with **Flutter 3** helping Algerian secondary school students prepare for national exams (**Baccalaureate & BEM**) by memorizing History & Geography content through active recall, **Spaced Repetition (SM-2)**, daily streaks, quizzes, and gamification achievements.

---

## 1. Features

- **Student Authentication & Onboarding**:
  - Email & Password registration with Algerian curriculum stream selector (*Sciences*, *Math*, *Math-Tech*, *Gestion*, *Lettres*, *Langues*).
  - Quick demo student login (`student@hafedh.dz` / `Student12345!`).
  - Persistent JWT Bearer token authentication with auto-login on app launch.

- **Student Home Dashboard**:
  - Live study streak counter (🔥 Flame icon with active streak days).
  - Daily goal completion meter (e.g. 7 / 10 reviews).
  - Prominent **"Start Today's Review" (ابدأ مراجعة اليوم)** button.
  - Learning metrics (Mastered Cards, Overall Accuracy %, Learning cards count, Longest streak).
  - Quick access to History and Geography modules.

- **Spaced Repetition (SM-2) Flashcard Study Session**:
  - Smooth **3D flip card animation** (Question front $\leftrightarrow$ Answer + Explanation back).
  - 4 SM-2 rating buttons:
    - 🟥 `Again` (أعد - 15 minutes)
    - 🟧 `Hard` (صعب - 1 day)
    - 🟩 `Good` (جيد - 3 days)
    - 🟦 `Easy` (سهل - 7 days)
  - Real-time progress bar & session summary celebration screen.

- **Curriculum Hierarchy Explorer**:
  - Interactive drilldown: **Subjects** $\to$ **Chapters** $\to$ **Lessons** $\to$ **Flashcards Preview**.

- **Quizzes & Self-Assessment**:
  - Quiz explorer with time limits and questions count.
  - Timed runner supporting **Multiple Choice** and **True/False** questions.
  - Real-time score calculator and breakdown.

- **Gamification & Achievements**:
  - Badge showcase (Premier Pas, Série 7 Jours, 100 Cartes, Quiz Parfait, etc.) with unlocked/locked status and points.

- **Profile & Settings**:
  - View stream and account info.
  - Set daily review goal.
  - Evening study reminder preferences.
  - Subscription status.

---

## 2. Directory Structure

```
hafedh_mobile/lib/
├── core/
│   ├── constants.dart        # API URLs, Theme colors, storage keys
│   ├── api_client.dart       # HTTP client with Bearer token injection
│   └── storage.dart          # SharedPreferences persistence helper
├── models/
│   ├── user.dart             # UserModel, StudentProfile, UserStreak
│   ├── subject.dart          # SubjectModel, ChapterModel, LessonModel
│   ├── flashcard.dart        # FlashcardModel, TodayReviewsDeck
│   ├── review_submission.dart # ReviewSubmissionResult
│   ├── quiz.dart             # QuizModel, QuestionModel, QuizScoreResult
│   ├── dashboard_data.dart   # DashboardData, DailyActivityPoint
│   └── achievement.dart      # AchievementModel
├── providers/
│   ├── auth_provider.dart    # Login, Register, Session state
│   ├── dashboard_provider.dart # Dashboard metrics state
│   ├── study_provider.dart   # SM-2 study session state & deck
│   ├── content_provider.dart # Subjects & Chapters state
│   └── quiz_provider.dart    # Quiz runner state
├── views/
│   ├── auth/                 # Login & Register screens
│   ├── dashboard/            # Home screen
│   ├── study/                # Spaced repetition study session
│   ├── content/              # Subjects & Lessons screens
│   ├── quizzes/              # Quizzes & Quiz runner screens
│   ├── achievements/         # Achievements badge grid
│   ├── profile/              # Profile & settings screen
│   └── main_navigation_screen.dart # Material 3 Bottom Navigation
├── widgets/
│   ├── custom_button.dart
│   ├── flashcard_view.dart   # 3D Flip Card Widget
│   ├── stat_box.dart
│   └── streak_badge.dart
└── main.dart
```

---

## 3. Running the Mobile App

### Prerequisites
1. **Backend Server Running**:
   ```bash
   cd c:\Users\Informatics\Documents\projects\vixa
   python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

### Run on Windows / Android / iOS / Web:

```bash
# 1. Navigate to directory
cd c:\Users\Informatics\Documents\projects\hafedh_mobile

# 2. Get dependencies
flutter pub get

# 3. Run the application
flutter run
```

> **Note for Android Emulator**: The app automatically detects Android and connects to `http://10.0.2.2:8000/api/v1` (which bridges to your host machine's `localhost:8000`).

---

## 4. Demo Login Credentials

- **Email**: `student@hafedh.dz`
- **Password**: `Student12345!`

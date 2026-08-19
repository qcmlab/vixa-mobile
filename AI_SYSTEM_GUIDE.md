# 🤖 Hafedh Mobile App - AI Agent Architecture & Logic Guide

> **Target Audience**: AI Agents & Flutter Engineers working on the Hafedh (حافظ) Mobile Application.
> **Last Updated**: August 2026

---

## 📌 1. Overview & Pedagogical Mission
**Hafedh Mobile** is a gamified, habit-forming Flutter mobile app designed to help Algerian Baccalaureate students memorize History, Geography, and other subjects effortlessly.
- **Core Concept**: Modeled after the addictive vertical scrolling paradigm of TikTok / Reels, but completely dedicated to curriculum mastery.
- **Learning Flow**: As students swipe vertically, they encounter diverse multi-modality learning cards, answer interactive QCMs, flip 3D flashcards, memorize dates/personalities, and record their mastery status (`0%`, `50%`, `100%`).

---

## 🛠️ 2. Technology Stack & Key Libraries
- **Framework**: Flutter (Dart 3+)
- **State Management & DI**: `flutter_riverpod: ^2.5.1` (Pure Dependency Injection with `autoDispose`)
- **Offline Storage**: `shared_preferences: ^2.2.2` + Custom `CacheManager` with TTL + `OfflineSyncService`
- **Typography & Theme**: `google_fonts` with Arabic `Tajawal` font family, Dark pedagogical palette (`AppColors.background: 0xFF0B1120`, `AppColors.primary: 0xFF10B981` Emerald).

---

## 📂 3. Directory Structure (Feature-First Clean Architecture)

```
hafedh_mobile/
├── lib/
│   ├── core/
│   │   ├── cache/
│   │   │   ├── cache_manager.dart        # High-performance local cache with configurable TTL
│   │   │   └── offline_sync_service.dart # Offline review queue for disconnected learning
│   │   ├── di/
│   │   │   └── injection_container.dart  # Central Riverpod DI registry (overridden in main)
│   │   ├── network/
│   │   │   └── api_client.dart           # Authenticated HTTP client with timeout & error handling
│   │   ├── storage/
│   │   │   └── storage_service.dart      # Key-value persistence interface and implementation
│   │   ├── constants.dart                # AppColors, ApiBaseUrl, Storage Keys, SM-2 thresholds
│   │   └── theme/                        # Dark theme definitions and text styles
│   ├── features/
│   │   └── feed/
│   │       └── data/
│   │           └── flashcard_repository.dart # Cache-first card repository & offline sync
│   ├── models/
│   │   ├── flashcard.dart                # Multi-modality flashcard entity (QCM, Flip, Date, etc.)
│   │   ├── user.go / user.dart           # Student profile, stream, streak, metrics
│   │   └── subject.dart                  # Subject & curriculum structures
│   ├── providers/
│   │   ├── tiktok_feed_provider.dart     # Auto-disposing feed state notifier & randomizer
│   │   ├── auth_provider.dart            # Login, token storage, session state
│   │   ├── dashboard_provider.dart       # Daily goal, streak, mastery counters
│   │   └── study_provider.dart           # Classic SM-2 study session state
│   ├── views/
│   │   ├── feed/
│   │   │   └── tiktok_feed_screen.dart   # Full-screen vertical PageView feed (Home Tab 0)
│   │   ├── dashboard/
│   │   │   └── home_screen.dart          # Stats dashboard with quick Feed shortcut banner
│   │   ├── content/                      # Subjects & curriculum browser
│   │   ├── quizzes/                      # Quizzes & mock exams runner
│   │   ├── profile/                      # Settings & personal record
│   │   └── main_navigation_screen.dart   # Bottom navigation bar holding all main tabs
│   └── widgets/
│       ├── feed/
│       │   ├── feed_card_item.dart       # Master full-screen container with TikTok layout
│       │   ├── feed_side_actions.dart    # Right-side floating action buttons
│       │   ├── memorization_feedback_bar.dart # 0% / 50% / 100% feedback selector
│       │   └── card_types/               # Modular card renderers
│       │       ├── qcm_feed_card.dart    # 4-choice interactive question
│       │       ├── flip_feed_card.dart   # 3D perspective flip card
│       │       ├── date_feed_card.dart   # Historical timeline badge card
│       │       ├── personality_feed_card.dart # Historical figure card
│       │       ├── term_feed_card.dart   # Definition & concept card
│       │       └── advice_feed_card.dart # Mnemonic advice capsule
│       └── custom_button.dart, stat_box.dart, streak_badge.dart
```

---

## 🧠 4. Core Features & Interaction Logic

### A. TikTok-Style Infinite Snapping Feed (`TiktokFeedScreen`)
- Uses `PageView.builder(scrollDirection: Axis.vertical, physics: BouncingScrollPhysics())`.
- Cards are **always randomized** (`cards.shuffle()`) upon loading or changing subject filters (`🎲 عشوائي (الكل)`, `📜 التاريخ`, `🌍 الجغرافيا`).

### B. 3-Level Memorization Feedback Loop (`MemorizationFeedbackBar`)
When a student answers or reveals the answer, three feedback options appear:
1. ❌ **"لم أحفظ" (0% / Not Yet)**:
   - Submits SM-2 Rating 1 (Again).
   - **Smart Re-Insertion**: Clones and inserts the card **4 items ahead** in the current active session feed so the student encounters it again soon.
2. ⚡ **"نصف حفظ" (50% / Partially)**:
   - Submits SM-2 Rating 3 (Hard).
3. ✅ **"أتقنتُها" (100% / Mastered)**:
   - Submits SM-2 Rating 5 (Easy).
   - Triggers a celebratory emerald burst animation (`🎯 أتقنتَها! تم تثبيت البطاقة`).
   - Increments the daily mastered cards counter.
4. **Auto-Advance**:
   - 700ms after giving feedback, the feed automatically scrolls smoothly to the next card.

### C. Offline-First Caching & Synchronization
- **`CacheManager`**: Loads cards with **0ms latency** from local storage with 24-hour TTL.
- **`OfflineSyncService`**: If a student reviews cards on airplane mode, the ratings are queued locally and automatically pushed to `/api/v1/study/review` as soon as internet connectivity returns.

---

## ⚙️ 5. How to Run & Verify

```bash
# Enter mobile directory
cd hafedh_mobile

# Verify static analysis (must be 0 issues)
dart analyze lib

# Run app on connected device or emulator
flutter run
```

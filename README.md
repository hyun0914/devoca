# Devoca — 개발자 영단어 학습 앱

**🌐 배포 주소: https://devoca-fc24f.web.app**

개발자가 실무에서 자주 마주치는 영어 단어를 **철자 중심**으로 학습하는 Flutter Web PWA입니다.

## 주요 기능

### 📖 단어 카드
- 영어 단어, 한국어 발음(한글), 한국어 의미, 실제 개발 예문 제공
- 브라우저 Web Speech API 기반 TTS (Google 고품질 목소리 자동 선택)
- 목소리 직접 선택 가능

### ✏️ 철자 연습
- 한국어 발음·의미를 힌트로 보여주고 철자를 직접 입력
- 글자 입력 시 즉각적인 초록(정답) / 빨강(오답) 피드백
- 전부 맞춰야 학습 완료 처리

### 🧠 퀴즈
- 랜덤 10문제 객관식 (영단어 → 한국어 의미 4지선다)
- 오늘의 퀴즈: 당일 추천 단어 5개만 집중 출제

### ☀️ 오늘의 학습
- 매일 5개 단어 자동 추천
- 우선순위: 미학습 → 인터벌 도전 가능 → 학습 중 → 마스터
- 날짜 기반 seed로 하루 동안 동일한 5개 유지
- 철자를 완전히 맞춰야 당일 학습 완료로 표시

### 📊 학습 현황
- 미학습 / 학습 중 / 마스터 3구간으로 단어 분류
- 학습 중 단어는 다음 인터벌까지 남은 일수 표시
- ⓘ 버튼으로 마스터 기준 상세 안내 제공

## 마스터 기준 (간격 반복 학습)

단순 반복이 아닌 **날짜 간격**을 두고 기억을 검증합니다.

```
미학습   → 철자를 한 번도 맞추지 못한 단어
학습 중  → 철자를 1번 이상 맞춘 단어
마스터   → 4일 이상 간격으로 3회 정답

  Day 1   ●── 1회차 정답
  Day 5+  ●── 2회차 정답  (4일 이상 뒤)
  Day 9+  ●   3회차 정답  (4일 이상 뒤) → ⭐ 마스터
```

하루에 몰아서 맞춰도 마스터되지 않습니다.

## 단어 목록

333개 단어, 19개 카테고리 — **개념 용어 / 코딩 실무 / DB** 3가지 타입으로 분류

### 🔵 개념 용어

| 카테고리 | 단어 수 | 예시 |
|---------|:------:|------|
| Git | 10 | commit, rebase, cherry-pick, fork, conflict |
| OOP | 10 | polymorphism, encapsulation, singleton, immutable |
| Architecture | 14 | idempotent, refactor, middleware, coupling, repository |
| DevOps | 11 | deprecate, deploy, orchestration, monitoring, scaling |
| Testing | 9 | mock, stub, fixture, flaky, snapshot |
| Network | 15 | latency, payload, webhook, CDN, SSL |
| Security | 15 | authentication, XSS, brute-force, rate-limiting, firewall |
| Frontend | 15 | carousel, i18n, debounce, throttle, SSR, lazy-loading |

### 🟢 코딩 실무

| 카테고리 | 단어 수 | 예시 |
|---------|:------:|------|
| JavaScript | 24 | forEach, map, find, includes, Object.keys, flat, some, every |
| Java | 22 | ArrayList, HashMap, Arrays.sort, String.format, Integer.parseInt |
| Flutter | 22 | StatelessWidget, setState, showDialog, MediaQuery.of, StreamBuilder |
| Dart | 22 | null safety, mixin, extension, toList, contains, sort, trim, expand |
| Python | 24 | list comprehension, lambda, append, split, join, sorted, getattr |
| Kotlin | 25 | val/var, data class, coroutine, let, also, run, takeIf, groupBy |
| Naming | 21 | count, result, temp, max, min, flag, length |
| Config | 11 | yaml, toml, dockerfile, linting, prettier |

### 🟠 DB

| 카테고리 | 단어 수 | 예시 |
|---------|:------:|------|
| Database | 20 | transaction, index, schema, sharding, ORM, trigger |
| SQL | 33 | SELECT, LEFT JOIN, CASE WHEN, CTE, EXPLAIN, PRIMARY KEY |
| NoSQL | 10 | document, aggregate, TTL index, replica set, CAP theorem |

## 기술 스택

- **Flutter** (Web only) + Material 3
- **State management** — flutter_bloc (Cubit)
- **Routing** — go_router (StatefulShellRoute)
- **TTS** — flutter_tts (Web Speech API, Google 목소리 자동 선택)
- **Storage** — shared_preferences (로컬 학습 진도 저장)
- **Backend** — Firebase (Hosting 배포 완료 / Auth · Firestore 추후 적용 예정)
- **PWA** — manifest.json + service worker

## 프로젝트 구조

```
lib/
├── data/
│   ├── repositories/      # SharedPreferences 기반 저장소
│   ├── services/          # TTS 서비스 (목소리 자동 선택)
│   └── word_data.dart     # 333개 단어 + 카테고리 타입 매핑
├── domain/
│   └── models/            # WordModel, WordProgress (intervalCorrects)
├── presentation/
│   ├── cubits/            # WordCubit (타입·카테고리 필터), QuizCubit, ProgressCubit
│   ├── screens/           # 5개 화면
│   └── widgets/           # CategoryChip, MasteryIndicator
├── firebase_options.dart  # Firebase 프로젝트 설정 (자동 생성)
└── main.dart
```

## 시작하기

```bash
flutter pub get
flutter run -d chrome
```

> **요구사항** — Flutter 3.x, Dart 3.5+, Chrome 권장 (Web Speech API 지원)

## 배포 (Firebase Hosting)

```bash
# 빌드
flutter build web --release

# 배포
firebase deploy --only hosting
```

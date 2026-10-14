# Devoca — 개발자 영단어 · SQL 학습 앱

**🌐 배포 주소: https://devoca-fc24f.web.app**

개발자가 실무에서 자주 마주치는 영어 단어를 **철자 중심**으로 학습하고, 기본 SQL 쿼리를 **직접 작성해 실행**하며 연습하는 Flutter Web PWA입니다.

## 주요 기능

### 📖 단어 카드
- 영어 단어, 한국어 발음(한글), 한국어 의미, 실제 개발 예문 제공
- 브라우저 Web Speech API 기반 TTS (Google 고품질 목소리 자동 선택)
- 목소리 직접 선택 가능

### ✏️ 철자 연습
- 한국어 발음·의미를 힌트로 보여주고 철자를 직접 입력
- 🔊 발음 듣기로 실제 영어 발음을 들으며 받아쓰기 (cache / cash처럼 한글 발음만으로 헷갈리는 단어 구분)
- 코딩 실무 단어(`forEach`, `StatelessWidget` 등)는 대소문자까지 맞아야 정답
- 확인을 누른 뒤 글자별 초록(정답) / 빨강(오답) 피드백 — 입력 중에는 정답 여부를 보여주지 않음
- 전부 맞춰야 학습 완료 처리

### 🧠 퀴즈
- 랜덤 10문제 객관식 (영단어 → 한국어 의미 4지선다)
- 오늘의 퀴즈: 당일 추천 단어 5개만 집중 출제
- 뜻을 알아보는 연습이라 철자 진도(마스터)에는 반영하지 않음

### ☀️ 오늘의 학습
- 매일 5개 단어 자동 추천
- 우선순위: 미학습 → 인터벌 도전 가능 → 학습 중 → 마스터
- 3글자 이하 단어(`len`, `DNS` 등)는 다른 미학습 단어를 다 본 뒤에 추천
- 카드에는 영단어를 숨기고, 누르면 단어 카드 없이 바로 철자 연습으로 이동 (맞힌 뒤에 영단어 공개)
- 날짜 기반 seed로 하루 동안 동일한 5개 유지
- 철자를 완전히 맞춰야 당일 학습 완료로 표시

### 🗄️ SQL 연습
- 문제를 읽고 쿼리를 직접 작성해 실행 (35문제, 7개 분류)
- 브라우저 안에서 SQLite(WASM)로 실제 실행 — 서버 없이 동작
- 실행 결과 표와 함께 정답 / 결과 다름 / 실행 오류 피드백
- 힌트는 필요할 때만: 쓰이는 키워드를 첫 글자만 보여주고(`S _ _ _ _ _`), 원하면 철자 공개
- 테이블 보기, 정답 예시 보기 제공

### 📊 학습 현황
- 미학습 / 학습 중 / 마스터 3구간으로 단어 분류
- 학습 중 단어는 다음 인터벌까지 남은 일수 표시
- SQL 연습 해결 개수 표시
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

하루에 몰아서 맞춰도 마스터되지 않습니다. 철자를 틀리면 인터벌 횟수가 1회 줄어들어, 마스터한 단어도 다시 학습 중으로 돌아갑니다.

## 단어 목록

321개 단어, 19개 카테고리 — **개념 용어 / 코딩 실무 / DB** 3가지 타입으로 분류

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
| Dart | 21 | null safety, mixin, extension, toList, contains, sort, trim, expand |
| Python | 20 | list comprehension, lambda, append, except, sorted, getattr |
| Kotlin | 21 | val/var, data class, coroutine, let, also, run, takeIf, groupBy |
| Naming | 19 | result, total, temp, max, min, flag, length |
| Config | 11 | yaml, toml, dockerfile, linting, prettier |

### 🟠 DB

| 카테고리 | 단어 수 | 예시 |
|---------|:------:|------|
| Database | 20 | transaction, index, schema, sharding, ORM, trigger |
| SQL | 32 | SELECT, LEFT JOIN, CASE WHEN, OFFSET, EXPLAIN, PRIMARY KEY |
| NoSQL | 10 | document, aggregate, TTL index, replica set, CAP theorem |

## SQL 연습

`users` / `products` / `orders` 3개 테이블을 대상으로 기본 쿼리를 작성합니다.

| 분류 | 문제 수 | 다루는 내용 |
|------|:------:|------------|
| SELECT 기본 | 3 | `*`, 컬럼 지정, `DISTINCT` |
| WHERE 조건 | 7 | 비교, `AND`, `OR` / `IN`, `BETWEEN`, `LIKE`, `IS NULL` |
| 정렬과 개수 제한 | 4 | `ORDER BY`, `LIMIT`, 다중 정렬 |
| 집계 함수 | 5 | `COUNT`, `MAX`, `SUM`, `AVG` |
| GROUP BY | 4 | 그룹별 개수·합계, `HAVING` |
| JOIN | 6 | 2~3개 테이블 연결, `LEFT JOIN`, JOIN + 집계 |
| 데이터 변경 | 6 | `INSERT`, `UPDATE`, `DELETE` |

### 채점 방식

쿼리 문자열이 아니라 **실행 결과**를 비교합니다. 사용자 쿼리와 정답 쿼리를 각각 새 DB에서 실행하므로, 표현이 달라도 결과가 같으면 정답입니다.

- 조회 문제 — 결과 값을 비교. 컬럼 이름(별칭)은 보지 않고, `ORDER BY` 문제만 행 순서까지 확인
- 변경 문제 — 실행 후 테이블 상태를 비교
- 컬럼 순서는 문제에 적힌 순서와 같아야 함
- 오답이면 컬럼 수 / 행 수 / 값 / 정렬 중 무엇이 다른지 안내

## 기술 스택

- **Flutter** (Web only) + Material 3
- **State management** — flutter_bloc (Cubit)
- **Routing** — go_router (StatefulShellRoute)
- **TTS** — flutter_tts (Web Speech API, Google 목소리 자동 선택)
- **SQL 엔진** — sqlite3 (WASM, 브라우저 인메모리 DB)
- **Storage** — shared_preferences (로컬 학습 진도 저장)
- **Backend** — Firebase (Hosting 배포 완료 / Auth · Firestore 추후 적용 예정)
- **PWA** — manifest.json + service worker

## 프로젝트 구조

```
lib/
├── data/
│   ├── repositories/         # SharedPreferences 기반 저장소
│   ├── services/             # TTS 서비스, SQL 엔진 · 채점 서비스
│   ├── sql_problem_data.dart # SQL 스키마 · 샘플 데이터 · 35문제
│   └── word_data.dart        # 321개 단어 + 카테고리 타입 매핑
├── domain/
│   └── models/               # WordModel, WordProgress, SqlProblem, SqlResult
├── presentation/
│   ├── cubits/               # WordCubit, QuizCubit, ProgressCubit, SqlPracticeCubit
│   ├── screens/              # 7개 화면
│   └── widgets/              # CategoryChip, MasteryIndicator, SqlResultTable
├── firebase_options.dart     # Firebase 프로젝트 설정 (자동 생성)
└── main.dart
web/
└── sqlite3.wasm              # SQLite WASM 바이너리
```

> `web/sqlite3.wasm`은 `pubspec.lock`의 `sqlite3` 패키지 버전과 같은 [릴리스](https://github.com/simolus3/sqlite3.dart/releases) 파일이어야 합니다. 패키지 버전을 올리면 이 파일도 함께 교체하세요.

## 시작하기

```bash
flutter pub get
flutter run -d chrome

# 테스트 (SQL 채점은 실제 SQLite로 검증)
flutter test
```

> **요구사항** — Flutter 3.x, Dart 3.5+, Chrome 권장 (Web Speech API 지원)

## 배포 (Firebase Hosting)

```bash
# 빌드
flutter build web --release

# 배포
firebase deploy --only hosting
```

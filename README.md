# Todo App

Firebase + Riverpod 기반 Flutter Todo 앱

---

## 스크린샷

| List Screen | Draft 복원 다이얼로그 |
|:-----------:|:--------------------:|
| ![List Screen](assets/screenshots/list_screen.png) | ![Draft Dialog](assets/screenshots/draft_dialog.png) |

---

## 구동 방법

**요구사항**
- Dart SDK `^3.11.1` / Flutter 3.29.0 이상
- Firebase 설정 파일 포함 (`google-services.json` / `GoogleService-Info.plist`)
- 지원 플랫폼: iOS (기본), Android 선택 가능

```bash
# 1. 의존성 설치
flutter pub get

# 2. 앱 실행
flutter run
```

---

## 구현 기능

### 필수

| 기능 | 구현 여부 |
|------|-----------|
| 사용자 정보 등록 (이름, 프로필 사진) | ✅ |
| Todo List (삭제, 필터, 검색) | ✅ |
| Todo 상세 (삭제, 수정) | ✅ |
| Todo 추가 (임시저장, 복원 다이얼로그) | ✅ |
| Todo 모델 (id, 제목, 이미지, 태그, created_at, updated_at) | ✅ |
| 태그 직접 생성·부여·중복 없이 다중 선택 | ✅ |

### 선택

| 기능 | 구현 여부 |
|------|-----------|
| Todo 태그 필터 | ✅ |
| 다크 모드 | ✅ |
| 애니메이션 (flutter_animate) | ✅ |

---

## 기술 스택

| 분류 | 사용 기술 |
|------|----------|
| 언어 / 프레임워크 | Dart / Flutter |
| 상태관리 | flutter_riverpod ^3.3.1 |
| 원격 저장 | Firebase Firestore · Auth · Storage |
| 로컬 저장 | Hive (Draft 임시저장 전용) |
| UI | velocity_x · flutter_animate · dotted_border |
| 이미지 | image_picker |

---

## 아키텍처 및 디렉토리 구조

Feature-First + Clean Architecture (Domain / Data / Presentation)

```
lib/
├── main.dart / app.dart          # 진입점 + 라우팅
├── core/                         # 공통 위젯·서비스·테마·Provider
│   ├── providers/theme_provider.dart
│   ├── services/                 # AppSnackBar, DebounceService, TagDialogService, TimeService
│   ├── theme/                    # light_mode.dart, dark_mode.dart
│   └── widgets/                  # AppButton, AppTextField, AppHeader
└── features/
    ├── auth/                     # Firebase 이메일 인증
    ├── user/                     # 프로필 (Firestore + Storage)
    └── todo/                     # Todo + Tag CRUD (Firestore + Hive draft)
```

**라우팅 로직 (`app.dart`)**

```
authStateProvider (StreamProvider<String?>)
  ├─ null → LoginScreen
  └─ uid  → userProvider (AsyncNotifierProvider<User?>)
              ├─ null → ProfileSetupScreen
              └─ User → ListScreen
```

---

## 상태관리 고민

### Provider 선택 기준

| 상황 | 사용 Provider |
|------|--------------|
| Firebase Auth 스트림 | `StreamProvider` |
| User / Todo / Tag (비동기 CRUD) | `AsyncNotifierProvider` |
| 테마 모드 (동기 전역 상태) | `NotifierProvider` |
| 화면 내 로컬 UI 상태 | 파일 내부 `NotifierProvider` (private) |

### setState 최소화

- `setState`는 `AppTextField`의 비밀번호 토글(순수 UI)에만 사용
- 로딩, 이미지 선택, 태그 선택 등 모든 비즈니스 로직은 Riverpod Notifier로 관리

### 필요한 위젯만 재빌드

- `ref.watch`를 가능한 트리 깊숙한 곳에 배치
  - `ListScreen._buildTasks()` 안에서만 `todoListProvider` watch → 리스트 영역만 재빌드
  - `ListScreen._buildUserProfile()` 안 Builder에서 `themeModeProvider` watch → 아이콘만 재빌드
- `TextEditingController` 또는 로컬 UI 상태가 필요한 화면만 `ConsumerStatefulWidget`, 그 외는 `ConsumerWidget`
- 로컬 Provider를 파일 내부에 private으로 정의하여 다른 화면의 재빌드에 영향 없도록 격리

---

## 고민했던 점

### 임시저장(Draft) 설계

앱이 종료된 후에도 입력 내용이 유지되어야 하므로 Hive(로컬 저장소)를 선택했다. 주 데이터(Todo)는 Firestore, Draft만 Hive로 저장소를 분리했다.

- `AddTodoScreen`에서 제목·사진 경로·태그 ID를 `DebounceService`(1500ms)로 자동 저장
- 화면 진입 시 draft 감지 → 다이얼로그로 "계속하기 / 새로 만들기" 선택

### 인증 → 유저 → Todo 의존성 체인

```
authStateProvider(Stream) → userProvider(Async) → todoListProvider(Async)
```

각 Provider가 상위 Provider를 `ref.watch`로 의존하도록 구성했다. 로그아웃 시 `authStateProvider`가 `null`을 방출하면 하위 체인 전체가 자동으로 초기화된다.

### 공통 컴포넌트 재사용

`AppButton`, `AppTextField`, `AppHeader`, `AppSnackBar`를 `core/`에 정의하고 전 화면에서 재사용했다. 버튼·입력 필드를 직접 사용하지 않아 디자인 일관성을 확보했고, 공통 동작(로딩 상태, 에러 표시 등)을 한 곳에서 관리할 수 있었다.

### 태그 설계

Tag를 별도 컬렉션(`tags`)으로 분리하고 Todo에는 `tagIds: List<String>`만 저장했다. 태그 색상은 `Color.toARGB32()` 정수로 Firestore에 저장하고, 읽을 때 `Color(int)`로 복원한다.

---

## 검증 시나리오

1. `flutter pub get` → `flutter run`
2. 회원가입 → 프로필 등록 → 리스트 화면 진입
3. Todo 추가 (이미지, 태그 포함) → 임시저장 후 재진입 시 복원 다이얼로그 확인
4. 검색 / 태그 필터 / 완료 필터 동작 확인
5. 다크모드 토글 확인
6. 프로필 사진 탭 → 이름·사진 수정 → 로그아웃

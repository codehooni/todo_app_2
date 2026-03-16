# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run              # Run the app
flutter clean            # Clean build artifacts
flutter build apk        # Build Android APK
flutter build ios        # Build iOS (requires macOS + Xcode)
```

## Architecture

This is an early-stage Flutter todo app. Currently only the default counter demo exists in `lib/main.dart`, but the project is set up for **Riverpod** state management (`flutter_riverpod: ^3.3.1` is already in `pubspec.yaml`).

**State management via `flutter_riverpod`** — use `ProviderScope` at the root. Provider selection:

|                | Synchronous       | Future                | Stream                |
|----------------|-------------------|-----------------------|-----------------------|
| Unmodifiable   | `Provider`        | `FutureProvider`      | `StreamProvider`      |
| Modifiable     | `NotifierProvider`| `AsyncNotifierProvider` | `StreamNotifierProvider` |

**Rules:**
- UI widgets extend `ConsumerWidget`; use `ref.watch` as deep in the tree as possible so only the necessary subtree rebuilds
- `setState` is **forbidden** — the only exception is `AnimationController` management
- `lib/` follows a feature-first structure:
  ```
  lib/
  ├── features/
  │   └── todo/
  │       ├── domain/      # Models / entities
  │       ├── data/        # Repositories
  │       └── presentation/# UI widgets + Riverpod providers
  └── core/                # Shared components and theme
  ```

## Core Widgets & Services

`lib/core/`에 공통 컴포넌트가 정의되어 있다. **새로 만들기 전에 반드시 먼저 사용할 것.**

| 경로 | 컴포넌트 | 용도 |
|------|----------|------|
| `lib/core/widgets/app_button.dart` | `AppButton` | 기본 버튼 (로딩 상태 포함) |
| `lib/core/widgets/app_text_field.dart` | `AppTextField` | 텍스트 입력 필드 (라벨·비밀번호 토글 포함) |
| `lib/core/widgets/app_header.dart` | `AppHeader` | 화면/카드 상단 타이틀 + 서브타이틀 |
| `lib/core/services/app_snack_bar.dart` | `AppSnackBar` | 일반/에러 스낵바 표시 |
| `lib/core/providers/theme_provider.dart` | `themeModeProvider` | 테마 모드 상태 관리 |

**Rules:**
- 버튼이 필요하면 `AppButton` 사용 — `ElevatedButton`, `FilledButton` 직접 사용 금지
- 텍스트 필드가 필요하면 `AppTextField` 사용 — `TextField`, `TextFormField` 직접 사용 금지
  - 필드 위에 라벨이 필요하면 `label:` 파라미터 사용 — 라벨 텍스트를 별도 위젯으로 만들지 말 것
- 화면/카드 상단 타이틀+서브타이틀은 `AppHeader` 사용
  - `alignment`: `CrossAxisAlignment.center`(기본) / `CrossAxisAlignment.start`(좌측 정렬)
  - `titleStyle` / `subtitleStyle`: 기본 스타일 위에 `TextStyle`로 덮어쓰기 가능
- 스낵바 표시는 `AppSnackBar.show()` / `AppSnackBar.showError()` 사용
- 테마 변경은 `themeModeProvider`를 통해서만 처리

**Performance:**
- 리스트 렌더링 시 `ListView.builder`를 사용하여 메모리 효율을 최적화한다
- 이미지 렌더링 시 `CachedNetworkImage` 또는 효율적인 Asset 관리를 적용한다

## UI (velocity_x)

모든 화면은 `velocity_x: ^4.3.1` 를 사용하여 작성한다.

**레이아웃:**
```dart
VStack([...])                          // Column
HStack([...])                          // Row
ZStack([...])                          // Stack
VStack([...], alignment: MainAxisAlignment.center, axisSize: MainAxisSize.max)
```

**간격:**
```dart
16.heightBox   // SizedBox(height: 16)
12.widthBox    // SizedBox(width: 12)
```

**텍스트:**
```dart
'Hello'.text.make()                    // Text('Hello')
'Hello'.text.xl2.bold.make()           // 굵은 큰 텍스트
'Hello'.text.color(Colors.grey).make() // 색상
```

**패딩/컨테이너:**
```dart
widget.p24()          // Padding(all: 24)
widget.px16()         // Padding(horizontal: 16)
widget.py8()          // Padding(vertical: 8)
widget.centered()     // Center(child: widget)
widget.wFull(context) // SizedBox(width: screenWidth, child: widget)
widget.box.roundedFull.color(color).make()  // 원형 컨테이너
```

**텍스트 크기 (작은 순):** `xs` → `sm` → `base` → `lg` → `xl` → `xl2` → `xl3` → `xl4` → `xl5` → `xl6`

## Key Dependencies

- `flutter_riverpod` — state management
- `velocity_x` — UI utility extensions (레이아웃, 텍스트, 패딩 등)
- `cupertino_icons` — iOS-style icons
- `flutter_lints` — lint rules (flutter recommended set, no custom overrides)

## Flutter/Dart Version

- Dart SDK: `^3.11.1`
- Flutter stable channel (revision `ff37bef`)

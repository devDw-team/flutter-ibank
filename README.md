# IBank 그룹웨어

Flutter와 Supabase를 사용한 모바일 그룹웨어 애플리케이션입니다.

## 주요 기능

- 📊 **대시보드**: 실시간 업무 현황 및 통계
- ⏰ **출퇴근 관리**: GPS/NFC 기반 출퇴근 체크
- ✅ **할 일 관리**: 개인 및 팀 작업 관리
- 📅 **일정 관리**: 개인 일정 및 팀 캘린더
- 📁 **프로젝트 관리**: 프로젝트 진행 상황 추적

## 기술 스택

- **Frontend**: Flutter 3.0+, Dart 3.0+
- **Backend**: Supabase (PostgreSQL, Realtime, Auth, Storage)
- **상태관리**: Riverpod 2.0
- **UI**: Material Design 3
- **로컬 저장소**: Hive

## 시작하기

### 사전 요구사항

- Flutter 3.0 이상
- Dart 3.0 이상
- Supabase 계정 및 프로젝트

### 설치

1. 저장소 클론
```bash
git clone https://github.com/yourusername/flutter-ibank.git
cd flutter-ibank
```

2. 환경 변수 설정
```bash
cp .env.example .env
```

`.env` 파일을 열어 Supabase 설정을 입력합니다:
```
SUPABASE_URL=https://uyqjrgmeunxumvwntyljr.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

> **중요**: Supabase 대시보드에서 프로젝트의 anon key를 복사하여 `SUPABASE_ANON_KEY`를 업데이트해주세요.

3. 의존성 설치
```bash
flutter pub get
```

4. 코드 생성 (freezed, json_serializable)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. 앱 실행
```bash
# 개발 모드
flutter run --dart-define-from-file=.env

# 프로덕션 빌드
flutter build apk --release --dart-define-from-file=.env
flutter build ios --release --dart-define-from-file=.env
```

## 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점
├── app.dart               # 앱 위젯
├── env/                   # 환경 변수
├── core/                  # 핵심 기능
│   ├── constants/         # 상수 정의
│   ├── router/           # 라우팅 설정
│   ├── theme/            # 테마 설정
│   └── utils/            # 유틸리티 함수
├── features/             # 기능별 모듈
│   ├── auth/             # 인증
│   ├── dashboard/        # 대시보드
│   ├── attendance/       # 출퇴근 관리
│   ├── tasks/           # 할 일 관리
│   ├── calendar/        # 일정 관리
│   └── projects/        # 프로젝트 관리
├── shared/              # 공통 컴포넌트
│   ├── widgets/         # 공통 위젯
│   └── providers/       # 공통 프로바이더
└── services/            # 외부 서비스 연동
```

## Supabase 설정

### 데이터베이스 테이블

프로젝트를 시작하기 전에 Supabase에서 다음 테이블들을 생성해야 합니다:

1. **users** - 사용자 정보
2. **attendance** - 출퇴근 기록
3. **tasks** - 할 일 목록
4. **events** - 일정 정보
5. **projects** - 프로젝트 정보

### 데이터베이스 마이그레이션

`supabase/migrations/001_initial_schema.sql` 파일에 있는 SQL을 Supabase SQL Editor에서 실행하여 필요한 테이블과 RLS 정책을 설정합니다.

1. [Supabase Dashboard](https://app.supabase.com)에 로그인
2. 프로젝트 선택
3. SQL Editor로 이동
4. `supabase/migrations/001_initial_schema.sql` 내용을 복사하여 실행

### Row Level Security (RLS)

모든 테이블에 적절한 RLS 정책이 자동으로 설정됩니다:
- 사용자는 자신의 데이터만 조회/수정 가능
- 프로젝트는 멤버인 경우에만 조회 가능
- 공지사항은 모든 사용자가 조회 가능

### Deep Links 설정 (iOS/Android)

#### Android 설정
`android/app/src/main/AndroidManifest.xml` 파일에 다음을 추가:

```xml
<activity android:name=".MainActivity" ...>
  <!-- Deep Links -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
      android:scheme="io.supabase.flutterquickstart"
      android:host="login-callback" />
  </intent-filter>
</activity>
```

#### iOS 설정
`ios/Runner/Info.plist` 파일에 다음을 추가:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.flutterquickstart</string>
    </array>
  </dict>
</array>
```

### Supabase 대시보드에서 Redirect URL 추가
1. [Authentication > URL Configuration](https://app.supabase.com/project/_/auth/url-configuration)으로 이동
2. Redirect URLs에 `io.supabase.flutterquickstart://login-callback/` 추가

## 개발 가이드

### 코드 스타일

- Dart 공식 스타일 가이드를 따릅니다
- 모든 public API에는 문서화 주석을 작성합니다
- 의미있는 변수명과 함수명을 사용합니다

### 커밋 메시지

```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 코드 리팩토링
test: 테스트 추가
chore: 빌드 업무 수정
```

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

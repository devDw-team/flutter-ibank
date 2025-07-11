# Supabase 설정 가이드

이 문서는 IBank 그룹웨어 프로젝트를 위한 Supabase 설정 방법을 안내합니다.

## 1. Supabase 프로젝트 생성

1. [Supabase](https://app.supabase.com)에 로그인합니다.
2. "New Project" 버튼을 클릭합니다.
3. 프로젝트 정보를 입력합니다:
   - Project name: `ibank-groupware`
   - Database Password: 강력한 비밀번호 설정
   - Region: 가장 가까운 지역 선택 (예: Northeast Asia)

## 2. 프로젝트 자격 증명 가져오기

프로젝트가 생성되면:

1. Settings > API로 이동합니다.
2. 다음 정보를 복사합니다:
   - **Project URL**: `https://uyqjrgmeunxumvwntyljr.supabase.co` (예시)
   - **anon public key**: 긴 문자열 형태의 키

## 3. 환경 변수 설정

프로젝트 루트의 `.env` 파일을 열고 다음과 같이 업데이트합니다:

```
SUPABASE_URL=https://uyqjrgmeunxumvwntyljr.supabase.co
SUPABASE_ANON_KEY=여기에_복사한_anon_key를_붙여넣으세요
```

## 4. 데이터베이스 테이블 생성

1. Supabase Dashboard에서 SQL Editor로 이동합니다.
2. `supabase/migrations/001_initial_schema.sql` 파일의 내용을 복사합니다.
3. SQL Editor에 붙여넣고 "Run" 버튼을 클릭합니다.

이 SQL 스크립트는 다음을 생성합니다:
- 필요한 모든 테이블 (users, tasks, events, projects 등)
- Row Level Security (RLS) 정책
- 트리거 및 함수

## 5. Authentication 설정

### Email Authentication 활성화

1. Authentication > Providers로 이동합니다.
2. Email을 활성화합니다.
3. 다음 설정을 확인합니다:
   - Enable Email Signup: ON
   - Enable Email Confirmations: ON (권장)

### Deep Link 설정

1. Authentication > URL Configuration으로 이동합니다.
2. Redirect URLs에 다음을 추가합니다:
   ```
   io.supabase.flutterquickstart://login-callback/
   ```

## 6. Storage 설정 (선택사항)

프로필 이미지 등을 저장하려면:

1. Storage로 이동합니다.
2. "New bucket" 클릭합니다.
3. Bucket 이름: `avatars`
4. Public bucket: ON (프로필 이미지용)

## 7. 테스트 계정 생성

1. Authentication > Users로 이동합니다.
2. "Add user" > "Create new user" 클릭합니다.
3. 테스트용 이메일과 비밀번호를 입력합니다.

## 8. 로컬 개발 시작

모든 설정이 완료되면:

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (freezed, json_serializable)
./scripts/build_runner.sh

# 앱 실행
./scripts/run_dev.sh
```

## 트러블슈팅

### 연결 오류

- `.env` 파일의 URL과 키가 정확한지 확인합니다.
- 프로젝트가 활성 상태인지 확인합니다.

### RLS 정책 오류

- SQL Editor에서 RLS 정책이 제대로 생성되었는지 확인합니다.
- Authentication > Policies에서 정책을 확인할 수 있습니다.

### 인증 오류

- anon key가 올바른지 확인합니다.
- Deep link가 제대로 설정되었는지 확인합니다.

## 추가 리소스

- [Supabase Flutter 문서](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Supabase RLS 가이드](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Storage 가이드](https://supabase.com/docs/guides/storage) 
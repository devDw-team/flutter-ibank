# Supabase SQL 수동 실행 가이드

MCP 연결 문제가 있을 때 다음 방법으로 직접 SQL을 실행할 수 있습니다.

## 단계별 진행 방법

### 1. Supabase 대시보드 접속
1. [Supabase Dashboard](https://app.supabase.com)에 로그인
2. 프로젝트 선택 (URL: `https://yqjrgmeunxumvwntyljr.supabase.co`)

### 2. SQL Editor로 이동
1. 왼쪽 메뉴에서 "SQL Editor" 클릭
2. 새 쿼리 탭 열기

### 3. SQL 실행
1. `supabase/migrations/001_initial_schema.sql` 파일의 전체 내용을 복사
2. SQL Editor에 붙여넣기
3. "Run" 버튼 클릭

### 4. 실행 확인
성공적으로 실행되면 다음이 생성됩니다:
- ✅ 테이블: users, attendance, tasks, events, projects, project_members, announcements
- ✅ RLS 정책
- ✅ 트리거 및 함수

### 5. 테이블 확인
1. "Table Editor"로 이동
2. 생성된 테이블들이 보이는지 확인

## 트러블슈팅

### 에러: "relation "auth.users" does not exist"
- Authentication이 활성화되어 있는지 확인
- Authentication > Settings에서 Email 인증이 켜져 있는지 확인

### 에러: "extension "uuid-ossp" does not exist"
- 대부분의 Supabase 프로젝트에는 이미 설치되어 있음
- 에러가 발생하면 해당 줄을 건너뛰고 진행

## 실행 후 확인사항
1. Table Editor에서 모든 테이블이 생성되었는지 확인
2. Authentication > Policies에서 RLS 정책이 생성되었는지 확인
3. Database > Functions에서 트리거가 생성되었는지 확인 
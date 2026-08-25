# ibm-salmon
## 📁 Project Structure

```text
salmon/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   └── v1/
│   │   │       ├── endpoints/
│   │   │       │   ├── analyze.py      # 스크린샷 이미지 OCR 및 LLM 분석 API
│   │   │       │   ├── calendar.py     # 추출된 일정 CRUD API
│   │   │       │   ├── history.py      # 분석 히스토리 조회 및 상세 API
│   │   │       │   └── devices.py      # FCM 디바이스 토큰 등록 API
│   │   │       └── api.py              # v1 라우터 통합
│   │   ├── core/
│   │   │   ├── config.py               # 환경 변수 및 설정 (DB URL, API Keys)
│   │   │   └── database.py             # 데이터베이스 세션 및 엔진 설정
│   │   ├── models/                     # DB ORM 모델 정의
│   │   ├── schemas/                    # Pydantic 요청/응답 스키마
│   │   ├── services/                   # 비즈니스 로직 및 외부 AI/FCM 연동 서비스
│   │   └── main.py                     # FastAPI 애플리케이션 진입점
│   ├── requirements.txt                # 백엔드 의존성 패키지 목록
│   ├── .env.example                    # 환경 변수 템플릿
│   └── Dockerfile                      # 백엔드 컨테이너 빌드 설정
│
└── frontend/
    ├── android/                        # Android 네이티브 설정 및 Gradle
    ├── ios/                            # iOS 네이티브 설정
    ├── lib/
    │   ├── constants/                  # 전역 상수 관리
    │   │   └── appconstants.dart       # API Base URL 및 공통 설정
    │   │
    │   ├── screens/                    # UI 화면 컴포넌트
    │   │   ├── nevigate.dart           # 하단 네비게이션 바 및 탭 컨트롤러
    │   │   ├── upload.dart             # 스크린샷 이미지 업로드 및 분석 요청
    │   │   ├── calender.dart           # 일정 캘린더 뷰 (TableCalendar 연동)
    │   │   ├── category.dart           # 키워드/카테고리별(맛집/공모전/장학금 등) 필터 뷰
    │   │   ├── history.dart            # 전체 분석 기록 리스트
    │   │   └── detail.dart             # 분석 결과 상세 보기 (네이버 지도, 링크 연동)
    │   │
    │   ├── services/                   # 외부 서비스 및 통신 모듈
    │   │   └── fcm.dart                # FCM 디바이스 토큰 관리 및 푸시 핸들러
    │   │
    │   └── main.dart                   # 앱 시작점 및 Firebase 초기화
    │
    ├── analysis_options.yaml           # Dart 정적 분석 규칙
    ├── pubspec.yaml                    # 패키지 의존성 및 에셋 관리 파일
    └── pubspec.lock                    # 패키지 버전 고정 파일

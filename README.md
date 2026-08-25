# ibm-salmon
## 📁 Project Structure

```text
salmon/
├── backend/
│   ├── calender.py           # 캘린더 일정 관리 및 조회 API
│   ├── history.py            # 분석 기록(히스토리) 조회 및 관리 API
│   ├── main.py               # FastAPI 서버 진입점 및 이미지 분석(OCR/LLM) API
│   ├── map.py                # 장소 및 지도 검색/매핑 관련 로직
│   ├── scheduler.py          # 일정 자동 알림 및 백그라운드 스케줄러
│   ├── serviceAccountKey.json # Firebase Admin SDK 인증 키
│   └── .env                  # 환경 변수 설정 (DB URL, API 키 등)
│
└── frontend/
    └── lib/
        ├── constants/
        │   └── constants.dart # API Base URL 및 공통 설정값
        │
        ├── screens/
        │   ├── calender.dart  # 일정 캘린더 뷰 (TableCalendar 연동)
        │   ├── category.dart  # 카테고리(맛집/공모전/장학금 등) 및 키워드 필터 뷰
        │   ├── detail.dart    # 분석 결과 상세 보기 (네이버 지도, 웹 링크 연동)
        │   ├── history.dart   # 전체 분석 기록 리스트
        │   ├── nevigate.dart  # 하단 네비게이션 바 및 탭 전환 관리
        │   └── upload.dart    # 스크린샷 이미지 업로드 및 분석 요청
        │
        ├── services/
        │   └── fcm.dart       # FCM 디바이스 토큰 등록 및 푸시 알림 핸들러
        │
        └── main.dart          # Flutter 앱 시작점 및 Firebase 초기화

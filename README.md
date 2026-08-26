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
        │   ├── chat.dart      # Watsonx 기반 스크린샷 분석 챗봇
        │   ├── detail.dart    # 분석 결과 상세 보기 (네이버 지도, 웹 링크 연동)
        │   ├── history.dart   # 전체 분석 기록 리스트
        │   ├── nevigate.dart  # 하단 네비게이션 바 및 탭 전환 관리
        │   └── upload.dart    # 스크린샷 이미지 업로드 및 분석 요청
        │
        ├── services/
        │   └── fcm.dart       # FCM 디바이스 토큰 등록 및 푸시 알림 핸들러
        │
        └── main.dart          # Flutter 앱 시작점 및 Firebase 초기화
```

## Watsonx Chatbot

백엔드에 `POST /api/v1/chat` 엔드포인트가 추가되어 저장된 스크린샷 분석 히스토리를 바탕으로 Watsonx Granite 모델이 답변합니다.

필요 환경 변수:

```env
WATSONX_API_KEY=your_ibm_cloud_api_key
WATSONX_PROJECT_ID=your_watsonx_project_id
WATSONX_URL=https://us-south.ml.cloud.ibm.com
WATSONX_CHAT_MODEL_ID=ibm/granite-3-8b-instruct
```

`WATSONX_CHAT_MODEL_ID`는 계정에서 사용 가능한 Granite 또는 Llama 계열 chat 모델 ID로 바꿀 수 있습니다.

챗봇 UI만 빠르게 확인하려면 백엔드를 켠 뒤 브라우저에서 아래 주소를 엽니다.

```text
http://127.0.0.1:8000/chatbot-preview
```

응답 라벨이 `Watsonx 응답`이면 모델 호출까지 성공한 상태이고, `로컬 보조 응답`이면 UI와 API는 정상이나 Watsonx 인증/권한을 확인해야 하는 상태입니다.

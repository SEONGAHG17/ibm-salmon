# Watson 챗봇 실행/테스트/전달 가이드

## 1. 백엔드 실행

루트 폴더 기준:

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

필요 환경 변수는 `backend/.env`에 넣는다. API 키는 단톡방이나 공개 저장소에 직접 올리지 않는다.

```env
WATSONX_API_KEY=...
WATSONX_PROJECT_ID=...
WATSONX_URL=https://us-south.ml.cloud.ibm.com
WATSONX_CHAT_MODEL_ID=ibm/granite-3-8b-instruct
```

## 2. 챗봇 API만 먼저 테스트

백엔드가 켜진 상태에서 새 터미널:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"최근 저장한 스크린샷 항목 요약해줘","user_id":"default_user"}'
```

응답에서 `"provider":"watsonx"`가 나오면 Watsonx 모델 호출까지 성공한 것이다.

`"provider":"local_fallback"`가 나오면 백엔드는 살아 있지만 Watsonx 키, 프로젝트 ID, 모델 ID 중 하나가 맞지 않는 상태다. 이 경우에도 데모용 기본 답변은 나온다.

## 3. Flutter 앱 실행

Android 에뮬레이터 기준으로 `frontend/lib/constants/constants.dart`가 이미 `http://10.0.2.2:8000`을 바라본다.

```bash
cd frontend
flutter pub get
flutter run
```

실제 핸드폰으로 테스트하면 `10.0.2.2`가 동작하지 않는다. 그때는 `frontend/lib/constants/constants.dart`의 `baseUrl`을 백엔드를 실행 중인 노트북의 같은 와이파이 IP로 바꾼다.

예:

```dart
const String baseUrl = "http://192.168.0.12:8000";
```

## 4. 앱에서 확인할 흐름

1. 백엔드를 먼저 켠다.
2. 앱을 실행한다.
3. 업로드 탭에서 스크린샷을 선택해 분석한다.
4. 분석 결과 아래 `Watson 챗봇에게 질문하기` 버튼을 누른다.
5. 또는 하단 `챗봇` 탭에서 직접 질문한다.
6. 추천 질문: `일정등록 항목만 알려줘`, `지도에서 볼 항목 정리해줘`, `장학금 관련 정보 있어?`

## 5. 조원에게 안전하게 전달하는 방법

가장 안전한 방법은 `main`에 바로 덮어쓰지 않고 브랜치와 PR로 전달하는 것이다.

```bash
git checkout -b feat/watson-chatbot
git add README.md WATSON_CHATBOT_HANDOFF.md backend/main.py backend/requirements.txt frontend/lib/screens/chat.dart frontend/lib/screens/nevigate.dart frontend/lib/screens/upload.dart
git commit -m "Add Watsonx screenshot chatbot"
git push origin feat/watson-chatbot
```

그 다음 GitHub에서 `feat/watson-chatbot` 브랜치로 Pull Request를 만든다.

조원이 이미 코드를 더 추가했다면 조원에게 먼저 자기 작업을 push하라고 하고, 그 다음 PR 화면에서 충돌 여부를 확인한다. 충돌이 나면 주로 아래 파일에서 날 가능성이 높다.

```text
backend/main.py
frontend/lib/screens/nevigate.dart
frontend/lib/screens/upload.dart
```

충돌이 걱정되면 zip으로 통째로 보내지 말고 PR 링크를 보내는 것이 가장 안전하다.

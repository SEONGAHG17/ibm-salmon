# Watson 챗봇 실행/테스트/전달 가이드

## 0. 현재 화면 판별법

브라우저 미리보기에서 챗봇 UI가 뜨고 터미널에 `POST /api/v1/chat HTTP/1.1" 200 OK`가 보이면 UI와 백엔드 API 연결은 성공이다.

답변 아래 또는 응답 JSON의 `provider` 값으로 Watsonx 연결 상태를 판단한다.

```text
provider: watsonx
```

Watsonx 모델 호출까지 성공한 상태다.

```text
provider: local_fallback
```

챗봇 UI와 백엔드는 정상 작동하지만 Watsonx 호출만 실패한 상태다. 터미널에 `Provided API key could not be found`가 보이면 `WATSONX_API_KEY`가 잘못됐거나 IBM Cloud에서 삭제된 키다. 새 IBM Cloud IAM API key를 발급해 `backend/.env`에 다시 넣는다.

```text
provider: error
```

브라우저가 백엔드 서버에 닿지 못한 상태다. 서버가 켜져 있는지, 포트가 `8000`인지 확인한다.

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
WATSONX_CHAT_MODEL_ID=ibm/granite-4-h-small
```

`WATSONX_API_KEY`는 watsonx 화면의 프로젝트 ID가 아니라 IBM Cloud IAM API key다. IBM Cloud 콘솔에서 `Manage > Access (IAM) > API keys`로 새로 만든다.

`WATSONX_PROJECT_ID`는 watsonx.ai 프로젝트의 `Manage > General > Details`에서 복사한다.

프로젝트 리전이 Dallas가 아니면 `WATSONX_URL`을 프로젝트 리전에 맞게 바꾼다.

```text
Dallas: https://us-south.ml.cloud.ibm.com
Frankfurt: https://eu-de.ml.cloud.ibm.com
London: https://eu-gb.ml.cloud.ibm.com
Tokyo: https://jp-tok.ml.cloud.ibm.com
Sydney: https://au-syd.ml.cloud.ibm.com
Toronto: https://ca-tor.ml.cloud.ibm.com
Mumbai: https://ap-south-1.aws.wxai.ibm.com
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

## 2-1. 챗봇 UI만 빠르게 보기

Android 에뮬레이터나 실제 기기 없이 챗봇 화면만 보고 싶으면 백엔드를 켠 뒤 브라우저에서 아래 주소를 연다.

```text
http://127.0.0.1:8000/chatbot-preview
```

이 화면은 Flutter 앱의 챗봇 탭과 같은 질문 흐름으로 `POST /api/v1/chat`을 호출한다. 기존 업로드, 캘린더, Firebase 기능을 확인하지 않고 챗봇 UI와 Watsonx 응답만 빠르게 볼 때 사용한다.

미리보기에서 확인할 기능:

```text
연결 상태 배너
추천 질문 버튼
답변 복사
대화 초기화
Watsonx/Fallback 라벨
근거 스크린샷 칩
```

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

## 6. 메인 개발자 연결 체크리스트

메인 개발자는 아래 순서로 붙이면 된다.

```text
1. 이 브랜치를 pull 또는 PR merge
2. backend/.env.example을 참고해 backend/.env를 로컬에 생성
3. WATSONX_API_KEY, WATSONX_PROJECT_ID, WATSONX_URL 설정
4. 백엔드 실행
5. http://127.0.0.1:8000/chatbot-preview에서 provider가 watsonx인지 확인
6. Flutter 앱에서 하단 챗봇 탭 확인
7. 실제 기기 테스트 시 frontend/lib/constants/constants.dart의 baseUrl을 노트북 IP로 변경
```

주요 연결 파일:

```text
backend/main.py
  POST /api/v1/chat
  GET /api/v1/chat/status
  GET /chatbot-preview

frontend/lib/screens/chat.dart
  Flutter 앱 챗봇 탭 UI

frontend/lib/screens/nevigate.dart
  하단 탭에 챗봇 추가

frontend/lib/screens/upload.dart
  분석 결과에서 챗봇으로 이동 버튼

frontend/chatbot_preview.html
  Android 없이 챗봇만 확인하는 브라우저 미리보기
```

챗봇 API 요청 형식:

```json
{
  "message": "지도에서 볼 항목 정리해줘",
  "user_id": "default_user",
  "history": [
    {"role": "user", "content": "최근 저장한 항목 요약해줘"}
  ]
}
```

챗봇 API 응답 형식:

```json
{
  "status": "success",
  "reply": "답변 내용",
  "provider": "watsonx",
  "model": "ibm/granite-4-h-small",
  "notice": "Watsonx Granite 모델로 생성한 응답입니다.",
  "citations": []
}
```

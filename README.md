# OpenCorpInsight

기업 재무 분석 및 AI 채팅봇을 위한 웹 애플리케이션입니다. DART API를 통한 재무 데이터 조회, Perplexity AI를 통한 뉴스 검색, GPT를 통한 AI 채팅 기능을 제공합니다.

## 주요 기능

### 대시보드
- 기업 재무 데이터 시각화
- 연도별 재무 지표 트렌드
- 실시간 뉴스 피드
- 감성 분석 기반 뉴스 분류

### AI 채팅봇
- 자연어 기반 기업 분석 질의
- 재무제표, 공시정보, 시계열 분석
- 실시간 뉴스 검색 및 요약

### 데이터 소스
- **DART API**: 기업 재무제표 데이터
- **Perplexity AI**: 실시간 뉴스 검색
- **OpenAI GPT**: 자연어 처리 및 분석

## 기술 스택

- **Backend**: Flask, Python 3.8+
- **Frontend**: Spring Boot, JSP, JavaScript
- **Database**: SQLite
- **API**: DART Open API, Perplexity AI, OpenAI GPT

## 프로젝트 구조

```
OpenCorpInsight/
├── app/                    # Flask 백엔드 API
│   ├── core/              # 핵심 모듈
│   ├── main.py            # Flask 메인 서버
│   └── schemas.py         # 데이터 스키마
├── DB/                    # DB API 서버
│   └── app.py             # SQLite DB 관리
├── front/                 # Spring Boot 프론트엔드
│   ├── src/main/java/     # Java 소스 코드
│   ├── src/main/resources/ # 설정 파일
│   └── build.gradle       # Gradle 설정
├── main_server.py         # Flask 메인 서버
├── requirements.txt       # Python 의존성
└── DEPLOY_GUIDE.md       # 실행 가이드
```

## 서버 구성

1. **DB API 서버** (포트 5002) - SQLite DB 관리
2. **Flask 메인 서버** (포트 5001) - 백엔드 API
3. **Spring Boot 프론트엔드** (포트 8080) - 웹 UI

## 빠른 시작

### 로컬 실행

1. **DB API 서버 실행**
```bash
cd DB
python3 -m venv venv
source venv/bin/activate
pip install -r ../requirements.txt
python app.py
```

2. **Flask 메인 서버 실행**
```bash
# 새 터미널에서
python3 main_server.py
```

3. **Spring Boot 프론트엔드 실행**
```bash
# 새 터미널에서
cd front
./gradlew bootRun
```

4. **브라우저에서 접속**
- 메인 웹사이트: `http://localhost:8080`

### EC2 배포

자세한 배포 방법은 `DEPLOY_GUIDE.md`를 참조하세요.

## API 엔드포인트

### 기업 검색
```
GET /api/company/search?name=삼성전자
```

### 뉴스 검색
```
GET /api/news/삼성전자?period=3days&limit=5
```

### AI 채팅
```
POST /api/chat
Content-Type: application/json

{
  "message": "삼성전자 2024년 현금흐름표 조회해줘",
  "user_info": {
    "user_sno": "test123",
    "nickname": "테스터"
  }
}
```

## 환경 설정

다음 API 키들이 필요합니다:
- `DART_API_KEY`: DART Open API 키
- `PERPLEXITY_API_KEY`: Perplexity AI API 키
- `GPT_API_KEY`: OpenAI GPT API 키

## 테스트

### API 연동 테스트
```bash
# DB API 서버 연결 테스트
curl http://localhost:5002/api/test

# 메인 서버 헬스 체크
curl http://localhost:5001/api/health

# 채팅 기능 테스트
curl -X POST http://localhost:5001/api/chat \
  -H "Content-Type: application/json" \
  -d '{"user_sno": "test", "nickname": "테스트", "difficulty": "intermediate", "interest": "기술주", "purpose": "투자분석", "chat_type": "general_chat", "message": "안녕하세요"}'
```

### 웹사이트 기능 테스트
- 메인 페이지: `http://localhost:8080`
- 채팅봇 페이지: `http://localhost:8080/chatBot`
- 기업 비교 페이지: `http://localhost:8080/compare`

## 주의사항

### 실행 순서
1. **반드시 DB API 서버를 먼저 실행**해야 합니다
2. 그 다음 Flask 메인 서버 실행
3. 마지막으로 Spring Boot 프론트엔드 실행

### 포트 충돌 확인
```bash
lsof -i :5002  # DB API 서버
lsof -i :5001  # Flask 메인 서버
lsof -i :8080  # Spring Boot 프론트엔드
```

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 문의

프로젝트에 대한 문의사항이 있으시면 Issues를 통해 연락해주세요.

---

**개발자**: OpenCorpInsight Team  
**최종 업데이트**: 2025년 1월
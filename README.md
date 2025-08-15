# OpenCorpInsight MCP Integration

기업 재무 분석 및 뉴스 검색을 위한 Flask 기반 웹 애플리케이션입니다. MCP(Microservice Core Project) 기능을 통합하여 실시간 재무 데이터 조회 및 뉴스 분석을 제공합니다.

## 🚀 주요 기능

### 📊 대시보드
- 기업 재무 데이터 시각화
- 연도별 재무 지표 트렌드
- 실시간 뉴스 피드
- 감성 분석 기반 뉴스 분류

### 💬 AI 채팅봇
- 자연어 기반 기업 분석 질의
- 동적 MCP 기능 연동
- 재무제표, 공시정보, 시계열 분석
- 실시간 뉴스 검색 및 요약

### 🔍 데이터 소스
- **DART API**: 기업 재무제표 데이터
- **Perplexity AI**: 실시간 뉴스 검색
- **OpenAI GPT**: 자연어 처리 및 분석

## 🛠️ 기술 스택

- **Backend**: Flask, Python 3.8+
- **Frontend**: HTML5, JavaScript, Chart.js
- **API**: DART Open API, Perplexity AI, OpenAI GPT
- **Infrastructure**: AWS Secrets Manager
- **MCP Core**: FastAPI 기반 마이크로서비스

## 📦 설치 및 실행

### 1. 저장소 클론
```bash
git clone https://github.com/[username]/OpenCorpInsight-new.git
cd OpenCorpInsight-new
```

### 2. 가상환경 설정
```bash
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# 또는
venv\Scripts\activate  # Windows
```

### 3. 의존성 설치
```bash
pip install -r requirements.txt
```

### 4. 환경 설정
AWS Secrets Manager에 다음 키들을 설정:
- `OPENCORPINSIGHT_SECRETS`: 통합 API 키 저장소
  - `DART_API_KEY`: DART Open API 키
  - `PERPLEXITY_API_KEY`: Perplexity AI API 키
  - `GPT_API_KEY`: OpenAI GPT API 키

### 5. 서버 실행
```bash
python3 main_server.py
```

### 6. 접속
- 대시보드: `http://localhost:5001/chat.html`
- API 테스트: `http://localhost:5001/test.html`

## 🔧 API 엔드포인트

### 대시보드 데이터
```
POST /api/dashboard
Content-Type: application/json

{
  "corp_code": "00126380",
  "bgn_de": "2022",
  "end_de": "2023",
  "user_info": {
    "user_sno": "test123",
    "nickname": "테스터",
    "purpose": "투자분석",
    "interest": "기술주",
    "difficulty": "intermediate"
  }
}
```

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

## 📁 프로젝트 구조

```
OpenCorpInsight-new/
├── app/
│   ├── core/
│   │   ├── dart_client.py      # DART API 클라이언트
│   │   ├── news_client.py      # Perplexity 뉴스 클라이언트
│   │   ├── secrets.py          # AWS Secrets 관리
│   │   └── services.py         # MCP 핵심 서비스
│   ├── main.py                 # FastAPI MCP 서버
│   ├── schemas.py              # 데이터 스키마
│   └── tool_registry.py        # MCP 도구 등록
├── main_server.py              # Flask 메인 서버
├── chat.html                   # 대시보드 프론트엔드
├── test.html                   # API 테스트 페이지
├── requirements.txt            # Python 의존성
├── Dockerfile                  # Docker 설정
└── README.md                   # 프로젝트 문서
```

## 🔐 보안

- 모든 API 키는 AWS Secrets Manager를 통해 관리
- 환경변수 직접 사용 금지
- 민감한 정보는 .gitignore에 포함

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 문의

프로젝트에 대한 문의사항이 있으시면 Issues를 통해 연락해주세요.

---

**개발자**: OpenCorpInsight Team  
**최종 업데이트**: 2025년 8월
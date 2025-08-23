# OpenCorpInsight 로컬 실행 가이드

## **프로젝트 구조**

### **서버 구성**
1. **DB API 서버** (포트 5002) - SQLite DB 관리
2. **Flask 메인 서버** (포트 5001) - 백엔드 API
3. **Spring Boot 프론트엔드** (포트 8080) - 웹 UI

### **포트 설정**
- **DB API 서버**: 포트 5002
- **Flask 메인 서버**: 포트 5001  
- **Spring Boot 프론트엔드**: 포트 8080

## **실행 방법**

### **1단계: DB API 서버 실행**
```bash
# DB 디렉토리로 이동
cd DB

# 가상환경 활성화 (필요시 생성)
python3 -m venv venv
source venv/bin/activate

# 의존성 설치
pip install -r requirements.txt

# DB API 서버 실행
python app.py
```

**예상 출력:**
```
✅ 데이터베이스 파일 확인: /path/to/DB/chatbot.db
🚀 Flask API 서버 시작...
📍 테스트 URL:
   - http://localhost:5002/api/test
   - http://localhost:5002/api/test/db
   - http://localhost:5002/api/users
   - http://localhost:5002/api/chat
 * Running on http://127.0.0.1:5002
```

### **2단계: Flask 메인 서버 실행**
```bash
# 새 터미널에서 프로젝트 루트 디렉토리로 이동
python3 main_server.py
```

**예상 출력:**
```
✅ MCP Secrets에서 API 키 로드 성공
✅ DART_API_KEY 설정됨
✅ MCP 서비스 초기화 성공
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5001
```

### **3단계: Spring Boot 프론트엔드 실행**
```bash
# 새 터미널에서 front 디렉토리로 이동
cd front
./gradlew bootRun
```

**예상 출력:**
```
> Task :bootRun
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.1)
 * Tomcat started on port 8080
```

### **4단계: 브라우저에서 접속**
- **메인 웹사이트**: `http://localhost:8080`

## 🧪 **테스트 체크리스트**

### **서버 실행 확인**
- [ ] DB API 서버 실행 확인 (포트 5002)
- [ ] Flask 메인 서버 실행 확인 (포트 5001)
- [ ] Spring Boot 프론트엔드 실행 확인 (포트 8080)
- [ ] 브라우저에서 웹사이트 접속 확인

### **API 연동 테스트**
- [ ] DB API 서버 연결 테스트
  ```bash
  curl http://localhost:5002/api/test
  ```
- [ ] DB 연결 테스트
  ```bash
  curl http://localhost:5002/api/test/db
  ```
- [ ] 메인 서버 헬스 체크
  ```bash
  curl http://localhost:5001/api/health
  ```
- [ ] 채팅 기능 테스트
  ```bash
  curl -X POST http://localhost:5001/api/chat \
    -H "Content-Type: application/json" \
    -d '{"user_sno": "test", "nickname": "테스트", "difficulty": "intermediate", "interest": "기술주", "purpose": "투자분석", "chat_type": "general_chat", "message": "안녕하세요"}'
  ```

### **웹사이트 기능 테스트**
- [ ] 메인 페이지 접속 (`http://localhost:8080`)
- [ ] 로그인/회원가입 페이지
- [ ] 채팅봇 페이지 (`http://localhost:8080/chatBot`)
- [ ] 기업 비교 페이지 (`http://localhost:8080/compare`)

## 🔍 **디버깅 팁**

### **포트 충돌 확인**
```bash
# 사용 중인 포트 확인
lsof -i :5002  # DB API 서버
lsof -i :5001  # Flask 메인 서버
lsof -i :8080  # Spring Boot 프론트엔드
```

### **서버 로그 확인**
```bash
# DB API 서버 로그
cd DB && python app.py

# Flask 메인 서버 로그
python3 main_server.py

# Spring Boot 로그
cd front && ./gradlew bootRun
```

### **브라우저 개발자 도구**
- Network 탭에서 API 호출 상태 확인
- Console 탭에서 JavaScript 에러 확인
- Application 탭에서 세션/쿠키 확인

## ⚠️ **주의사항**

### **실행 순서**
1. **반드시 DB API 서버를 먼저 실행**해야 합니다
2. 그 다음 Flask 메인 서버 실행
3. 마지막으로 Spring Boot 프론트엔드 실행

### **API 키 설정**
- 실제 기능 테스트를 위해서는 다음 API 키들이 필요합니다:
  - DART API 키 (금융 데이터용)
  - Perplexity API 키 (뉴스 검색용)
  - GPT API 키 (채팅 응답용)

## 🎯 **성공 기준**

✅ **로컬 실행 성공 조건:**
1. 3개 서버 모두 정상 실행
2. 포트 충돌 없음
3. 브라우저에서 웹사이트 정상 접속
4. DB 연결 정상 동작
5. 기본 UI 기능 동작 확인

모든 서버가 정상 실행되면 완전한 OpenCorpInsight 웹사이트를 로컬에서 이용할 수 있습니다! 🚀

# 🚀 로컬 연동 테스트 가이드

## 📋 **수정된 내용**

### ✅ **해결된 문제들**
1. **API 키 누락 시 서버 시작 실패** → 경고만 표시하고 서버 계속 실행
2. **외부 DB 서버 의존성** → 로컬 테스트용으로 비활성화
3. **Spring Boot 빌드 파일 누락** → build.gradle 및 gradle wrapper 생성
4. **CORS 설정** → 포트 8080, 8081 모두 허용
5. **샘플 데이터 제공** → API 키 없어도 테스트 가능

### 🔧 **포트 설정**
- **Spring Boot 서버**: 포트 8081 (변경됨)
- **Flask 서버**: 포트 5001 (고정)
- **chat.html**: `http://localhost:5001` (Flask 서버 직접 호출)

## 🚀 **테스트 실행 방법**

### **1. Flask 서버 실행**
```bash
# 프로젝트 루트 디렉토리에서
python main_server.py
```

**예상 출력:**
```
⚠️ DART_API_KEY가 설정되지 않았습니다! 일부 기능이 제한됩니다.
⚠️ 로컬 테스트를 위해 서버는 계속 실행됩니다.
⚠️ 실제 기능 테스트를 위해서는 DART API 키를 설정하세요.
✅ DART_API_KEY 설정됨
✅ MCP 서비스 초기화 성공
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5001
```

### **2. Spring Boot 서버 실행**
```bash
# front 디렉토리에서
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
 :: Spring Boot ::                (v3.2.0)

2024-01-XX XX:XX:XX.XXX  INFO 12345 --- [main] c.c.OpenCorpInsightApplication : Starting OpenCorpInsightApplication...
2024-01-XX XX:XX:XX.XXX  INFO 12345 --- [main] c.c.OpenCorpInsightApplication : Started OpenCorpInsightApplication in X.XXX seconds
```

### **3. 브라우저에서 접속**
- **Spring Boot**: `http://localhost:8081`
- **독립형 HTML**: `file:///Users/choetaeyeong/projects/OpenCorpInsight-new/chat.html`

## 🧪 **테스트 체크리스트**

### **기본 연결 테스트**
- [ ] Flask 서버 실행 확인 (포트 5001)
- [ ] Spring Boot 서버 실행 확인 (포트 8081)
- [ ] 브라우저에서 Spring Boot 접속 확인

### **API 연동 테스트**
- [ ] `/api/health` 엔드포인트 테스트
  ```bash
  curl http://localhost:5001/api/health
  ```
- [ ] 대시보드 데이터 로드 테스트
  ```bash
  curl -X POST http://localhost:5001/api/dashboard \
    -H "Content-Type: application/json" \
    -d '{"corp_code": "00126380", "bgn_de": "2020", "end_de": "2023"}'
  ```
- [ ] 채팅 기능 테스트
  ```bash
  curl -X POST http://localhost:5001/api/chat \
    -H "Content-Type: application/json" \
    -d '{"user_sno": "test", "nickname": "테스트", "difficulty": "intermediate", "interest": "기술주", "purpose": "투자분석", "chat_type": "general_chat", "message": "안녕하세요"}'
  ```

### **브라우저 테스트**
- [ ] Spring Boot 메인 페이지 접속
- [ ] 채팅 페이지 접속
- [ ] 기업 비교 페이지 접속
- [ ] 독립형 HTML 대시보드 접속

## 🔍 **디버깅 팁**

### **1. 포트 충돌 확인**
```bash
# 포트 사용 중인지 확인
lsof -i :5001
lsof -i :8081
```

### **2. 로그 확인**
```bash
# Flask 서버 로그
python main_server.py

# Spring Boot 로그
cd front && ./gradlew bootRun
```

### **3. 브라우저 개발자 도구**
- Network 탭에서 API 호출 확인
- Console 탭에서 JavaScript 에러 확인

## ⚠️ **주의사항**

### **API 키 없이 테스트 시**
- 재무 데이터는 샘플 데이터로 대체
- 뉴스 데이터는 샘플 뉴스로 대체
- 채팅 응답은 제한적

### **실제 기능 테스트를 위해서는**
- DART API 키 설정 필요
- Perplexity API 키 설정 필요 (뉴스 검색용)
- GPT API 키 설정 필요 (채팅 응답용)

## 🎯 **성공 기준**

✅ **연동 테스트 성공 조건:**
1. 두 서버 모두 정상 실행
2. 브라우저에서 Spring Boot 접속 가능
3. API 엔드포인트 응답 확인
4. CORS 오류 없음
5. 기본 UI 동작 확인

이제 로컬에서 안전하게 연동 테스트를 진행할 수 있습니다! 🚀

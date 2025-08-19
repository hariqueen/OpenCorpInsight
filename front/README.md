# 🚀 OpenCorpInsight Frontend

## 📋 빠른 시작

### 1. 자동 설치
```bash
# 설치 스크립트 실행
./setup.sh
```

### 2. 수동 설치
```bash
# Java 17 설치 (macOS)
brew install openjdk@17

# PATH 설정
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 의존성 다운로드 및 실행
./gradlew clean build
./gradlew bootRun
```

### 3. 접속
- **메인 페이지**: http://localhost:8081/
- **기업 비교**: http://localhost:8081/compare
- **채팅봇**: http://localhost:8081/chatBot

## 🔧 주요 기능

- ✅ **기업 검색**: 실시간 기업 검색 및 선택
- ✅ **기업 비교**: 두 기업 간 재무 비교 분석
- ✅ **사용자 인증**: 로그인/회원가입 시스템
- ✅ **AI 채팅**: 기업 분석 챗봇
- ✅ **반응형 디자인**: 모바일/데스크톱 지원

## 📚 상세 가이드

자세한 설치 및 개발 가이드는 [FRONTEND_UPDATE_GUIDE.md](./FRONTEND_UPDATE_GUIDE.md)를 참조하세요.

## 🐛 문제 해결

### 자주 발생하는 문제

1. **Java 버전 오류**
   ```bash
   # Java 17 설치 및 PATH 설정
   brew install openjdk@17
   echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

2. **포트 충돌**
   ```bash
   # 기존 프로세스 종료
   pkill -f "gradle.*bootRun"
   ```

3. **의존성 오류**
   ```bash
   # 의존성 재다운로드
   ./gradlew clean build
   ```

## 🔗 연동 시스템

- **Flask 백엔드**: 포트 5001
- **데이터베이스**: SQLite
- **API**: DART, Perplexity, GPT

## 📞 지원

문제가 발생하면 다음을 확인하세요:
1. Java 버전: `java -version`
2. 포트 사용: `lsof -i :8081`
3. 로그 확인: `./gradlew bootRun` 출력

---

**버전**: 1.0-SNAPSHOT  
**마지막 업데이트**: 2025-08-15

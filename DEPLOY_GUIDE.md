# OpenCorpInsight 실행 가이드

## **프로젝트 구조**
- **DB API 서버** (포트 5002) - SQLite DB 관리
- **Flask 메인 서버** (포트 5001) - 백엔드 API
- **Spring Boot 프론트엔드** (포트 8080) - 웹 UI

## **로컬 실행 방법**

### **1단계: DB API 서버 실행**
```bash
cd DB
python3 -m venv venv
source venv/bin/activate
pip install -r ../requirements.txt
python app.py
```

### **2단계: Flask 메인 서버 실행**
```bash
# 새 터미널에서
python3 main_server.py
```

### **3단계: Spring Boot 프론트엔드 실행**
```bash
# 새 터미널에서
cd front
./gradlew bootRun
```

### **4단계: 브라우저에서 접속**
- **메인 웹사이트**: `http://localhost:8080`

## **EC2 배포**

### **1단계: 프로젝트 업로드**
```bash
scp -r OpenCorpInsight ubuntu@your-ec2-ip:~/
ssh ubuntu@your-ec2-ip
```

### **2단계: DB API 서버**
```bash
cd ~/OpenCorpInsight/DB
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

sudo tee /etc/systemd/system/db-api.service << 'EOF'
[Unit]
Description=DB API Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/OpenCorpInsight/DB
Environment=PATH=/home/ubuntu/OpenCorpInsight/DB/venv/bin
ExecStart=/home/ubuntu/OpenCorpInsight/DB/venv/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable db-api
sudo systemctl start db-api
```

### **3단계: Flask 메인 서버**
```bash
cd ~/OpenCorpInsight

sudo tee /etc/systemd/system/flask-main.service << 'EOF'
[Unit]
Description=Flask Main Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/OpenCorpInsight
ExecStart=/usr/bin/python3 main_server.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable flask-main
sudo systemctl start flask-main
```

### **4단계: Spring Boot 프론트엔드**
```bash
cd ~/OpenCorpInsight/front
./gradlew clean build

sudo tee /etc/systemd/system/springboot-frontend.service << 'EOF'
[Unit]
Description=Spring Boot Frontend
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/OpenCorpInsight/front
ExecStart=/usr/bin/java -jar build/libs/OpenCorpInsight-1.0-SNAPSHOT.jar
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable springboot-frontend
sudo systemctl start springboot-frontend
```

## **테스트 및 확인**

### **서버 실행 확인**
- [ ] DB API 서버 실행 확인 (포트 5002)
- [ ] Flask 메인 서버 실행 확인 (포트 5001)
- [ ] Spring Boot 프론트엔드 실행 확인 (포트 8080)
- [ ] 브라우저에서 웹사이트 접속 확인

### **API 연동 테스트**
```bash
# DB API 서버 연결 테스트
curl http://localhost:5002/api/test

# DB 연결 테스트
curl http://localhost:5002/api/test/db

# 메인 서버 헬스 체크
curl http://localhost:5001/api/health

# 채팅 기능 테스트
curl -X POST http://localhost:5001/api/chat \
  -H "Content-Type: application/json" \
  -d '{"user_sno": "test", "nickname": "테스트", "difficulty": "intermediate", "interest": "기술주", "purpose": "투자분석", "chat_type": "general_chat", "message": "안녕하세요"}'
```

### **웹사이트 기능 테스트**
- [ ] 메인 페이지 접속 (`http://localhost:8080`)
- [ ] 로그인/회원가입 페이지
- [ ] 채팅봇 페이지 (`http://localhost:8080/chatBot`)
- [ ] 기업 비교 페이지 (`http://localhost:8080/compare`)

### **배포 환경 확인**
```bash
# 서비스 상태 확인
sudo systemctl status db-api flask-main springboot-frontend

# 포트 확인
ss -tlnp | grep -E ':(5001|5002|8080)'

# 접속 테스트
curl http://localhost:5002/api/test
curl http://localhost:5001/api/health
```

## **디버깅 팁**

### **포트 충돌 확인**
```bash
lsof -i :5002  # DB API 서버
lsof -i :5001  # Flask 메인 서버
lsof -i :8080  # Spring Boot 프론트엔드
```

### **서버 로그 확인**
```bash
# 로컬 환경
cd DB && python app.py
python3 main_server.py
cd front && ./gradlew bootRun

# 배포 환경
sudo journalctl -u [서비스명] -f
```

## **주의사항**

### **실행 순서**
1. **반드시 DB API 서버를 먼저 실행**해야 합니다
2. 그 다음 Flask 메인 서버 실행
3. 마지막으로 Spring Boot 프론트엔드 실행

### **API 키 설정**
- 실제 기능 테스트를 위해서는 다음 API 키들이 필요합니다:
  - DART API 키 (금융 데이터용)
  - Perplexity API 키 (뉴스 검색용)
  - GPT API 키 (채팅 응답용)

### **배포 환경 설정**
- EC2 보안 그룹에서 포트 5001, 5002, 8080 열기
- 로그 확인: `sudo journalctl -u [서비스명] -f`

## **성공 기준**

**로컬 실행 성공 조건:**
1. 3개 서버 모두 정상 실행
2. 포트 충돌 없음
3. 브라우저에서 웹사이트 정상 접속
4. DB 연결 정상 동작
5. 기본 UI 기능 동작 확인

**배포 성공 조건:**
1. 3개 서비스 모두 활성 상태
2. 포트 정상 바인딩 (5001, 5002, 8080)
3. 웹사이트 정상 접속
4. API 응답 정상
5. DB 연결 정상


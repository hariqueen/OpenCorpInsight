# 🚀 OpenCorpInsight 배포 가이드

## 📋 **프로젝트 구조**

현재 OpenCorpInsight는 3개의 독립적인 서버로 구성되어 있습니다:

1. **DB API 서버** (포트 5002) - SQLite DB 관리
2. **Flask 메인 서버** (포트 5001) - 백엔드 API 및 비즈니스 로직
3. **Spring Boot 프론트엔드** (포트 8080) - 웹 UI

## 🌐 **EC2 배포 방법**

### **1단계: EC2 인스턴스 준비**
```bash
# 프로젝트 업로드
scp -i your-key.pem -r OpenCorpInsight ubuntu@your-ec2-ip:~/

# EC2 접속
ssh -i your-key.pem ubuntu@your-ec2-ip
```

### **2단계: DB API 서버 설정**
```bash
cd ~/OpenCorpInsight/DB

# 가상환경 생성 및 활성화
python3 -m venv venv
source venv/bin/activate

# 의존성 설치
pip install -r requirements.txt

# systemd 서비스 생성
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
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 서비스 활성화
sudo systemctl daemon-reload
sudo systemctl enable db-api
sudo systemctl start db-api
```

### **3단계: Flask 메인 서버 설정**
```bash
cd ~/OpenCorpInsight

# systemd 서비스 생성
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
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 서비스 활성화
sudo systemctl daemon-reload
sudo systemctl enable flask-main
sudo systemctl start flask-main
```

### **4단계: Spring Boot 프론트엔드 설정**
```bash
cd ~/OpenCorpInsight/front

# JAR 파일 빌드
./gradlew clean build

# systemd 서비스 생성
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
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 서비스 활성화
sudo systemctl daemon-reload
sudo systemctl enable springboot-frontend
sudo systemctl start springboot-frontend
```

## 🔧 **Nginx 리버스 프록시 설정 (선택사항)**

```bash
# Nginx 설치
sudo apt update
sudo apt install nginx

# 설정 파일 생성
sudo tee /etc/nginx/sites-available/opencorpinsight << 'EOF'
server {
    listen 80;
    server_name your-domain.com;

    # Spring Boot 프론트엔드 (메인)
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Flask API
    location /api/ {
        proxy_pass http://localhost:5001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 사이트 활성화
sudo ln -s /etc/nginx/sites-available/opencorpinsight /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

## 🔍 **배포 확인**

### **서비스 상태 확인**
```bash
# 모든 서비스 상태 확인
sudo systemctl status db-api
sudo systemctl status flask-main  
sudo systemctl status springboot-frontend

# 포트 사용 확인
ss -tlnp | grep -E ':(5001|5002|8080)'
```

### **접속 테스트**
```bash
# DB API 서버 테스트
curl http://localhost:5002/api/test

# Flask 메인 서버 테스트  
curl http://localhost:5001/api/health

# 웹사이트 접속
# http://your-ec2-ip:8080 (또는 도메인)
```

## ⚠️ **주의사항**

### **보안 설정**
- EC2 보안 그룹에서 필요한 포트만 열기
- SSL/TLS 인증서 설정 권장
- 방화벽 설정 확인

### **API 키 설정**
- DART API 키
- Perplexity API 키  
- GPT API 키

### **모니터링**
```bash
# 로그 확인
sudo journalctl -u db-api -f
sudo journalctl -u flask-main -f
sudo journalctl -u springboot-frontend -f
```

## 🎯 **성공 기준**

✅ **배포 성공 조건:**
1. 3개 서비스 모두 활성 상태
2. 포트 정상 바인딩 (5001, 5002, 8080)
3. 웹사이트 정상 접속
4. API 응답 정상
5. DB 연결 정상

모든 조건이 만족되면 OpenCorpInsight가 성공적으로 배포됩니다! 🚀

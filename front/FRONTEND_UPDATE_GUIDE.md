# 🚀 Frontend 업데이트 가이드

## 📋 개요

이 가이드는 `OpenCorpInsight-jiyoon-fullstack`의 최신 프론트엔드 구성을 기존 `front` 폴더에 적용하는 방법을 설명합니다.

## 🔄 주요 변경사항

### 1. Spring Boot 3.2.1 업그레이드
- **Java 버전**: 17 → 21 (안정성을 위해 17로 다운그레이드)
- **Spring Boot**: 3.2.0 → 3.2.1
- **Spring Security**: 추가됨
- **MyBatis**: 데이터베이스 매핑 추가

### 2. 새로운 기능 추가
- **사용자 인증 시스템**: 로그인/회원가입
- **비밀번호 암호화**: BCrypt 사용
- **세션 관리**: HttpSession 기반
- **기업 검색 API**: 외부 API 연동

### 3. 페이지 구조 개선
- **JSP 템플릿**: 최신 디자인 적용
- **모달 팝업**: 기업 검색 기능
- **반응형 디자인**: 모바일 친화적

## 🛠️ 설치 및 설정

### 1. Java 환경 설정

```bash
# Java 17 설치 (macOS)
brew install openjdk@17

# PATH 설정
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Java 버전 확인
java -version
```

### 2. 프로젝트 구조 확인

```
front/
├── build.gradle                    # Gradle 빌드 설정 (업데이트됨)
├── gradlew                         # Gradle Wrapper
├── gradlew.bat                     # Gradle Wrapper (Windows)
├── gradle/wrapper/                 # Gradle Wrapper 설정
├── src/
│   └── main/
│       ├── java/com/corpIns/
│       │   ├── OpenCorpInsightApplication.java  # 메인 애플리케이션
│       │   ├── controller/                      # 컨트롤러
│       │   │   ├── CommonController.java        # 공통 페이지
│       │   │   ├── LoginController.java         # 로그인/회원가입
│       │   │   └── CorpSearchController.java    # 기업 검색 API
│       │   ├── service/                         # 서비스 레이어
│       │   │   └── UserService.java             # 사용자 서비스
│       │   ├── mapper/                          # MyBatis 매퍼
│       │   │   └── UserMapper.java              # 사용자 매퍼
│       │   ├── dto/                             # 데이터 전송 객체
│       │   │   └── User.java                    # 사용자 DTO
│       │   └── config/                          # 설정
│       │       └── SecurityConfig.java          # Spring Security 설정
│       ├── resources/
│       │   ├── application.yml                  # 애플리케이션 설정
│       │   └── mappers/                         # MyBatis XML 매퍼
│       └── webapp/WEB-INF/views/                # JSP 페이지
│           ├── index.jsp                        # 메인 페이지
│           ├── common/                          # 공통 페이지
│           │   ├── compare.jsp                  # 기업 비교
│           │   ├── chatBot.jsp                  # 채팅봇
│           │   ├── compareDetail.jsp            # 상세 비교
│           │   ├── myPage.jsp                   # 마이페이지
│           │   ├── chatBotDash.jsp              # 채팅봇 대시보드
│           │   └── modal/                       # 모달 팝업
│           │       └── compSearchPopUp.jsp      # 기업 검색 팝업
│           ├── login/                           # 로그인 페이지
│           │   ├── login.jsp                    # 로그인
│           │   ├── join.jsp                     # 회원가입
│           │   ├── setProfile.jsp               # 프로필 설정
│           │   └── joinAction.jsp               # 회원가입 처리
│           └── layout/                          # 레이아웃
│               ├── sideMenu.jsp                 # 사이드 메뉴
│               ├── searchBar.jsp                # 검색바
│               └── floating.jsp                 # 플로팅 요소
```

### 3. 의존성 업데이트

#### build.gradle 주요 변경사항

```gradle
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.2.1'  // 3.2.0 → 3.2.1
    id 'io.spring.dependency-management' version '1.1.4'
}

group = 'com.corpIns'
version = '1.0-SNAPSHOT'  // 0.0.1-SNAPSHOT → 1.0-SNAPSHOT

java {
    sourceCompatibility = '17'  // 21 → 17 (안정성)
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-security'  // 추가
    implementation 'org.springframework.boot:spring-boot-devtools'          // 추가
    
    // MyBatis 추가
    implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:3.0.3'
    
    // JSP (버전 업데이트)
    implementation 'org.apache.tomcat.embed:tomcat-embed-jasper'
    implementation 'jakarta.servlet:jakarta.servlet-api'
    implementation 'jakarta.servlet.jsp.jstl:jakarta.servlet.jsp.jstl-api:3.0.0'
    implementation 'org.glassfish.web:jakarta.servlet.jsp.jstl:3.0.1'
    
    // SQLite 추가
    implementation 'org.xerial:sqlite-jdbc:3.45.1.0'
    
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
    
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

### 4. 애플리케이션 설정

#### application.yml 주요 변경사항

```yaml
server:
  port: 8081  # 포트 설정

spring:
  mvc:
    view:
      prefix: /WEB-INF/views/
      suffix: .jsp
  
  # 데이터베이스 설정 추가c
  datasource:
    url: jdbc:sqlite:/home/ubuntu/chatbot.db
    driver-class-name: org.sqlite.JDBC
  
  jpa:
    hibernate:
      ddl-auto: none

# MyBatis 설정 추가
mybatis:
  mapper-locations: classpath*:mappers/*.xml
```

## 🚀 실행 방법

### 1. 빌드 및 실행

```bash
# 프로젝트 디렉토리로 이동
cd front

# Gradle Wrapper 권한 설정 (macOS/Linux)
chmod +x gradlew

# 의존성 다운로드 및 빌드
./gradlew clean build

# 애플리케이션 실행
./gradlew bootRun
```

### 2. 접속 확인

- **메인 페이지**: http://localhost:8081/
- **기업 비교**: http://localhost:8081/compare
- **채팅봇**: http://localhost:8081/chatBot
- **로그인**: http://localhost:8081/login
- **회원가입**: http://localhost:8081/join

## 🔧 주요 기능 설명

### 1. 기업 검색 시스템

#### API 엔드포인트
- **GET /api/search**: 기업 검색 API
- **파라미터**: q (검색어), limit (결과 수), bgn_de, end_de (날짜 범위)

#### 사용 방법
1. `/compare` 페이지 접속
2. VS 버튼 클릭 → 기업 검색 팝업 열림
3. 기업명 입력 → 검색 결과 표시
4. 기업 선택 → 비교 페이지로 이동

### 2. 사용자 인증 시스템

#### 기능
- **회원가입**: 이메일, 비밀번호 입력
- **로그인**: 세션 기반 인증
- **비밀번호 암호화**: BCrypt 사용
- **로그아웃**: 세션 무효화

#### API 엔드포인트
- **POST /joinAction**: 회원가입 처리
- **POST /loginAction**: 로그인 처리
- **POST /logout**: 로그아웃 처리

### 3. Spring Security 설정

#### SecurityConfig.java
```java
@Configuration
public class SecurityConfig {
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .anyRequest().permitAll()
            );
        return http.build();
    }
}
```

## 🐛 문제 해결

### 1. Java 버전 오류
```
error: invalid source release: 21
```
**해결**: build.gradle에서 `sourceCompatibility = '17'`로 설정

### 2. Spring Security import 오류
```
The import org.springframework.security cannot be resolved
```
**해결**: `./gradlew clean build`로 의존성 재다운로드

### 3. 기업 검색 결과가 항상 동일한 경우
**원인**: API 호출 방식 불일치
**해결**: JSP에서 Spring Boot 백엔드 경유로 API 호출

### 4. 포트 충돌
```
Port 8081 is already in use
```
**해결**: 
```bash
# 실행 중인 프로세스 종료
pkill -f "gradle.*bootRun"

# 또는 다른 포트 사용
# application.yml에서 server.port 변경
```

## 📝 개발 가이드

### 1. 새로운 페이지 추가

1. **JSP 파일 생성**: `src/main/webapp/WEB-INF/views/`
2. **컨트롤러 메서드 추가**: `CommonController.java`
3. **URL 매핑**: `@GetMapping("/newPage")`

### 2. API 엔드포인트 추가

1. **컨트롤러 클래스 생성**: `src/main/java/com/corpIns/controller/`
2. **서비스 클래스 생성**: `src/main/java/com/corpIns/service/`
3. **매퍼 인터페이스 생성**: `src/main/java/com/corpIns/mapper/`

### 3. 데이터베이스 연동

1. **MyBatis 매퍼 XML**: `src/main/resources/mappers/`
2. **DTO 클래스**: `src/main/java/com/corpIns/dto/`
3. **서비스 로직**: `src/main/java/com/corpIns/service/`

## 🔗 연동 시스템

### 1. Flask 백엔드 연동
- **포트**: 5001
- **CORS**: http://localhost:8081 허용
- **API**: `/api/dashboard`, `/api/chat` 등

### 2. 데이터베이스
- **SQLite**: 로컬 파일 기반
- **MyBatis**: ORM 매핑
- **스키마**: 자동 생성 (ddl-auto: none)

## 📊 성능 최적화

### 1. 빌드 최적화
```bash
# 개발 모드 (핫 리로드)
./gradlew bootRun

# 프로덕션 빌드
./gradlew bootJar
```

### 2. 메모리 설정
```bash
# JVM 힙 메모리 설정
export GRADLE_OPTS="-Xmx2g -Xms1g"
./gradlew bootRun
```

## 🧪 테스트

### 1. 단위 테스트
```bash
./gradlew test
```

### 2. 통합 테스트
```bash
# 애플리케이션 실행 후
curl http://localhost:8081/api/search?q=삼성전자
```

### 3. 브라우저 테스트
1. http://localhost:8081/ 접속
2. 기업 검색 기능 테스트
3. 로그인/회원가입 테스트
4. 페이지 이동 테스트

## 📞 지원

### 문제 발생 시 확인사항
1. **Java 버전**: `java -version`
2. **포트 사용**: `lsof -i :8081`
3. **로그 확인**: `./gradlew bootRun` 출력
4. **의존성 확인**: `./gradlew dependencies`

### 로그 레벨 설정
```yaml
# application.yml
logging:
  level:
    com.corpIns: DEBUG
    org.springframework.web: DEBUG
```

---

**마지막 업데이트**: 2025-08-15
**버전**: 1.0-SNAPSHOT
**작성자**: AI Assistant

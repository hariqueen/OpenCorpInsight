#!/bin/bash

# 🚀 Frontend 설치 스크립트
# 이 스크립트는 front 폴더의 최신 버전을 설정합니다.

echo "🚀 OpenCorpInsight Frontend 설치를 시작합니다..."

# 1. Java 환경 확인
echo "📋 Java 환경을 확인합니다..."
if ! command -v java &> /dev/null; then
    echo "❌ Java가 설치되지 않았습니다."
    echo "💡 다음 명령어로 Java 17을 설치하세요:"
    echo "   brew install openjdk@17"
    echo "   echo 'export PATH=\"/opt/homebrew/opt/openjdk@17/bin:\$PATH\"' >> ~/.zshrc"
    echo "   source ~/.zshrc"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
echo "✅ Java 버전: $JAVA_VERSION"

if [ "$JAVA_VERSION" -lt "17" ]; then
    echo "⚠️  Java 17 이상이 필요합니다. 현재 버전: $JAVA_VERSION"
    echo "💡 Java 17을 설치하고 PATH를 업데이트하세요."
    exit 1
fi

# 2. Gradle Wrapper 권한 설정
echo "📋 Gradle Wrapper 권한을 설정합니다..."
chmod +x gradlew
echo "✅ Gradle Wrapper 권한 설정 완료"

# 3. 의존성 다운로드
echo "📦 의존성을 다운로드합니다..."
./gradlew clean build --no-daemon
if [ $? -ne 0 ]; then
    echo "❌ 빌드 실패. 오류를 확인하세요."
    exit 1
fi
echo "✅ 의존성 다운로드 완료"

# 4. 포트 확인
echo "🔍 포트 8081 사용 여부를 확인합니다..."
if lsof -i :8081 > /dev/null 2>&1; then
    echo "⚠️  포트 8081이 이미 사용 중입니다."
    echo "💡 다음 명령어로 기존 프로세스를 종료하세요:"
    echo "   pkill -f 'gradle.*bootRun'"
    echo "   또는 다른 포트를 사용하세요."
else
    echo "✅ 포트 8081 사용 가능"
fi

# 5. Flask 백엔드 확인
echo "🔍 Flask 백엔드 상태를 확인합니다..."
if lsof -i :5001 > /dev/null 2>&1; then
    echo "✅ Flask 백엔드가 포트 5001에서 실행 중입니다."
else
    echo "⚠️  Flask 백엔드가 실행되지 않았습니다."
    echo "💡 Flask 백엔드를 먼저 실행하세요:"
    echo "   cd .. && source venv/bin/activate && python main_server.py"
fi

echo ""
echo "🎉 설치가 완료되었습니다!"
echo ""
echo "📋 다음 명령어로 애플리케이션을 실행하세요:"
echo "   ./gradlew bootRun"
echo ""
echo "🌐 브라우저에서 다음 주소로 접속하세요:"
echo "   http://localhost:8081"
echo ""
echo "📚 자세한 내용은 FRONTEND_UPDATE_GUIDE.md를 참조하세요."

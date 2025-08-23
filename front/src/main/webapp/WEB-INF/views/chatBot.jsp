<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>AI 챗봇 - OpenCorpInsight</title>
    <style>
        body {
            margin: 0;
            background-color: #161e63;
            font-family: 'Pretendard', sans-serif;
            color: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .container {
            flex: 1;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            display: flex;
            flex-direction: column;
            height: calc(100vh - 140px);
        }

        .chat-header {
            text-align: center;
            margin-bottom: 20px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }

        .chat-header h1 {
            margin: 0;
            font-size: 2rem;
            background: linear-gradient(45deg, #00ffff, #0077ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .chat-header p {
            margin: 10px 0 0 0;
            color: rgba(255, 255, 255, 0.8);
            font-size: 1rem;
        }

        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            margin-bottom: 20px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .message {
            display: flex;
            margin-bottom: 20px;
            animation: fadeIn 0.3s ease-in;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .message.user {
            flex-direction: row-reverse;
        }

        .message-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 10px;
            font-size: 18px;
            font-weight: bold;
        }

        .message.user .message-avatar {
            background: linear-gradient(45deg, #00ffff, #0077ff);
            color: #161e63;
        }

        .message.assistant .message-avatar {
            background: linear-gradient(45deg, #ff6b6b, #ffa500);
            color: white;
        }

        .message-content {
            max-width: 70%;
            padding: 15px 20px;
            border-radius: 20px;
            word-wrap: break-word;
            line-height: 1.5;
        }

        .message.user .message-content {
            background: linear-gradient(135deg, #00ffff, #0077ff);
            color: #161e63;
            border-bottom-right-radius: 5px;
        }

        .message.assistant .message-content {
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border-bottom-left-radius: 5px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .message-content p {
            margin: 0 0 10px 0;
        }

        .message-content p:last-child {
            margin-bottom: 0;
        }

        .message-content table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 8px;
            overflow: hidden;
        }

        .message-content th,
        .message-content td {
            padding: 8px 12px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .message-content th {
            background: rgba(255, 255, 255, 0.2);
            font-weight: bold;
        }

        .message-content code {
            background: rgba(0, 0, 0, 0.3);
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
        }

        .message-content pre {
            background: rgba(0, 0, 0, 0.3);
            padding: 15px;
            border-radius: 8px;
            overflow-x: auto;
            margin: 10px 0;
        }

        .chat-input-container {
            display: flex;
            gap: 10px;
            padding: 20px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .chat-input {
            flex: 1;
            padding: 15px 20px;
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 25px;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            font-size: 16px;
            outline: none;
            transition: all 0.3s ease;
            resize: none;
            min-height: 20px;
            max-height: 120px;
            font-family: inherit;
        }

        .chat-input:focus {
            border-color: #00ffff;
            box-shadow: 0 0 15px rgba(0, 255, 255, 0.3);
        }

        .chat-input::placeholder {
            color: rgba(255, 255, 255, 0.6);
        }

        .send-button {
            background: linear-gradient(45deg, #00ffff, #0077ff);
            color: #161e63;
            border: none;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 255, 255, 0.3);
        }

        .send-button:hover:not(:disabled) {
            transform: scale(1.1);
            box-shadow: 0 6px 20px rgba(0, 255, 255, 0.5);
        }

        .send-button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        .search-button {
            background: linear-gradient(45deg, #ff6b6b, #ffa500);
            color: white;
            border: none;
            border-radius: 25px;
            padding: 10px 20px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
            margin-left: 10px;
            font-weight: bold;
            font-size: 14px;
            min-width: 100px;
        }

        .search-button:hover:not(:disabled) {
            transform: scale(1.1);
            box-shadow: 0 6px 20px rgba(255, 107, 107, 0.5);
        }

        .search-button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        .spinner {
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-top: 2px solid #00ffff;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .welcome-message {
            text-align: center;
            padding: 40px 20px;
            color: rgba(255, 255, 255, 0.8);
        }

        .welcome-message h2 {
            margin-bottom: 15px;
            color: #00ffff;
        }

        .welcome-message p {
            margin-bottom: 10px;
            line-height: 1.6;
        }

        .suggestion-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 20px;
            justify-content: center;
        }

        .suggestion-chip {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            padding: 8px 16px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 14px;
        }

        .suggestion-chip:hover {
            background: rgba(0, 255, 255, 0.2);
            border-color: #00ffff;
            transform: translateY(-2px);
        }

        /* 스크롤바 스타일링 */
        .chat-messages::-webkit-scrollbar {
            width: 8px;
        }

        .chat-messages::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 4px;
        }

        .chat-messages::-webkit-scrollbar-thumb {
            background: rgba(0, 255, 255, 0.3);
            border-radius: 4px;
        }

        .chat-messages::-webkit-scrollbar-thumb:hover {
            background: rgba(0, 255, 255, 0.5);
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }
    </style>
</head>
<body>
<%@ include file="layout/sideMenu.jsp" %>

<div class="container">
    <div class="chat-header">
        <h1>🤖 AI 챗봇</h1>
        <p>재무 분석, 투자 상담, 기업 정보 등 무엇이든 물어보세요!</p>
    </div>

    <div class="chat-messages" id="chatMessages">
        <div id="messagesContainer">
            <div class="welcome-message">
                <h2>안녕하세요! 👋</h2>
                <p>저는 OpenCorpInsight의 AI 챗봇입니다.</p>
                <p>재무 분석, 투자 상담, 기업 정보 등 다양한 질문에 답변해드릴 수 있습니다.</p>
                
                <div class="suggestion-chips">
                    <div class="suggestion-chip" onclick="sendSuggestion('ROE와 ROA의 차이점은?')">재무비율 설명</div>
                    <div class="suggestion-chip" onclick="sendSuggestion('투자 포트폴리오 구성법을 알려주세요')">포트폴리오 구성</div>
                    <div class="suggestion-chip" onclick="sendSuggestion('현금흐름표 분석 방법은?')">현금흐름 분석</div>
                    <div class="suggestion-chip" onclick="sendSuggestion('재무제표 읽는 법을 알려주세요')">재무제표 읽기</div>
                </div>
            </div>
        </div>
</div>

    <div class="chat-input-container">
        <textarea 
            class="chat-input" 
            id="chatInput" 
            placeholder="메시지를 입력하세요... (Enter로 전송, Shift+Enter로 줄바꿈)"
            rows="1"
        ></textarea>
        <button class="send-button" id="sendButton">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                <path d="M22 2L11 13M22 2L15 22L11 13M22 2L2 9L11 13" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
        </button>
        <button class="search-button" id="searchBtn" style="display: none;">
            기업검색
        </button>
    </div>
</div>

<script>
    const API_BASE_URL = 'http://43.203.170.37:5001';
    const chatMessages = document.getElementById('chatMessages');
    const chatInput = document.getElementById('chatInput');
    const sendButton = document.getElementById('sendButton');

    // 메시지 추가 함수
    function addMessage(role, content) {
        const messagesContainer = document.getElementById('messagesContainer');
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${role}`;

        const avatar = document.createElement('div');
        avatar.className = 'message-avatar';
        avatar.textContent = role === 'user' ? '나' : 'AI';
        
        const contentDiv = document.createElement('div');
        contentDiv.className = 'message-content';
        
        // AI 응답인 경우 마크다운 스타일 적용
        if (role === 'assistant') {
            contentDiv.innerHTML = formatAIResponse(content);
        } else {
            contentDiv.textContent = content;
        }
        
        messageDiv.appendChild(avatar);
        messageDiv.appendChild(contentDiv);
        messagesContainer.appendChild(messageDiv);
        
        // 스크롤을 맨 아래로 (부드러운 스크롤)
        setTimeout(() => {
            const chatMessages = document.getElementById('chatMessages');
            chatMessages.scrollTo({
                top: chatMessages.scrollHeight,
                behavior: 'smooth'
            });
        }, 100);
    }

    // 🤖 AI 응답 포맷팅 함수 (시각화 지원)
    function formatAIResponse(content) {
        let formattedContent = content;
        
        // 재무비율 테이블 패턴 감지 및 변환
        formattedContent = detectAndFormatFinancialRatios(formattedContent);
        
        // 차트 데이터 패턴 감지 및 변환
        formattedContent = detectAndFormatCharts(formattedContent);
        
        // **텍스트** → <strong>텍스트</strong>
        formattedContent = formattedContent.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        
        // *텍스트* → <em>텍스트</em>
        formattedContent = formattedContent.replace(/\*(.*?)\*/g, '<em>$1</em>');
        
        // 줄바꿈 처리
        formattedContent = formattedContent.replace(/\n/g, '<br>');
        
        // 백만원 → 원으로 변경
        formattedContent = formattedContent.replace(/백만원/g, '원');
        
        // 숫자와 퍼센트 강조
        formattedContent = formattedContent.replace(/(\d+\.?\d*%)/g, '<span style="color: #00d4ff; font-weight: bold;">$1</span>');
        
        // 재무비율 강조
        const ratioPatterns = [
            /(ROE|ROA|부채비율|영업이익률|자기자본이익률|총자산이익률)/g,
            /(\d+\.?\d*%)(?=\s*로)/g
        ];
        
        ratioPatterns.forEach(pattern => {
            formattedContent = formattedContent.replace(pattern, '<span style="color: #00ffcc; font-weight: bold;">$1</span>');
        });
        
        return formattedContent;
    }

    // 재무비율 테이블 감지 및 변환
    function detectAndFormatFinancialRatios(content) {
        // 재무비율 테이블 패턴 감지
        const ratioPattern = /(\w+[:\s]+[\d\.]+%?)/g;
        const matches = content.match(ratioPattern);
        
        if (matches && matches.length >= 3) {
            let tableHTML = '<table style="width: 100%; border-collapse: collapse; margin: 10px 0; background: rgba(255, 255, 255, 0.1); border-radius: 8px; overflow: hidden;">';
            tableHTML += '<thead><tr style="background: rgba(255, 255, 255, 0.2);"><th style="padding: 8px 12px; text-align: left; border-bottom: 1px solid rgba(255, 255, 255, 0.1);">지표</th><th style="padding: 8px 12px; text-align: left; border-bottom: 1px solid rgba(255, 255, 255, 0.1);">값</th></tr></thead>';
            tableHTML += '<tbody>';
            
            matches.forEach(match => {
                const [indicator, value] = match.split(/[:\s]+/);
                tableHTML += `<tr><td style="padding: 8px 12px; text-align: left; border-bottom: 1px solid rgba(255, 255, 255, 0.1);">${indicator}</td><td style="padding: 8px 12px; text-align: left; border-bottom: 1px solid rgba(255, 255, 255, 0.1); color: #00d4ff; font-weight: bold;">${value}</td></tr>`;
            });
            
            tableHTML += '</tbody></table>';
            
            // 원본 텍스트를 테이블로 교체
            content = content.replace(ratioPattern, tableHTML);
        }
        
        return content;
    }

    // 차트 데이터 감지 및 변환
    function detectAndFormatCharts(content) {
        // 연도별 데이터 패턴 감지 (예: 2020년: 100억원, 2021년: 120억원)
        const yearPattern = /(\d{4}년[:\s]+[\d,]+억?원)/g;
        const matches = content.match(yearPattern);
        
        if (matches && matches.length >= 2) {
            let chartHTML = '<div style="background: rgba(255, 255, 255, 0.05); border-radius: 8px; padding: 15px; margin: 10px 0; border: 1px solid rgba(255, 255, 255, 0.1);">';
            chartHTML += '<h4 style="margin: 0 0 10px 0; color: #00d4ff;">📈 연도별 추이</h4>';
            
            matches.forEach(match => {
                chartHTML += `<div style="margin: 5px 0; padding: 5px 10px; background: rgba(0, 212, 255, 0.1); border-radius: 4px; border-left: 3px solid #00d4ff;">${match}</div>`;
            });
            
            chartHTML += '</div>';
            
            // 원본 텍스트를 차트로 교체
            content = content.replace(yearPattern, chartHTML);
        }
        
        return content;
    }

    // 🏢 기업 검색 팝업 표시 함수
    function showCompanySearchPopup(actionData) {
        // 검색 버튼 활성화
        const searchBtn = document.getElementById('searchBtn');
        searchBtn.style.display = 'flex';
        
        // 검색 버튼에 애니메이션 효과 추가
        searchBtn.style.animation = 'pulse 2s infinite';
        
        console.log('🔍 검색 버튼 활성화됨');
    }

    // 🏢 기업 검색 팝업 열기
    function openCompanySearch() {
        const popupUrl = 'http://localhost:8081/compare/compSearchPopUp';
        const popupWindow = window.open(
            popupUrl,
            'companySearch',
            'width=800,height=600,scrollbars=yes,resizable=yes,status=yes,location=yes,toolbar=yes,menubar=yes'
        );
        
        // 팝업이 차단되었는지 확인
        if (!popupWindow || popupWindow.closed || typeof popupWindow.closed == 'undefined') {
            alert('팝업이 차단되었습니다. 팝업 차단을 해제하고 다시 시도해주세요.');
            return;
        }
        
        // 팝업 창에 메시지 전달 (선택사항)
        popupWindow.focus();
        
        // 검색 버튼 비활성화
        hideSearchButton();
        
        console.log('🔍 기업 검색 팝업 열기:', popupUrl);
    }

    // 🔍 검색 버튼 숨기기
    function hideSearchButton() {
        const searchBtn = document.getElementById('searchBtn');
        searchBtn.style.display = 'none';
        searchBtn.style.animation = 'none';
    }

    // 제안 메시지 전송
    function sendSuggestion(text) {
        chatInput.value = text;
        sendMessage();
    }

    // 메시지 전송 함수
    async function sendMessage() {
        const message = chatInput.value.trim();
        if (!message) return;

        // 사용자 메시지 추가
        addMessage('user', message);
        chatInput.value = '';
        chatInput.style.height = 'auto';

        // 전송 버튼 비활성화 및 로딩 표시
        sendButton.disabled = true;
        sendButton.innerHTML = '<div class="spinner"></div>';

        // 로딩 메시지
        const loadingMessageId = 'loading-' + Date.now();
        addMessage('assistant', `<div id="${loadingMessageId}">분석 중입니다... 잠시만 기다려주세요! 🔍</div>`);

        try {
            // Flask 서버로 메시지 전송
            const response = await sendChatMessage(message);

            // 로딩 메시지 제거
            const loadingElement = document.getElementById(loadingMessageId);
            if (loadingElement) {
                loadingElement.parentElement.parentElement.remove();
            }

            // AI 응답 추가
            addMessage('assistant', response);

        } catch (error) {
            // 로딩 메시지 제거
            const loadingElement = document.getElementById(loadingMessageId);
            if (loadingElement) {
                loadingElement.parentElement.parentElement.remove();
            }

            // 에러 메시지 추가
            addMessage('assistant', `죄송합니다. 현재 응답을 생성할 수 없습니다. 서버 연결을 확인해주세요. (${error.message})`);
        } finally {
            // 전송 버튼 활성화
            sendButton.disabled = false;
            sendButton.innerHTML = `
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                    <path d="M22 2L11 13M22 2L15 22L11 13M22 2L2 9L11 13" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            `;
            chatInput.focus();
        }
    }

    // Flask 서버로 채팅 메시지 전송
    async function sendChatMessage(message) {
        try {
            console.log('🔍 API_BASE_URL 확인:', API_BASE_URL);
            const fullUrl = API_BASE_URL + '/api/chat';
            console.log('🔍 요청 URL:', fullUrl);
            
            const requestData = {
                user_sno: 'web_user',
                nickname: '웹사용자',
                difficulty: 'intermediate',
                interest: '기술주',
                purpose: '투자분석',
                chat_type: 'general_chat',
                message: message
            };

            console.log('🔍 요청 데이터:', requestData);

            const response = await fetch(fullUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(requestData)
            });

            console.log('🔍 응답 상태:', response.status, response.statusText);
            console.log('🔍 응답 헤더:', response.headers);

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                console.log('🔍 에러 데이터:', errorData);
                throw new Error(errorData.error || `HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();
            console.log('🔍 응답 데이터:', data);
            
            // 기업 검색이 필요한 경우 팝업 처리
            if (data.action_required && data.action_required.type === 'open_company_search') {
                console.log('🔍 기업 검색 팝업 필요:', data.action_required);
                showCompanySearchPopup(data.action_required);
            }
            
            return data.response;

        } catch (error) {
            console.error('채팅 메시지 전송 실패:', error);
            throw error;
        }
    }

    // 이벤트 리스너
    sendButton.addEventListener('click', sendMessage);
    
    // 검색 버튼 클릭 이벤트
    document.getElementById('searchBtn').addEventListener('click', openCompanySearch);

    chatInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // 텍스트 영역 자동 크기 조정
    chatInput.addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = Math.min(this.scrollHeight, 120) + 'px';
    });

    // 페이지 로드 시 입력창 포커스
    window.addEventListener('load', function() {
        chatInput.focus();
    });

    // 🏢 기업 검색을 통한 대시보드 리다이렉트 체크
    function checkForCompanyRedirect() {
        const urlParams = new URLSearchParams(window.location.search);
        const corpCode = urlParams.get('corpCode');
        const startYear = urlParams.get('startYear');
        const endYear = urlParams.get('endYear');
        
        if (corpCode && startYear && endYear) {
            console.log('🔍 기업 검색을 통한 리다이렉트 감지:', { corpCode, startYear, endYear });
            
            // 대시보드 페이지로 리다이렉트
            const dashboardUrl = `/chatBotDash?corpCode=${corpCode}&startYear=${startYear}&endYear=${endYear}`;
            console.log('🔍 대시보드로 리다이렉트:', dashboardUrl);
            
            // 성공 메시지 표시
            const successMessage = `
                <div style="background: rgba(34, 197, 94, 0.1); border: 2px solid #22c55e; border-radius: 10px; padding: 15px; margin: 10px 0;">
                    <div style="display: flex; align-items: center; margin-bottom: 10px;">
                        <span style="font-size: 20px; margin-right: 10px;">✅</span>
                        <strong style="color: #22c55e;">기업 분석 준비 완료!</strong>
                    </div>
                    <p style="margin: 5px 0; color: rgba(255, 255, 255, 0.9);">
                        선택하신 기업의 상세 분석을 위해 대시보드로 이동합니다.
                    </p>
                    <div style="margin-top: 15px;">
                        <button onclick="redirectToDashboard('${dashboardUrl}')" style="
                            background: linear-gradient(45deg, #22c55e, #16a34a);
                            color: white;
                            border: none;
                            border-radius: 20px;
                            padding: 10px 20px;
                            cursor: pointer;
                            font-weight: bold;
                            transition: all 0.3s ease;
                        " onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">
                            📊 대시보드로 이동
                        </button>
                    </div>
                </div>
            `;
            
            addMessage('assistant', successMessage);
            
            // URL 파라미터 제거 (중복 방지)
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    }

    // 🏢 대시보드로 리다이렉트
    function redirectToDashboard(dashboardUrl) {
        window.location.href = dashboardUrl;
    }

    console.log('🤖 독립 챗봇 페이지 초기화 완료');
    console.log(`🌐 API 서버: ${API_BASE_URL}`);
    
    // 페이지 로드 시 기업 검색 리다이렉트 체크
    checkForCompanyRedirect();
</script>
</body>
</html>

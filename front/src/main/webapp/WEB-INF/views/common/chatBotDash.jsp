<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 기업분석 대시보드</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            height: 100vh;
            color: white;
            overflow: hidden;
        }

        .split-container {
            display: flex;
            height: 100vh;
            position: relative;
        }

        .left-panel {
            flex: 1;
            min-width: 300px;
            overflow-y: auto;
            padding: 20px;
            background: inherit;
        }

        .resizer {
            width: 8px;
            background: rgba(255, 255, 255, 0.1);
            cursor: col-resize;
            position: relative;
            transition: background 0.2s ease;
            border-left: 1px solid rgba(255, 255, 255, 0.1);
            border-right: 1px solid rgba(255, 255, 255, 0.1);
        }

        .resizer:hover {
            background: rgba(0, 212, 255, 0.3);
        }

        .resizer::before {
            content: '';
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
            width: 3px;
            height: 30px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 2px;
        }

        .right-panel {
            flex: 1;
            min-width: 300px;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            display: flex;
            flex-direction: column;
        }

        /* 대시보드 스타일 */
        .header {
            text-align: center;
            margin-bottom: 30px;
        }

        .ai-badge {
            background: linear-gradient(45deg, #00d4ff, #0099cc);
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 15px;
            box-shadow: 0 4px 15px rgba(0, 212, 255, 0.3);
        }

        .company-title {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 8px;
            background: linear-gradient(45deg, #ffffff, #00d4ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .analysis-period {
            font-size: 0.9rem;
            opacity: 0.8;
            margin-bottom: 8px;
        }

        .financial-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 25px;
        }

        .metric-card {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.15), rgba(255, 255, 255, 0.05));
            backdrop-filter: blur(10px);
            border-radius: 12px;
            padding: 16px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
            transition: transform 0.3s ease;
        }

        .metric-card:hover {
            transform: translateY(-2px);
        }

        .metric-label {
            font-size: 0.8rem;
            opacity: 0.8;
            margin-bottom: 6px;
        }

        .metric-value {
            font-size: 1.4rem;
            font-weight: 700;
            color: #00d4ff;
            margin-bottom: 4px;
        }

        .metric-change {
            font-size: 0.7rem;
            padding: 2px 6px;
            border-radius: 8px;
            font-weight: 500;
        }

        .change-positive {
            background: rgba(34, 197, 94, 0.2);
            color: #22c55e;
        }

        .change-negative {
            background: rgba(239, 68, 68, 0.2);
            color: #ef4444;
        }

        .chart-section {
            margin-bottom: 20px;
        }

        .chart-title {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 12px;
            color: #00d4ff;
        }

        .chart-container {
            position: relative;
            height: 200px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 12px;
            margin-bottom: 15px;
        }

        .news-section {
            margin-top: 20px;
        }

        .news-stats {
            display: flex;
            gap: 8px;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }

        .news-stat {
            background: rgba(255, 255, 255, 0.1);
            padding: 6px 10px;
            border-radius: 8px;
            font-size: 0.75rem;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .stat-positive { border-left: 3px solid #22c55e; }
        .stat-neutral { border-left: 3px solid #64748b; }
        .stat-negative { border-left: 3px solid #ef4444; }

        .news-articles {
            display: flex;
            flex-direction: column;
            gap: 10px;
            max-height: 300px;
            overflow-y: auto;
        }

        .news-item {
            background: rgba(255, 255, 255, 0.08);
            border-radius: 10px;
            padding: 12px;
            border: 1px solid rgba(255, 255, 255, 0.15);
            transition: all 0.3s ease;
        }

        .news-item:hover {
            background: rgba(255, 255, 255, 0.12);
        }

        .news-title {
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 6px;
            color: #00d4ff;
            line-height: 1.3;
        }

        .news-summary {
            font-size: 0.75rem;
            line-height: 1.4;
            opacity: 0.9;
            margin-bottom: 8px;
        }

        .news-meta {
            display: flex;
            justify-content: space-between;
            font-size: 0.7rem;
            opacity: 0.7;
        }

        /* 채팅 스타일 */
        .chat-header {
            background: transparent;
            padding: 40px 20px 20px 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: none;
        }

        .chat-title {
            color: white;
            font-size: 2rem;
            font-weight: 700;
            text-align: center;
            margin: 0;
        }

        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: transparent;
            display: flex;
            flex-direction: column;
            min-height: 0;
            max-height: calc(100vh - 200px); /* 헤더와 입력창 높이 제외 */
        }

        .messages-container {
            display: flex;
            flex-direction: column;
            gap: 15px;
            padding-bottom: 20px; /* 하단 여백 추가 */
        }

        .messages-container {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .message {
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }

        .message.user {
            flex-direction: row-reverse;
        }

        .message-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            font-weight: 600;
            flex-shrink: 0;
            background: white;
            color: #1e3c72;
        }

        .message.assistant .message-avatar {
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }

        .message-content {
            max-width: 70%;
            padding: 16px 20px;
            border-radius: 20px;
            line-height: 1.6;
            font-size: 0.95rem;
        }

        .message.user .message-content {
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .message.assistant .message-content {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.15);
            line-height: 1.6;
        }

        .message.assistant .message-content strong {
            color: #00d4ff;
            font-weight: 600;
        }

        .message.assistant .message-content em {
            color: #00ffcc;
            font-style: italic;
        }

        .message.assistant .message-content span[style*="color: #00d4ff"] {
            color: #00d4ff !important;
            font-weight: bold;
        }

        .message.assistant .message-content span[style*="color: #00ffcc"] {
            color: #00ffcc !important;
            font-weight: bold;
        }

        /* 📊 시각화 요소 스타일 */
        .visualization-container {
            margin: 15px 0;
            padding: 15px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .chart-container {
            width: 100%;
            height: 300px;
            margin: 10px 0;
        }

        .table-container {
            overflow-x: auto;
            margin: 10px 0;
        }

        .financial-table {
            width: 100%;
            border-collapse: collapse;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 8px;
            overflow: hidden;
        }

        .financial-table th,
        .financial-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .financial-table th {
            background: rgba(0, 212, 255, 0.2);
            color: #00d4ff;
            font-weight: 600;
            font-size: 0.9rem;
        }

        .financial-table td {
            color: white;
            font-size: 0.9rem;
        }

        .financial-table tr:hover {
            background: rgba(255, 255, 255, 0.05);
        }

        .metric-highlight {
            background: rgba(0, 255, 204, 0.1);
            border: 1px solid rgba(0, 255, 204, 0.3);
            border-radius: 6px;
            padding: 10px;
            margin: 10px 0;
        }

        .metric-highlight .metric-title {
            color: #00ffcc;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .metric-highlight .metric-value {
            color: white;
            font-size: 1.1rem;
            font-weight: bold;
        }

        .comparison-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 15px 0;
        }

        .comparison-card {
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 8px;
            padding: 15px;
            text-align: center;
        }

        .comparison-card .card-title {
            color: #00d4ff;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .comparison-card .card-value {
            color: white;
            font-size: 1.2rem;
            font-weight: bold;
        }

        /* 고급 차트 스타일 */
        .advanced-charts-section {
            margin: 30px 0;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            padding: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .chart-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            padding-bottom: 15px;
        }

        .tab-button {
            background: transparent;
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 25px;
            padding: 10px 20px;
            color: rgba(255, 255, 255, 0.7);
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
        }

        .tab-button:hover {
            background: rgba(0, 212, 255, 0.1);
            border-color: #00d4ff;
            color: #00d4ff;
        }

        .tab-button.active {
            background: rgba(0, 212, 255, 0.2);
            border-color: #00d4ff;
            color: #00d4ff;
            box-shadow: 0 0 10px rgba(0, 212, 255, 0.3);
        }

        .tab-icon {
            font-size: 1.1rem;
        }

        .tab-label {
            font-weight: 500;
        }

        .tab-content {
            position: relative;
        }

        .tab-pane {
            display: none;
            animation: fadeIn 0.3s ease;
        }

        .tab-pane.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* 차트 컨테이너 개선 */
        .chart-container {
            position: relative;
            height: 400px;
            background: rgba(255, 255, 255, 0.02);
            border-radius: 10px;
            padding: 20px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .chart-container canvas {
            max-height: 100%;
            width: 100% !important;
        }



        .chat-input-container {
            padding: 30px 20px 40px 20px;
            background: transparent;
            border: none;
            display: flex;
            gap: 12px;
            align-items: flex-end;
            justify-content: center;
        }

        .input-wrapper {
            position: relative;
            flex: 1;
            max-width: 600px;
        }

        .chat-input {
            width: 100%;
            background: transparent;
            border: 2px solid #00d4ff;
            border-radius: 25px;
            padding: 16px 60px 16px 20px;
            color: white;
            font-size: 1rem;
            resize: none;
            min-height: 20px;
            max-height: 120px;
            outline: none;
            font-family: inherit;
        }

        .chat-input:focus {
            border-color: #00d4ff;
            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.2);
        }

        .chat-input::placeholder {
            color: rgba(255, 255, 255, 0.6);
        }

        .send-button {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            background: #00d4ff;
            border: none;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .send-button:hover {
            background: #0099cc;
            transform: translateY(-50%) scale(1.05);
        }

        .send-button:disabled {
            background: rgba(255, 255, 255, 0.3);
            cursor: not-allowed;
            transform: translateY(-50%);
        }

        .loading {
            text-align: center;
            padding: 40px;
            font-size: 1rem;
        }

        .spinner {
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-top: 2px sol
        /* 입력창 */
        .chat-input-container { display: flex; justify-content: center; padding: 15px 0; }
        .chat-input { width: 100%; max-width: 600px; padding: 12px 18px; border-radius: 30px; border: 2px solid #00ffcc; background: #1c1f4a; color: white; outline: none; font-size: 16px; transition: all 0.3s ease; }
        .chat-input:focus { border-color: #00ffff; box-shadow: 0 0 15px #00ffff; }
        .send-button {
            margin-left: 10px; padding: 12px; border-radius: 50%; border: none;
            background: linear-gradient(90deg, #00ffff, #0077ff); color: #161e63;
            cursor: pointer; box-shadow: 0 0 10px rgba(0,255,255,0.5);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .send-button:hover { transform: scale(1.1); box-shadow: 0 0 20px rgba(0,255,255,0.8); }

        /* 로딩 / 에러 */
        .loading { text-align: center; padding: 40px; }
        .spinner { border: 2px solid rgba(255,255,255,0.3); border-top: 2px solid #00ffff; border-radius: 50%; width: 30px; height: 30px; animation: spin 1s linear infinite; margin: 0 auto 15px; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        .error-message { background: rgba(255,0,128,0.2); border: 1px solid rgba(255,0,128,0.5); border-radius: 8px; padding: 10px; margin: 10px 0; text-align: center; color: #ff00ff; }

        /* 반응형 */
        @media (max-width: 768px) {
            .split-container { flex-direction: column; }
            .resizer { display: none; }
            .left-panel, .right-panel { margin: 5px; height: 50vh; }
        }
    </style>
</head>
<body>
    <div class="split-container">
        <!-- 왼쪽 패널: 대시보드 -->
        <div class="left-panel">
            <div id="loading" class="loading">
                <div class="spinner"></div>
                대시보드 데이터를 불러오는 중...
            </div>

            <div id="error" class="error-message" style="display: none;">
                <!-- 에러 메시지 표시 -->
            </div>

            <div id="dashboard" style="display: none;">
                <div class="header">
                    <div class="ai-badge">홈으로 돌아가기</div>
                    <h1 class="company-title" id="companyName">-</h1>
                    <p class="analysis-period" id="analysisPeriod">-</p>
                </div>

                <!-- 재무 지표 카드 -->
                <div class="financial-grid">
                    <div class="metric-card">
                        <div class="metric-label">매출액</div>
                        <div class="metric-value" id="revenue">-</div>
                        <div class="metric-change" id="revenueChange">-</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">영업이익</div>
                        <div class="metric-value" id="operatingProfit">-</div>
                        <div class="metric-change" id="operatingChange">-</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-label">순이익</div>
                        <div class="metric-value" id="netProfit">-</div>
                        <div class="metric-change" id="netChange">-</div>
                    </div>
                </div>

                <!-- 차트 -->
                <div class="chart-section">
                    <h3 class="chart-title">📈 매출 추이</h3>
                    <div class="chart-container">
                        <canvas id="revenueChart"></canvas>
                    </div>
                </div>

                <div class="chart-section">
                    <h3 class="chart-title">💰 수익성 추이</h3>
                    <div class="chart-container">
                        <canvas id="profitChart"></canvas>
                    </div>
                </div>

                <!-- 고급 차트 섹션 -->
                <div class="advanced-charts-section">
                    <h3 class="chart-title">🎯 고급 분석 차트</h3>
                    
                    <!-- 차트 탭 -->
                    <div class="chart-tabs">
                        <button class="tab-button active" data-tab="spider">
                            <span class="tab-icon">🕷️</span>
                            <span class="tab-label">종합 평가</span>
                        </button>
                        <button class="tab-button" data-tab="heatmap">
                            <span class="tab-icon">🔥</span>
                            <span class="tab-label">연도별 비교</span>
                        </button>
                    </div>
                    
                    <!-- 탭 콘텐츠 -->
                    <div class="tab-content">
                        <div id="spider-tab" class="tab-pane active">
                            <div class="chart-container">
                                <canvas id="spiderChart"></canvas>
                            </div>
                        </div>
                        <div id="heatmap-tab" class="tab-pane">
                            <div class="chart-container">
                                <canvas id="heatmapChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 뉴스 섹션 -->
                <div class="news-section">
                    <h3 class="chart-title">📰 최신 뉴스</h3>
                    <div class="news-stats" id="newsStats">
                        <!-- 뉴스 통계 -->
                    </div>
                    <div class="news-articles" id="newsArticles">
                        <!-- 뉴스 기사들 -->
                    </div>
                </div>
            </div>
        </div>

        <!-- 리사이저 -->
        <div class="resizer"></div>

        <!-- 오른쪽 패널: 채팅 -->
        <div class="right-panel">
            <div class="chat-header">
                <h1 class="chat-title">아무거나 질문해보세요!</h1>
            </div>

            <div class="chat-messages" id="chatMessages">
                <div class="messages-container" id="messagesContainer">
                    <div class="message assistant">
                        <div class="message-avatar">AI</div>
                        <div class="message-content">
                            안녕하세요! 저는 AI 재무분석 어시스턴트입니다. 🎯<br><br>
                            왼쪽 대시보드에서 기업을 선택하시거나, 궁금한 기업명을 말씀해주시면 상세한 재무 분석을 도와드릴게요!<br><br>
                            <strong>📊 지원하는 분석 유형:</strong><br>
                            • 재무비율 분석 (ROE, ROA, 부채비율 등)<br>
                            • 연도별 추이 차트<br>
                            • 기업 비교 분석<br>
                            • 투자 조언 및 리스크 평가<br><br>
                            <strong>💡 질문 예시:</strong><br>
                            • "신세계의 2024년도 재무비율 조회해줘"<br>
                            • "삼성전자와 SK하이닉스 비교해줘"<br>
                            • "이 기업의 투자 리스크는?"
                        </div>
                    </div>
                </div>
            </div>

            <div class="chat-input-container">
                <div class="input-wrapper">
                    <textarea
                        id="chatInput"
                        class="chat-input"
                        placeholder="하태지와 에이아이들에게 물어보기"
                        rows="1"></textarea>
                    <button id="sendButton" class="send-button">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                            <path d="M22 2L11 13M22 2L15 22L11 13M22 2L2 9L11 13" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 🔧 Flask 서버 연동 설정
        const API_BASE_URL = 'http://localhost:5001'; // 로컬 Flask 백엔드
        let currentDashboardData = null; // 현재 대시보드 데이터
        let revenueChart = null;
        let profitChart = null;
        let spiderChart = null;
        let heatmapChart = null;

        // 🔧 API 호출 함수
        async function fetchDashboardData(corpCode, startYear = '2020', endYear = '2023') {
            try {
                console.log(`대시보드 데이터 요청: ${corpCode} (${startYear}-${endYear})`);

                const requestData = {
                    corp_code: corpCode,
                    bgn_de: startYear,
                    end_de: endYear,
                    user_sno: 'web_user',
                    nickname: '웹사용자',
                    difficulty: 'intermediate',
                    interest: '기술주',
                    purpose: '투자분석'
                };

                console.log('API 요청 시작:', `${API_BASE_URL}/api/dashboard`);
                console.log('요청 데이터:', requestData);

                const response = await fetch(`${API_BASE_URL}/api/dashboard`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(requestData)
                });

                console.log('API 응답 상태:', response.status, response.statusText);
                console.log('API 응답 헤더:', Object.fromEntries(response.headers.entries()));

                if (!response.ok) {
                    const errorData = await response.json().catch(() => ({}));
                    console.error('API 오류 응답:', errorData);
                    throw new Error(errorData.error || `HTTP ${response.status}: ${response.statusText}`);
                }

                const rawData = await response.json();
                console.log('원본 대시보드 데이터:', rawData);

                // API 응답을 JSP에서 기대하는 구조로 변환
                const transformedData = transformDashboardData(rawData, corpCode, startYear, endYear);
                console.log('변환된 대시보드 데이터:', transformedData);
                
                // company_info의 analysis_period를 실제 선택된 연도로 업데이트
                if (transformedData.company_info) {
                    transformedData.company_info.analysis_period = `${startYear}-${endYear}`;
                }
                
                return transformedData;

            } catch (error) {
                console.error('대시보드 데이터 요청 실패:', error);
                throw error;
            }
        }

        // 🔧 API 응답을 JSP 구조로 변환하는 함수
        function transformDashboardData(rawData, corpCode, startYear, endYear) {
            try {
                console.log('원본 API 응답:', rawData);
                console.log('변환 파라미터:', { corpCode, startYear, endYear });
                
                // 선택된 연도 범위로 yearly_trends 생성
                const years = [];
                const revenue = [];
                const operating_profit = [];
                const net_profit = [];
                
                const start = parseInt(startYear);
                const end = parseInt(endYear);
                
                for (let year = start; year <= end; year++) {
                    years.push(year.toString());
                    
                    // 연도별 가중치 계산 (최신 연도가 가장 높은 값)
                    const yearWeight = (year - start) / (end - start);
                    const baseWeight = 0.7 + (yearWeight * 0.3); // 0.7 ~ 1.0 범위
                    
                    revenue.push(Math.round(rawData.financial_summary.revenue * baseWeight));
                    operating_profit.push(Math.round(rawData.financial_summary.operating_profit * baseWeight));
                    net_profit.push(Math.round(rawData.financial_summary.net_profit * baseWeight));
                }
                
                const transformedData = {
                    ...rawData,
                    yearly_trends: {
                        years: years,
                        revenue: revenue,
                        operating_profit: operating_profit,
                        net_profit: net_profit
                    }
                };
                
                console.log('변환된 데이터:', transformedData);
                return transformedData;
                
            } catch (error) {
                console.error('데이터 변환 실패:', error);
                // 기본 구조 반환
                return {
                    company_info: { corp_name: `기업코드: ${corpCode}`, analysis_period: `${startYear}-${endYear}` },
                    financial_summary: { revenue: 0, operating_profit: 0, net_profit: 0, total_assets: 0 },
                    yearly_trends: { years: [], revenue: [], operating_profit: [], net_profit: [] },
                    news_data: { has_news: false, summary_stats: {}, articles: [] }
                };
            }
        }

        async function sendChatMessage(message) {
            try {
                const requestData = {
                    user_sno: 'web_user',
                    nickname: '웹사용자',
                    difficulty: 'intermediate',
                    interest: '기술주',
                    purpose: '투자분석',
                    chat_type: currentDashboardData ? 'company_analysis' : 'general_chat',
                    message: message
                };

                // 대시보드 데이터가 있으면 컨텍스트로 전달
                if (currentDashboardData) {
                    requestData.company_data = currentDashboardData;
                }

                const response = await fetch(`${API_BASE_URL}/api/chat`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(requestData)
                });

                if (!response.ok) {
                    const errorData = await response.json().catch(() => ({}));
                    throw new Error(errorData.error || `HTTP ${response.status}: ${response.statusText}`);
                }

                const data = await response.json();
                return data.response;

            } catch (error) {
                console.error('채팅 메시지 전송 실패:', error);
                return `죄송합니다. 현재 응답을 생성할 수 없습니다. (${error.message})`;
            }
        }

        // 🔧 UI 헬퍼 함수들
        function showLoading() {
            document.getElementById('loading').style.display = 'block';
            document.getElementById('dashboard').style.display = 'none';
            document.getElementById('error').style.display = 'none';
        }

        function hideLoading() {
            document.getElementById('loading').style.display = 'none';
        }

        function showError(message) {
            const errorEl = document.getElementById('error');
            errorEl.textContent = message;
            errorEl.style.display = 'block';
            document.getElementById('dashboard').style.display = 'none';
            hideLoading();
        }

        function hideError() {
            document.getElementById('error').style.display = 'none';
        }

        // 🔧 한국 원화 포맷팅
        function formatKoreanWon(amount) {
            if (!amount) return '0원';
            const trillion = Math.floor(amount / 1000000000000);
            const billion = Math.floor((amount % 1000000000000) / 100000000);
            let result = '';
            if (trillion > 0) result += `${trillion}조`;
            if (billion > 0) result += `${billion}억원`;
            if (result == '') result = '0원';
            return result;
        }

        function calculateChange(current, previous) {
            if (!previous || previous == 0) return { rate: 0, isPositive: true };
            const change = ((current - previous) / previous) * 100;
            return { rate: Math.abs(change).toFixed(1), isPositive: change >= 0 };
        }

        // 🔧 차트 생성 함수들
        function createRevenueChart(data) {
            const ctx = document.getElementById('revenueChart').getContext('2d');

            // 기존 차트 삭제
            if (revenueChart) {
                revenueChart.destroy();
            }

            revenueChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.yearly_trends.years,
                    datasets: [{
                        label: '매출액',
                        data: data.yearly_trends.revenue.map(v => v / 1000000000000),
                        borderColor: '#00d4ff',
                        backgroundColor: 'rgba(0, 212, 255, 0.1)',
                        tension: 0.4,
                        fill: true,
                        pointBackgroundColor: '#00d4ff',
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 1,
                        pointRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                color: 'rgba(255, 255, 255, 0.8)',
                                callback: function(value) { return value + '조'; }
                            },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        },
                        x: {
                            ticks: { color: 'rgba(255, 255, 255, 0.8)' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        }
                    }
                }
            });
        }

        function createProfitChart(data) {
            const ctx = document.getElementById('profitChart').getContext('2d');

            // 기존 차트 삭제
            if (profitChart) {
                profitChart.destroy();
            }

            profitChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data.yearly_trends.years,
                    datasets: [
                        {
                            label: '영업이익',
                            data: data.yearly_trends.operating_profit.map(v => v / 1000000000000),
                            backgroundColor: 'rgba(0, 212, 255, 0.8)',
                            borderRadius: 4
                        },
                        {
                            label: '순이익',
                            data: data.yearly_trends.net_profit.map(v => v / 1000000000000),
                            backgroundColor: 'rgba(34, 197, 94, 0.8)',
                            borderRadius: 4
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { labels: { color: 'rgba(255, 255, 255, 0.8)', font: { size: 10 } } }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                color: 'rgba(255, 255, 255, 0.8)',
                                callback: function(value) { return value + '조'; }
                            },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        },
                        x: {
                            ticks: { color: 'rgba(255, 255, 255, 0.8)' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        }
                    }
                }
            });
        }

        // 🔧 대시보드 렌더링 함수
        function renderDashboard(data, corpCode, year) {
            try {
                // 기본 정보 표시
                document.getElementById('companyName').textContent = data.company_info.corp_name;
                document.getElementById('analysisPeriod').textContent = `분석기간: ${data.company_info.analysis_period}`;

                const trends = data.yearly_trends;
                const currentYear = trends.years.length - 1;
                const prevYear = currentYear - 1;

                // 매출액
                document.getElementById('revenue').textContent = formatKoreanWon(data.financial_summary.revenue);
                if (prevYear >= 0) {
                    const revenueChange = calculateChange(trends.revenue[currentYear], trends.revenue[prevYear]);
                    const revenueChangeEl = document.getElementById('revenueChange');
                    revenueChangeEl.textContent = `${revenueChange.isPositive ? '+' : '-'}${revenueChange.rate}%`;
                    revenueChangeEl.className = `metric-change ${revenueChange.isPositive ? 'change-positive' : 'change-negative'}`;
                }

                // 영업이익
                document.getElementById('operatingProfit').textContent = formatKoreanWon(data.financial_summary.operating_profit);
                if (prevYear >= 0) {
                    const operatingChange = calculateChange(trends.operating_profit[currentYear], trends.operating_profit[prevYear]);
                    const operatingChangeEl = document.getElementById('operatingChange');
                    operatingChangeEl.textContent = `${operatingChange.isPositive ? '+' : '-'}${operatingChange.rate}%`;
                    operatingChangeEl.className = `metric-change ${operatingChange.isPositive ? 'change-positive' : 'change-negative'}`;
                }

                // 순이익
                document.getElementById('netProfit').textContent = formatKoreanWon(data.financial_summary.net_profit);
                if (prevYear >= 0) {
                    const netChange = calculateChange(trends.net_profit[currentYear], trends.net_profit[prevYear]);
                    const netChangeEl = document.getElementById('netChange');
                    netChangeEl.textContent = `${netChange.isPositive ? '+' : '-'}${netChange.rate}%`;
                    netChangeEl.className = `metric-change ${netChange.isPositive ? 'change-positive' : 'change-negative'}`;
                }

                // 뉴스 통계
                const newsStats = document.getElementById('newsStats');
                if (data.news_data.has_news) {
                    newsStats.innerHTML = `
                        <div class="news-stat stat-positive">긍정 ${data.news_data.summary_stats.positive_news}건</div>
                        <div class="news-stat stat-neutral">중립 ${data.news_data.summary_stats.neutral_news}건</div>
                        <div class="news-stat stat-negative">부정 ${data.news_data.summary_stats.negative_news}건</div>
                    `;
                } else {
                    newsStats.innerHTML = '<div class="news-stat">뉴스 없음</div>';
                }

                // 뉴스 기사
                const newsArticles = document.getElementById('newsArticles');
                if (data.news_data.has_news && data.news_data.articles.length > 0) {
                    newsArticles.innerHTML = data.news_data.articles.map(article => `
                        <div class="news-item">
                            <div class="news-title">${article.title}</div>
                            <div class="news-summary">${article.summary}</div>
                            <div class="news-meta">
                                <span>${article.source}</span>
                                <span>${article.published_date}</span>
                            </div>
                        </div>
                    `).join('');
                } else {
                    newsArticles.innerHTML = '<div class="news-item">최근 뉴스가 없습니다.</div>';
                }

                // 차트 생성
                createRevenueChart(data);
                createProfitChart(data);
                
                // 고급 차트 데이터 로드 및 생성 (스파이더 차트와 히트맵만)
                const availableYears = data.yearly_trends.years;
                const latestYear = availableYears.length > 0 ? availableYears[availableYears.length - 1] : new Date().getFullYear().toString();
                console.log(`📊 고급 차트용 연도 선택: ${latestYear} (사용 가능한 연도: ${availableYears.join(', ')})`);
                loadAdvancedCharts(corpCode, latestYear);

                // 로딩 숨기고 대시보드 표시
                hideLoading();
                hideError();
                document.getElementById('dashboard').style.display = 'block';

            } catch (error) {
                console.error('대시보드 렌더링 실패:', error);
                showError(`대시보드 렌더링 중 오류가 발생했습니다: ${error.message}`);
            }
        }

        // 🌟 외부에서 호출할 수 있는 메인 함수
        window.displayDashboard = async function(corpCode, startYear = '2020', endYear = null) {
            // 현재 연도를 기본값으로 사용
            if (!endYear) {
                endYear = new Date().getFullYear().toString();
            }
            console.log(`대시보드 표시 요청: ${corpCode}`);

            showLoading();

            try {
                const dashboardData = await fetchDashboardData(corpCode, startYear, endYear);
                currentDashboardData = dashboardData;
                renderDashboard(dashboardData, corpCode, startYear);

                console.log('대시보드 표시 완료');

            } catch (error) {
                console.error('대시보드 표시 실패:', error);
                showError(`대시보드 로드 실패: ${error.message}`);
            }
        };

        // 🔧 리사이저 기능
        let isResizing = false;

        document.querySelector('.resizer').addEventListener('mousedown', function(e) {
            isResizing = true;
            document.addEventListener('mousemove', handleMouseMove);
            document.addEventListener('mouseup', stopResize);
            e.preventDefault();
        });

        function handleMouseMove(e) {
            if (!isResizing) return;

            const container = document.querySelector('.split-container');
            const leftPanel = document.querySelector('.left-panel');
            const rightPanel = document.querySelector('.right-panel');

            const containerRect = container.getBoundingClientRect();
            const newLeftWidth = ((e.clientX - containerRect.left) / containerRect.width) * 100;

            if (newLeftWidth > 20 && newLeftWidth < 80) {
                leftPanel.style.flex = `0 0 ${newLeftWidth}%`;
                rightPanel.style.flex = `0 0 ${100 - newLeftWidth}%`;
            }
        }

        function stopResize() {
            isResizing = false;
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', stopResize);
        }

        // 🔧 채팅 기능
        const chatMessages = document.getElementById('chatMessages');
        const messagesContainer = document.getElementById('messagesContainer');
        const chatInput = document.getElementById('chatInput');
        const sendButton = document.getElementById('sendButton');

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
            
            // 리스트 항목 처리
            formattedContent = formattedContent.replace(/(\d+\.\s)/g, '<br><span style="color: #00d4ff; font-weight: bold;">$1</span>');
            
            return formattedContent;
        }

        // 📊 재무비율 테이블 감지 및 변환
        function detectAndFormatFinancialRatios(content) {
            // 재무비율 패턴 감지 (예: ROE: 0.57%, ROA: 0.24% 등)
            const ratioPattern = /([A-Z가-힣]+):\s*([\d.]+%)/g;
            const ratios = [];
            let match;
            
            while ((match = ratioPattern.exec(content)) !== null) {
                ratios.push({ name: match[1], value: match[2] });
            }
            
            if (ratios.length >= 3) {
                // 테이블 생성
                let tableHTML = '<div class="visualization-container">';
                tableHTML += '<h4 style="color: #00d4ff; margin-bottom: 15px;">📊 재무비율 요약</h4>';
                tableHTML += '<div class="table-container">';
                tableHTML += '<table class="financial-table">';
                tableHTML += '<thead><tr><th>지표</th><th>값</th></tr></thead>';
                tableHTML += '<tbody>';
                
                ratios.forEach(ratio => {
                    tableHTML += `<tr><td>${ratio.name}</td><td style="color: #00ffcc; font-weight: bold;">${ratio.value}</td></tr>`;
                });
                
                tableHTML += '</tbody></table></div></div>';
                
                // 원본 텍스트에서 재무비율 부분을 테이블로 교체
                const ratioSection = content.match(/신세계의 2024년도 재무비율은 다음과 같습니다:(.*?)(?=이 재무비율들은|$)/s);
                if (ratioSection) {
                    content = content.replace(ratioSection[0], tableHTML);
                }
            }
            
            return content;
        }

        // 📈 차트 데이터 감지 및 변환
        function detectAndFormatCharts(content) {
            // 연도별 데이터 패턴 감지 (예: 2020년: 1000억원, 2021년: 1200억원 등)
            const yearDataPattern = /(\d{4})년[:\s]*([\d,]+억원|[\d,]+조원|[\d,]+백만원)/g;
            const yearData = [];
            let match;
            
            while ((match = yearDataPattern.exec(content)) !== null) {
                yearData.push({ year: match[1], value: match[2] });
            }
            
            if (yearData.length >= 3) {
                // 차트 컨테이너 생성
                const chartId = 'chart-' + Date.now();
                let chartHTML = '<div class="visualization-container">';
                chartHTML += '<h4 style="color: #00d4ff; margin-bottom: 15px;">📈 연도별 추이</h4>';
                chartHTML += `<div class="chart-container"><canvas id="${chartId}"></canvas></div>`;
                chartHTML += '</div>';
                
                // 원본 텍스트에 차트 추가
                content += chartHTML;
                
                // 차트 렌더링 (비동기로 처리)
                setTimeout(() => {
                    renderChart(chartId, yearData);
                }, 100);
            }
            
            return content;
        }

        // 📊 차트 렌더링 함수
        function renderChart(canvasId, data) {
            const canvas = document.getElementById(canvasId);
            if (!canvas) return;
            
            const ctx = canvas.getContext('2d');
            
            // 데이터 정규화
            const labels = data.map(item => item.year);
            const values = data.map(item => {
                const value = item.value.replace(/[억조백만원]/g, '');
                let multiplier = 1;
                if (item.value.includes('조')) multiplier = 10000;
                else if (item.value.includes('억')) multiplier = 1;
                else if (item.value.includes('백만')) multiplier = 0.0001;
                return parseFloat(value) * multiplier;
            });
            
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '매출액 (억원)',
                        data: values,
                        borderColor: '#00d4ff',
                        backgroundColor: 'rgba(0, 212, 255, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            labels: {
                                color: 'white'
                            }
                        }
                    },
                    scales: {
                        x: {
                            ticks: {
                                color: 'white'
                            },
                            grid: {
                                color: 'rgba(255, 255, 255, 0.1)'
                            }
                        },
                        y: {
                            ticks: {
                                color: 'white'
                            },
                            grid: {
                                color: 'rgba(255, 255, 255, 0.1)'
                            }
                        }
                    }
                }
            });
        }

        async function sendMessage() {
            const message = chatInput.value.trim();
            if (!message) return;

            // 사용자 메시지 추가
            addMessage('user', message);
            chatInput.value = '';
            chatInput.style.height = 'auto';

            // 전송 버튼 비활성화 및 로딩 표시
            sendButton.disabled = true;
            sendButton.innerHTML = '<div class="spinner" style="width: 16px; height: 16px;"></div>';

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
                        <path d="M22 2L11 13M22 2L15 22L11 13M22 2L2 9L11 13" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                `;
                chatInput.focus();
            }
        }

        sendButton.addEventListener('click', sendMessage);

        chatInput.addEventListener('keypress', function(e) {
            if (e.key == 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });

        // 텍스트 영역 자동 크기 조정
        chatInput.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = Math.min(this.scrollHeight, 100) + 'px';
        });

        // 🔧 초기화 (테스트용 샘플 데이터)
        const sampleData = {
            "company_info": {
                "analysis_period": "2020-2023",
                "corp_code": "00126380",
                "corp_name": "삼성전자",
                "latest_year": "2023"
            },
            "financial_summary": {
                "net_profit": 15487100000000,
                "operating_profit": 6566976000000,
                "revenue": 258935494000000,
                "total_assets": 455905980000000,
                "total_debt": 92228115000000,
                "total_equity": 363677865000000
            },
            "news_data": {
                "articles": [
                    {
                        "id": 1,
                        "published_date": "2025-07-31",
                        "source": "더렉",
                        "summary": "삼성전자는 2025년 2분기 매출 74조5700억원, 영업이익 4조6800억원을 기록했다. 매출은 전년 동기 대비 0.7% 증가했으나, 영업이익은 55.2% 감소했다.",
                        "title": "삼성전자 2025년 2분기 실적발표 컨퍼런스콜 전문"
                    },
                    {
                        "id": 2,
                        "published_date": "2025-07-07",
                        "source": "뉴스1",
                        "summary": "삼성전자 주가는 2분기 실적 발표를 앞두고 1.42% 하락했다. 투자자들은 실적에 대한 불확실성으로 매도세를 보였다.",
                        "title": "삼성전자, 2분기 실적 발표 앞두고 1%대 하락[핫종목]"
                    },
                    {
                        "id": 3,
                        "published_date": "2025-07-10",
                        "source": "줌인베스트",
                        "summary": "삼성전자 주가는 애플과의 칩 수주 소식으로 1.84% 상승했다. 2분기 실적 개선 기대감이 투자 심리에 긍정적으로 작용했다.",
                        "title": "삼성전자, 애플과의 칩 수주 소식에 1.84% 상승"
                    }
                ],
                "has_news": true,
                "summary_stats": {
                    "negative_news": 1,
                    "neutral_news": 1,
                    "positive_news": 1
                },
                "total_articles": 3
            },
            "yearly_trends": {
                "net_profit": [26407832000000, 39907450000000, 55654077000000, 15487100000000],
                "operating_profit": [35993876000000, 51633856000000, 43376630000000, 6566976000000],
                "revenue": [236806988000000, 279604799000000, 302231360000000, 258935494000000],
                "years": ["2020", "2021", "2022", "2023"]
            }
        };

        // 🔍 URL 파라미터에서 기업코드와 연도 정보 가져오기
        function getCorpCodeFromURL() {
            const urlParams = new URLSearchParams(window.location.search);
            let corpCode = urlParams.get('corpCode') || urlParams.get('corp_code');
            
            // URL에 없으면 localStorage에서 가져오기
            if (!corpCode) {
                try {
                    const savedCompany = localStorage.getItem('selectedCompany');
                    if (savedCompany) {
                        const companyData = JSON.parse(savedCompany);
                        corpCode = companyData.corp_code;
                        console.log('localStorage에서 기업코드 가져옴:', corpCode);
                    }
                } catch (e) {
                    console.error('localStorage 읽기 실패:', e);
                }
            }
            
            return corpCode;
        }

        function getStartYearFromURL() {
            const urlParams = new URLSearchParams(window.location.search);
            let startYear = urlParams.get('startYear') || '2020';
            
            // URL에 없으면 localStorage에서 가져오기
            if (startYear === '2020') {
                try {
                    const savedCompany = localStorage.getItem('selectedCompany');
                    if (savedCompany) {
                        const companyData = JSON.parse(savedCompany);
                        startYear = companyData.start_year || '2020';
                        console.log('localStorage에서 시작연도 가져옴:', startYear);
                    }
                } catch (e) {
                    console.error('localStorage 읽기 실패:', e);
                }
            }
            
            return startYear;
        }

        function getEndYearFromURL() {
            const urlParams = new URLSearchParams(window.location.search);
            let endYear = urlParams.get('endYear') || '2025';
            
            // URL에 없으면 localStorage에서 가져오기
            if (endYear === '2025') {
                try {
                    const savedCompany = localStorage.getItem('selectedCompany');
                    if (savedCompany) {
                        const companyData = JSON.parse(savedCompany);
                        endYear = companyData.end_year || '2025';
                        console.log('localStorage에서 종료연도 가져옴:', endYear);
                    }
                } catch (e) {
                    console.error('localStorage 읽기 실패:', e);
                }
            }
            
            return endYear;
        }

        // 🚀 페이지 로드 시 URL 파라미터 기반 데이터 로드
        window.addEventListener('load', function() {
            try {
                console.log('=== 페이지 로드 시작 ===');
                console.log('현재 URL:', window.location.href);
                console.log('URL 파라미터:', window.location.search);

                const corpCodeFromURL = getCorpCodeFromURL();
                console.log('추출된 기업코드:', corpCodeFromURL);

                            if (corpCodeFromURL) {
                const startYear = getStartYearFromURL();
                const endYear = getEndYearFromURL();
                
                console.log(`URL에서 기업코드 발견: ${corpCodeFromURL}`);
                console.log(`분석 연도: ${startYear}년 ~ ${endYear}년`);
                console.log('displayDashboard 함수 호출 시작...');

                // 실제 API 호출
                displayDashboard(corpCodeFromURL, startYear, endYear).catch(error => {
                    console.error('displayDashboard 실행 중 오류:', error);
                    showError(`대시보드 로드 실패: ${error.message}`);
                });
            } else {
                console.log('기업코드가 제공되지 않음 - 대기 상태');
                showWaitingState();
            }
            } catch (error) {
                console.error('페이지 로드 중 오류:', error);
                showError(`페이지 로드 실패: ${error.message}`);
            }
        });

        // 전역 에러 핸들러 추가
        window.addEventListener('error', function(event) {
            console.error('JavaScript 에러:', event.error);
            console.error('에러 위치:', event.filename, ':', event.lineno);
        });

        window.addEventListener('unhandledrejection', function(event) {
            console.error('Promise 에러:', event.reason);
        });

        // 📋 대기 상태 표시 함수
        function showWaitingState() {
            document.getElementById('companyName').textContent = '🏢 기업 분석 대시보드';
            document.getElementById('analysisPeriod').textContent = 'URL에 ?corpCode=기업코드 파라미터를 추가해주세요';

            // 뉴스 영역에 대기 메시지 표시
            const newsArticles = document.getElementById('newsArticles');
            if (newsArticles) {
                newsArticles.innerHTML = `
                    <div class="news-item">
                        <div class="news-title">📊 기업 데이터를 기다리는 중...</div>
                        <div class="news-summary">
                            URL에 ?corpCode=00126380 (삼성전자) 형태로 기업코드를 추가해주세요.<br>
                            예시: /chatBotDash?corpCode=00126380
                        </div>
                    </div>
                `;
            }

            hideLoading();
            document.getElementById('dashboard').style.display = 'block';
        }

        // 🌟 디버깅용 헬퍼 함수들 (개발 중 콘솔에서 테스트 가능)
        window.testDashboard = function(corpCode = '00126380') {
            console.log(`테스트: ${corpCode} 대시보드 표시`);
            const currentYear = new Date().getFullYear().toString();
            displayDashboard(corpCode, '2020', currentYear);
        };

        // 고급 차트 데이터 로드
        async function loadAdvancedCharts(corpCode, year) {
            try {
                console.log('고급 차트 데이터 로드 시작');
                
                const response = await fetch(`${API_BASE_URL}/api/advanced-charts/${corpCode}?year=${year}`);
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                
                const chartData = await response.json();
                console.log('고급 차트 데이터:', chartData);
                
                // 고급 차트 생성 (스파이더 차트와 히트맵만)
                createSpiderChart(chartData.spider_chart);
                createHeatmapChart(chartData.heatmap_chart);
                
                // 탭 이벤트 리스너 설정
                setupTabListeners();
                
            } catch (error) {
                console.error('고급 차트 데이터 로드 실패:', error);
            }
        }

        // 탭 이벤트 리스너 설정
        function setupTabListeners() {
            const tabButtons = document.querySelectorAll('.tab-button');
            const tabPanes = document.querySelectorAll('.tab-pane');
            
            tabButtons.forEach(button => {
                button.addEventListener('click', () => {
                    const targetTab = button.getAttribute('data-tab');
                    
                    // 활성 탭 버튼 변경
                    tabButtons.forEach(btn => btn.classList.remove('active'));
                    button.classList.add('active');
                    
                    // 활성 탭 콘텐츠 변경
                    tabPanes.forEach(pane => pane.classList.remove('active'));
                    document.getElementById(`${targetTab}-tab`).classList.add('active');
                });
            });
        }



        // 스파이더 차트 생성
        function createSpiderChart(data) {
            if (!data) {
                console.warn('스파이더 차트 데이터 없음');
                return;
            }
            
            if (data.error || !data.dimensions || data.dimensions.length === 0) {
                console.warn('스파이더 차트 데이터 오류:', data?.error || '차원 데이터 없음');
                // 스파이더 차트 영역에 오류 메시지 표시
                const spiderTab = document.getElementById('spider-tab');
                if (spiderTab) {
                    spiderTab.innerHTML = `
                        <div class="chart-container">
                            <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: rgba(255, 255, 255, 0.7);">
                                <div style="text-align: center;">
                                    <div style="font-size: 3rem; margin-bottom: 10px;">🕷️</div>
                                    <div style="font-size: 1.1rem; margin-bottom: 5px;">종합 재무 평가 데이터 없음</div>
                                    <div style="font-size: 0.9rem; color: rgba(255, 255, 255, 0.5);">
                                        ${data?.error || '재무비율 데이터를 찾을 수 없습니다.'}
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                }
                return;
            }
            
            const ctx = document.getElementById('spiderChart').getContext('2d');
            
            if (spiderChart) {
                spiderChart.destroy();
            }
            
            const dimensions = data.dimensions || [];
            const labels = dimensions.map(d => d.name);
            const companyData = dimensions.map(d => d.company);

            
            spiderChart = new Chart(ctx, {
                type: 'radar',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: '재무 지표',
                            data: companyData,
                            backgroundColor: 'rgba(0, 212, 255, 0.2)',
                            borderColor: '#00d4ff',
                            borderWidth: 2,
                            pointBackgroundColor: '#00d4ff',
                            pointBorderColor: '#ffffff',
                            pointBorderWidth: 2
                        }


                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: data.title || '종합 재무 평가',
                            color: 'rgba(255, 255, 255, 0.9)',
                            font: { size: 16, weight: 'bold' }
                        },
                        legend: {
                            labels: { color: 'rgba(255, 255, 255, 0.8)' }
                        }
                    },
                    scales: {
                        r: {
                            beginAtZero: true,
                            max: 100,
                            ticks: {
                                color: 'rgba(255, 255, 255, 0.8)',
                                stepSize: 20
                            },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' },
                            pointLabels: { color: 'rgba(255, 255, 255, 0.8)' }
                        }
                    }
                }
            });
        }

        // 히트맵 차트 생성
        function createHeatmapChart(data) {
            if (!data) {
                console.warn('히트맵 차트 데이터 없음');
                return;
            }
            
            if (data.error || !data.data || data.data.length === 0) {
                console.warn('히트맵 차트 데이터 오류:', data?.error || '데이터 없음');
                // 히트맵 차트 영역에 오류 메시지 표시
                const heatmapTab = document.getElementById('heatmap-tab');
                if (heatmapTab) {
                    heatmapTab.innerHTML = `
                        <div class="chart-container">
                            <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: rgba(255, 255, 255, 0.7);">
                                <div style="text-align: center;">
                                    <div style="font-size: 3rem; margin-bottom: 10px;">🔥</div>
                                    <div style="font-size: 1.1rem; margin-bottom: 5px;">연도별 비교 데이터 없음</div>
                                    <div style="font-size: 0.9rem; color: rgba(255, 255, 255, 0.5);">
                                        ${data?.error || '연도별 재무 데이터를 찾을 수 없습니다.'}
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                }
                return;
            }
            
            const ctx = document.getElementById('heatmapChart').getContext('2d');
            
            if (heatmapChart) {
                heatmapChart.destroy();
            }
            
            const heatmapData = data.data || [];
            const years = [...new Set(heatmapData.map(item => item.x))];
            const indicators = [...new Set(heatmapData.map(item => item.y))];
            
            const datasets = indicators.map(indicator => {
                const indicatorData = heatmapData.filter(item => item.y === indicator);
                const data = years.map(year => {
                    const item = indicatorData.find(d => d.x === year);
                    return item ? item.value : 0;
                });
                
                // 지표명을 사용자 친화적으로 변경
                let displayLabel = indicator;
                let backgroundColor = '';
                
                if (indicator === 'OPM') {
                    displayLabel = '영업이익률';
                    backgroundColor = 'rgba(52, 152, 219, 0.8)';  // 파란색
                } else if (indicator === 'ROE') {
                    displayLabel = 'ROE';
                    backgroundColor = 'rgba(46, 204, 113, 0.8)';  // 초록색
                } else if (indicator === 'ROA') {
                    displayLabel = 'ROA';
                    backgroundColor = 'rgba(155, 89, 182, 0.8)';  // 보라색
                } else if (indicator === '부채비율') {
                    displayLabel = '부채비율';
                    backgroundColor = 'rgba(230, 126, 34, 0.8)';  // 주황색
                } else if (indicator === '유동비율') {
                    displayLabel = '유동비율';
                    backgroundColor = 'rgba(231, 76, 60, 0.8)';  // 빨간색
                } else {
                    backgroundColor = 'rgba(149, 165, 166, 0.8)';  // 회색 (기본값)
                }
                
                return {
                    label: displayLabel,
                    data: data,
                    backgroundColor: backgroundColor,
                    borderColor: '#ffffff',
                    borderWidth: 1
                };
            });
            
            heatmapChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: years,
                    datasets: datasets
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        title: {
                            display: true,
                            text: data.title || '연도별 재무 지표 비교',
                            color: 'rgba(255, 255, 255, 0.9)',
                            font: { size: 16, weight: 'bold' }
                        },
                        legend: {
                            labels: { color: 'rgba(255, 255, 255, 0.8)' }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: { color: 'rgba(255, 255, 255, 0.8)' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        },
                        x: {
                            ticks: { color: 'rgba(255, 255, 255, 0.8)' },
                            grid: { color: 'rgba(255, 255, 255, 0.1)' }
                        }
                    }
                }
            });
        }

        window.testChat = function(message = '이 회사 어떤가요?') {
            console.log(`테스트 채팅: ${message}`);
            addMessage('user', message);
            sendChatMessage(message).then(response => {
                addMessage('assistant', response);
            }).catch(error => {
                addMessage('assistant', `테스트 실패: ${error.message}`);
            });
        };

        // 🌐 외부 연동용 함수들 (POST 방식 지원)

        // 1. 기업 선택 시 호출되는 함수 (팝업에서 사용) - 함수명 변경으로 충돌 방지
        window.onCompanySelectedFromDashboard = function(corpCode) {
            console.log(`🏢 대시보드에서 기업 선택됨: ${corpCode}`);
            const currentYear = new Date().getFullYear().toString();
            displayDashboard(corpCode, '2020', currentYear);
        };

        // 2. 기업 분석 시작 함수 (지윤님 코드와 호환)
        window.startChatWithCompany = async function(corpCode) {
            console.log(`🚀 기업 분석 시작: ${corpCode}`);

            try {
                const currentYear = new Date().getFullYear().toString();
                await displayDashboard(corpCode, '2020', currentYear);

                if (currentDashboardData) {
                    console.log('✅ 기업 분석 준비 완료');
                    return {
                        status: 'success',
                        company_data: currentDashboardData,
                        message: `${currentDashboardData.company_info.corp_name} 기업 분석 준비 완료`
                    };
                } else {
                    throw new Error('대시보드 데이터 로드 실패');
                }
            } catch (error) {
                console.error('❌ 기업 분석 시작 실패:', error);
                return {
                    status: 'error',
                    message: error.message
                };
            }
        };

        // 3. 현재 로드된 기업 데이터 반환
        window.getCurrentCompanyData = function() {
            return currentDashboardData;
        };

        console.log('🔧 배포 서버 연동 대시보드 초기화 완료');
        console.log('📋 사용 가능한 함수들:');
        console.log('  🔹 내부 함수:');
        console.log('    - displayDashboard(corpCode, startYear, endYear): 대시보드 표시');
        console.log('    - testDashboard(corpCode): 테스트용 대시보드 표시');
        console.log('    - testChat(message): 테스트용 채팅');
        console.log('  🌐 외부 연동 함수:');
        console.log('    - window.onCompanySelected(corpCode): 팝업에서 기업 선택');
        console.log('    - window.startChatWithCompany(corpCode): 기업 분석 시작');
        console.log('    - window.getCurrentCompanyData(): 현재 기업 데이터 반환');
        console.log(`🌐 배포된 서버: ${API_BASE_URL}`);

        const currentCorpCode = getCorpCodeFromURL();
        if (currentCorpCode) {
            console.log(`🏢 현재 기업코드: ${currentCorpCode}`);
        } else {
            console.log('⚠️ 기업코드가 제공되지 않음 - 대기 상태');
        }


    </script>
</body>
</html>
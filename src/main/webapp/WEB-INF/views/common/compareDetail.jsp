<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>기업 비교 분석</title>
    <style>
       * {
           margin: 0;
           padding: 0;
           box-sizing: border-box;
       }

       body {
           font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
           background: linear-gradient(135deg, #0d0f2f 0%, #1c1f4a 100%);
           color: #e0e0e0;
           min-height: 100vh;
       }

       /* 헤더 */
       .header {
           display: flex;
           justify-content: space-between;
           align-items: center;
           padding: 20px 40px;
       }

       .user-icon {
           width: 50px;
           height: 50px;
           background: rgba(255, 255, 255, 0.1);
           border-radius: 50%;
           display: flex;
           align-items: center;
           justify-content: center;
           backdrop-filter: blur(8px);
           font-size: 24px;
       }

       /* AI 채팅 버튼 */
       .ai-chat {
           position: fixed;
           bottom: 30px;
           right: 30px;
           width: 60px;
           height: 60px;
           background: linear-gradient(135deg, #00e0ff, #0066cc);
           border-radius: 50%;
           display: flex;
           align-items: center;
           justify-content: center;
           font-weight: bold;
           font-size: 18px;
           cursor: pointer;
           box-shadow: 0 6px 20px rgba(0, 224, 255, 0.5);
           transition: transform 0.2s, box-shadow 0.2s;
       }

       .ai-chat:hover {
           transform: scale(1.15);
           box-shadow: 0 8px 30px rgba(0, 224, 255, 0.7);
       }

       /* 메인 컨테이너 */
       .main-container {
           max-width: 1200px;
           margin: 0 auto;
           padding: 20px;
       }

       /* VS 타이틀 */
       .vs-header {
           text-align: center;
           margin-bottom: 40px;
       }

       .vs-title {
           font-size: 56px;
           font-weight: 400;
           letter-spacing: 10px;
           color: #00e0ff;
           text-shadow: 0 0 10px #00e0ff, 0 0 20px #00e0ff;
       }

       /* 기업 이름 */
       .companies-header {
           display: flex;
           justify-content: space-between;
           align-items: center;
           margin-bottom: 30px;
           padding: 0 50px;
       }

       .company-name {
           font-size: 32px;
           font-weight: 600;
           text-align: center;
       }

       .company-left {
           color: #ff6a95;
           text-shadow: 0 0 5px #ff6a95;
       }

       .company-right {
           color: #4ef0e0;
           text-shadow: 0 0 5px #4ef0e0;
       }

       /* 비교 카드 */
       .comparison-grid {
           display: flex;
           flex-direction: column;
           gap: 25px;
       }

       .comparison-row {
           display: flex;
           justify-content: space-between;
           align-items: center;
           gap: 40px;
       }

       .metric-card {
           flex: 1;
           background: rgba(255, 255, 255, 0.05);
           backdrop-filter: blur(12px);
           border-radius: 20px;
           padding: 25px;
           text-align: center;
           border: 1px solid rgba(255, 255, 255, 0.15);
           position: relative;
           transition: transform 0.2s, box-shadow 0.2s;
       }

       .metric-card.winner {
           background: rgba(255, 255, 255, 0.15);
           box-shadow: 0 8px 30px rgba(255, 255, 255, 0.1);
           transform: translateY(-3px);
       }

       .metric-card.left {
           background: linear-gradient(135deg, rgba(255, 106, 149, 0.15), rgba(255, 106, 149, 0.05));
       }

       .metric-card.right {
           background: linear-gradient(135deg, rgba(78, 240, 224, 0.15), rgba(78, 240, 224, 0.05));
       }

       .metric-label {
           font-size: 16px;
           opacity: 0.8;
           margin-bottom: 10px;
           font-weight: 500;
       }

       .metric-value {
           font-size: 28px;
           font-weight: 700;
           margin-bottom: 5px;
       }

       .metric-unit {
           font-size: 14px;
           opacity: 0.7;
       }

       /* VS Divider */
       .vs-divider {
           width: 60px;
           height: 60px;
           background: rgba(255, 255, 255, 0.1);
           border-radius: 50%;
           display: flex;
           align-items: center;
           justify-content: center;
           font-size: 20px;
           font-weight: bold;
           backdrop-filter: blur(10px);
           border: 2px solid rgba(255, 255, 255, 0.2);
       }

       /* 승자 표시 */
       .winner-indicator {
           position: absolute;
           top: -5px;
           right: -5px;
           width: 32px;
           height: 32px;
           background: linear-gradient(135deg, #ffd700, #ffed4e);
           border-radius: 50%;
           display: flex;
           align-items: center;
           justify-content: center;
           font-size: 16px;
           color: #333;
           box-shadow: 0 0 5px #ffd700;
       }

       /* 분석 버튼 */
       .analysis-button {
           display: block;
           margin: 40px auto;
           padding: 15px 40px;
           background: linear-gradient(135deg, #00e0ff, #0066cc);
           border: none;
           border-radius: 30px;
           color: white;
           font-size: 18px;
           font-weight: 600;
           cursor: pointer;
           transition: all 0.3s ease;
           box-shadow: 0 6px 20px rgba(0, 224, 255, 0.4);
       }

       .analysis-button:hover {
           transform: translateY(-3px);
           box-shadow: 0 8px 30px rgba(0, 224, 255, 0.6);
       }

       /* 요약 섹션 */
       .summary-section {
           background: rgba(255, 255, 255, 0.05);
           backdrop-filter: blur(12px);
           border-radius: 20px;
           padding: 30px;
           margin-top: 40px;
           border: 1px solid rgba(255, 255, 255, 0.1);
       }

       .summary-title {
           font-size: 24px;
           font-weight: 600;
           margin-bottom: 20px;
           text-align: center;
       }

       .summary-stats {
           display: flex;
           justify-content: space-around;
           gap: 20px;
       }

       .summary-item {
           text-align: center;
           flex: 1;
       }

       .summary-item .label {
           font-size: 14px;
           opacity: 0.8;
           margin-bottom: 8px;
       }

       .summary-item .value {
           font-size: 20px;
           font-weight: 700;
       }

       .summary-item .winner {
           color: #ffd700;
       }

       /* 반응형 */
       @media (max-width: 768px) {
           .companies-header {
               padding: 0 20px;
           }

           .company-name {
               font-size: 24px;
           }

           .comparison-row {
               gap: 20px;
               flex-direction: column;
           }

           .metric-card {
               padding: 20px;
           }

           .metric-value {
               font-size: 24px;
           }

           .vs-divider {
               width: 50px;
               height: 50px;
               font-size: 16px;
           }
       }

    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/layout/sideMenu.jsp" %>
    <div class="main-container">
        <div class="vs-header">
            <h1 class="vs-title">VS</h1>
        </div>

        <div class="companies-header">
            <div class="company-name company-left" id="company1Name">삼성전자</div>
            <div class="company-name company-right" id="company2Name">LG</div>
        </div>

        <div class="comparison-grid">
            <!-- 매출액 비교 -->
            <div class="comparison-row">
                <div class="metric-card left" id="revenue1">
                    <div class="metric-label">매출액</div>
                    <div class="metric-value">258.9조</div>
                    <div class="metric-unit">원</div>
                </div>
                <div class="vs-divider">VS</div>
                <div class="metric-card right" id="revenue2">
                    <div class="metric-label">매출액</div>
                    <div class="metric-value">7.4조</div>
                    <div class="metric-unit">원</div>
                </div>
            </div>

            <!-- 영업이익 비교 -->
            <div class="comparison-row">
                <div class="metric-card left" id="operating1">
                    <div class="metric-label">영업이익</div>
                    <div class="metric-value">6.6조</div>
                    <div class="metric-unit">원</div>
                </div>
                <div class="vs-divider">VS</div>
                <div class="metric-card right" id="operating2">
                    <div class="metric-label">영업이익</div>
                    <div class="metric-value">1.6조</div>
                    <div class="metric-unit">원</div>
                </div>
            </div>

            <!-- 순이익 비교 -->
            <div class="comparison-row">
                <div class="metric-card left" id="net1">
                    <div class="metric-label">순이익</div>
                    <div class="metric-value">15.5조</div>
                    <div class="metric-unit">원</div>
                </div>
                <div class="vs-divider">VS</div>
                <div class="metric-card right" id="net2">
                    <div class="metric-label">순이익</div>
                    <div class="metric-value">1.4조</div>
                    <div class="metric-unit">원</div>
                </div>
            </div>

            <!-- 총자산 비교 -->
            <div class="comparison-row">
                <div class="metric-card left" id="assets1">
                    <div class="metric-label">총자산</div>
                    <div class="metric-value">455.9조</div>
                    <div class="metric-unit">원</div>
                </div>
                <div class="vs-divider">VS</div>
                <div class="metric-card right" id="assets2">
                    <div class="metric-label">총자산</div>
                    <div class="metric-value">30.3조</div>
                    <div class="metric-unit">원</div>
                </div>
            </div>

            <!-- ROE 비교 -->
            <div class="comparison-row">
                <div class="metric-card left" id="roe1">
                    <div class="metric-label">ROE</div>
                    <div class="metric-value">4.3%</div>
                    <div class="metric-unit">자기자본이익률</div>
                </div>
                <div class="vs-divider">VS</div>
                <div class="metric-card right" id="roe2">
                    <div class="metric-label">ROE</div>
                    <div class="metric-value">5.3%</div>
                    <div class="metric-unit">자기자본이익률</div>
                </div>
            </div>

            <!-- 부채비율 비교 -->
            <div class="comparison-row">
                <div class="metric-card left" id="debt1">
                    <div class="metric-label">부채비율</div>
                    <div class="metric-value">25.4%</div>
                    <div class="metric-unit">안정성</div>
                </div>
                <div class="vs-divider">VS</div>
                <div class="metric-card right" id="debt2">
                    <div class="metric-label">부채비율</div>
                    <div class="metric-value">12.0%</div>
                    <div class="metric-unit">안정성</div>
                </div>
            </div>
        </div>

        <div class="summary-section">
            <h3 class="summary-title">비교 요약</h3>
            <div class="summary-stats">
                <div class="summary-item">
                    <div class="label">매출 우위</div>
                    <div class="value winner" id="revenueWinner">삼성전자</div>
                </div>
                <div class="summary-item">
                    <div class="label">수익성 우위</div>
                    <div class="value winner" id="profitWinner">삼성전자</div>
                </div>
                <div class="summary-item">
                    <div class="label">자산 규모</div>
                    <div class="value winner" id="assetWinner">삼성전자</div>
                </div>
                <div class="summary-item">
                    <div class="label">안정성 우위</div>
                    <div class="value winner" id="stabilityWinner">LG</div>
                </div>
            </div>
        </div>

        <button class="analysis-button" onclick="openDetailAnalysis()">
            다른 기업 비교하기
        </button>
    </div>

    <div class="ai-chat" onclick="openAIChat()">
        AI
    </div>

    <script>
        // 샘플 데이터 (실제로는 API에서 받아옴)
        const comparisonData = {
            "comparison_info": {
                "company1": {"corp_name": "삼성전자"},
                "company2": {"corp_name": "LG"}
            },
            "basic_financial_comparison": {
                "company1": {
                    "revenue": 258935494000000,
                    "operating_profit": 6566976000000,
                    "net_profit": 15487100000000,
                    "total_assets": 455905980000000
                },
                "company2": {
                    "revenue": 7445336000000,
                    "operating_profit": 1589013000000,
                    "net_profit": 1414258000000,
                    "total_assets": 30253085000000
                }
            },
            "financial_indicators_comparison": {
                "profitability": {
                    "company1": {"ROE": 4.311},
                    "company2": {"ROE": 5.312}
                },
                "stability": {
                    "company1": {"부채비율": 25.36},
                    "company2": {"부채비율": 11.98}
                }
            },
            "comparison_summary": {
                "revenue_comparison": {"winner": "삼성전자"},
                "profitability_comparison": {"winner": "삼성전자"},
                "asset_comparison": {"winner": "삼성전자"}
            }
        };

        function formatNumber(num) {
            if (num >= 1000000000000) {
                return (num / 1000000000000).toFixed(1) + '조';
            } else if (num >= 100000000) {
                return (num / 100000000).toFixed(0) + '억';
            }
            return num.toLocaleString();
        }

        function updateDashboard(data) {
            // 기업명 업데이트
            document.getElementById('company1Name').textContent = data.comparison_info.company1.corp_name;
            document.getElementById('company2Name').textContent = data.comparison_info.company2.corp_name;

            const basic = data.basic_financial_comparison;
            const indicators = data.financial_indicators_comparison;

            // 매출액
            document.querySelector('#revenue1 .metric-value').textContent = formatNumber(basic.company1.revenue);
            document.querySelector('#revenue2 .metric-value').textContent = formatNumber(basic.company2.revenue);

            // 영업이익
            document.querySelector('#operating1 .metric-value').textContent = formatNumber(basic.company1.operating_profit);
            document.querySelector('#operating2 .metric-value').textContent = formatNumber(basic.company2.operating_profit);

            // 순이익
            document.querySelector('#net1 .metric-value').textContent = formatNumber(basic.company1.net_profit);
            document.querySelector('#net2 .metric-value').textContent = formatNumber(basic.company2.net_profit);

            // 총자산
            document.querySelector('#assets1 .metric-value').textContent = formatNumber(basic.company1.total_assets);
            document.querySelector('#assets2 .metric-value').textContent = formatNumber(basic.company2.total_assets);

            // ROE
            document.querySelector('#roe1 .metric-value').textContent = indicators.profitability.company1.ROE + '%';
            document.querySelector('#roe2 .metric-value').textContent = indicators.profitability.company2.ROE + '%';

            // 부채비율
            document.querySelector('#debt1 .metric-value').textContent = indicators.stability.company1['부채비율'] + '%';
            document.querySelector('#debt2 .metric-value').textContent = indicators.stability.company2['부채비율'] + '%';

            // 우위 표시
            highlightWinners(data);

            // 요약 업데이트
            document.getElementById('revenueWinner').textContent = data.comparison_summary.revenue_comparison.winner;
            document.getElementById('profitWinner').textContent = data.comparison_summary.profitability_comparison.winner;
            document.getElementById('assetWinner').textContent = data.comparison_summary.asset_comparison.winner;

            // 안정성은 부채비율이 낮은 쪽이 우위
            const stabilityWinner = indicators.stability.company1['부채비율'] < indicators.stability.company2['부채비율']
                ? data.comparison_info.company1.corp_name
                : data.comparison_info.company2.corp_name;
            document.getElementById('stabilityWinner').textContent = stabilityWinner;
        }

        function highlightWinners(data) {
            const basic = data.basic_financial_comparison;
            const indicators = data.financial_indicators_comparison;

            // 매출액 우위
            if (basic.company1.revenue > basic.company2.revenue) {
                document.getElementById('revenue1').classList.add('winner');
                document.getElementById('revenue1').innerHTML += '<div class="winner-indicator">👑</div>';
            } else {
                document.getElementById('revenue2').classList.add('winner');
                document.getElementById('revenue2').innerHTML += '<div class="winner-indicator">👑</div>';
            }

            // 영업이익 우위
            if (basic.company1.operating_profit > basic.company2.operating_profit) {
                document.getElementById('operating1').classList.add('winner');
                document.getElementById('operating1').innerHTML += '<div class="winner-indicator">👑</div>';
            } else {
                document.getElementById('operating2').classList.add('winner');
                document.getElementById('operating2').innerHTML += '<div class="winner-indicator">👑</div>';
            }

            // 순이익 우위
            if (basic.company1.net_profit > basic.company2.net_profit) {
                document.getElementById('net1').classList.add('winner');
                document.getElementById('net1').innerHTML += '<div class="winner-indicator">👑</div>';
            } else {
                document.getElementById('net2').classList.add('winner');
                document.getElementById('net2').innerHTML += '<div class="winner-indicator">👑</div>';
            }

            // 총자산 우위
            if (basic.company1.total_assets > basic.company2.total_assets) {
                document.getElementById('assets1').classList.add('winner');
                document.getElementById('assets1').innerHTML += '<div class="winner-indicator">👑</div>';
            } else {
                document.getElementById('assets2').classList.add('winner');
                document.getElementById('assets2').innerHTML += '<div class="winner-indicator">👑</div>';
            }

            // ROE 우위
            if (indicators.profitability.company1.ROE > indicators.profitability.company2.ROE) {
                document.getElementById('roe1').classList.add('winner');
                document.getElementById('roe1').innerHTML += '<div class="winner-indicator">👑</div>';
            } else {
                document.getElementById('roe2').classList.add('winner');
                document.getElementById('roe2').innerHTML += '<div class="winner-indicator">👑</div>';
            }

            // 부채비율 우위 (낮은 것이 좋음)
            if (indicators.stability.company1['부채비율'] < indicators.stability.company2['부채비율']) {
                document.getElementById('debt1').classList.add('winner');
                document.getElementById('debt1').innerHTML += '<div class="winner-indicator">👑</div>';
            } else {
                document.getElementById('debt2').classList.add('winner');
                document.getElementById('debt2').innerHTML += '<div class="winner-indicator">👑</div>';
            }
        }

        function openDetailAnalysis() {
            window.location.href = '/compare';
        }

        function openAIChat() {
            alert('AI 채팅을 시작합니다.');
        }

        // 페이지 로드 시 데이터 업데이트
        window.onload = function() {
            updateDashboard(comparisonData);
        };

        // 실제 API 데이터로 업데이트하는 함수
        function loadComparisonData(apiData) {
            updateDashboard(apiData.data);
        }
    </script>
</body>
</html>
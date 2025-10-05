<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
<%@ page import="com.corpIns.dto.User" %>
<%
    // 로그인 체크 - 로그인하지 않은 경우 로그인 페이지로 리다이렉트
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
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

       .loading-spinner {
           color: #888;
           font-size: 14px;
           animation: pulse 1.5s infinite;
       }

       @keyframes pulse {
           0%, 100% { opacity: 0.5; }
           50% { opacity: 1; }
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
    <div class="header">
        <div></div>
        <div class="user-icon">👤</div>
    </div>

    <div class="main-container">
        <div class="vs-header">
            <h1 class="vs-title">VS</h1>
        </div>

        <div class="companies-header">
            <div class="company-name company-left" id="company1Name"></div>
            <div class="company-name company-right" id="company2Name"></div>
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
                    <div class="value winner" id="revenueWinner">
                        <div class="loading-spinner" id="revenueLoading">분석중...</div>
                    </div>
                </div>
                <div class="summary-item">
                    <div class="label">수익성 우위</div>
                    <div class="value winner" id="profitWinner">
                        <div class="loading-spinner" id="profitLoading">분석중...</div>
                    </div>
                </div>
                <div class="summary-item">
                    <div class="label">자산 규모</div>
                    <div class="value winner" id="assetWinner">
                        <div class="loading-spinner" id="assetLoading">분석중...</div>
                    </div>
                </div>
                <div class="summary-item">
                    <div class="label">안정성 우위</div>
                    <div class="value winner" id="stabilityWinner">
                        <div class="loading-spinner" id="stabilityLoading">분석중...</div>
                    </div>
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
        // URL 파라미터에서 기업 정보 읽기
        function getUrlParameter(name) {
            const urlParams = new URLSearchParams(window.location.search);
            return urlParams.get(name);
        }

        // 선택된 기업 정보
        const selectedCompanies = {
            company1: {
                corp_code: getUrlParameter('corp1Code'),
                corp_name: getUrlParameter('corp1Name'),
                ceo_name: getUrlParameter('corp1Ceo'),
                business_name: getUrlParameter('corp1Business')
            },
            company2: {
                corp_code: getUrlParameter('corp2Code'),
                corp_name: getUrlParameter('corp2Name'),
                ceo_name: getUrlParameter('corp2Ceo'),
                business_name: getUrlParameter('corp2Business')
            }
        };

        console.log('선택된 기업들:', selectedCompanies);

        // 기본 데이터 (실제로는 API에서 받아옴)
        const comparisonData = {
            "comparison_info": {
                "company1": {"corp_name": selectedCompanies.company1.corp_name},
                "company2": {"corp_name": selectedCompanies.company2.corp_name}
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
                "revenue_comparison": {"winner": selectedCompanies.company1.corp_name},
                "profitability_comparison": {"winner": selectedCompanies.company1.corp_name},
                "asset_comparison": {"winner": selectedCompanies.company1.corp_name}
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

            // 요약 업데이트 - 실제 API 응답 구조에 맞게 수정
            updateComparisonSummary(data);
        }

        function updateComparisonSummary(data) {
            try {
                const basic = data.basic_financial_comparison || {};
                const indicators = data.financial_indicators_comparison || {};
                const companyNames = [
                    data.comparison_info?.company1?.corp_name || data.basic_info?.company1?.name,
                    data.comparison_info?.company2?.corp_name || data.basic_info?.company2?.name
                ];

                // 매출 우위 (매출액 기준)
                let revenueWinner = '-';
                if (basic.company1?.revenue && basic.company2?.revenue) {
                    revenueWinner = basic.company1.revenue > basic.company2.revenue ? companyNames[0] : companyNames[1];
                }
                document.getElementById('revenueWinner').textContent = revenueWinner;

                // 수익성 우위 (ROE 기준)
                let profitWinner = '-';
                if (indicators.profitability?.company1?.ROE && indicators.profitability?.company2?.ROE) {
                    profitWinner = indicators.profitability.company1.ROE > indicators.profitability.company2.ROE ? companyNames[0] : companyNames[1];
                }
                document.getElementById('profitWinner').textContent = profitWinner;

                // 자산 규모 (총자산 기준)
                let assetWinner = '-';
                if (basic.company1?.total_assets && basic.company2?.total_assets) {
                    assetWinner = basic.company1.total_assets > basic.company2.total_assets ? companyNames[0] : companyNames[1];
                }
                document.getElementById('assetWinner').textContent = assetWinner;

                // 안정성 우위 (부채비율 기준 - 낮을수록 좋음)
                let stabilityWinner = '-';
                if (indicators.stability?.company1?.['부채비율'] && indicators.stability?.company2?.['부채비율']) {
                    stabilityWinner = indicators.stability.company1['부채비율'] < indicators.stability.company2['부채비율'] ? companyNames[0] : companyNames[1];
                }
                document.getElementById('stabilityWinner').textContent = stabilityWinner;

            } catch (error) {
                console.error('비교 요약 업데이트 오류:', error);
                // 오류 시 기본값으로 설정
                document.getElementById('revenueWinner').textContent = '-';
                document.getElementById('profitWinner').textContent = '-';
                document.getElementById('assetWinner').textContent = '-';
                document.getElementById('stabilityWinner').textContent = '-';
            }
        }

        function updateComparisonSummaryFromAPI(comparisonData) {
            try {
                console.log('API 응답으로 비교 요약 업데이트:', comparisonData);
                
                const financialComparison = comparisonData.financial_comparison || {};
                const detailedRatios = comparisonData.detailed_ratios || {};
                const basicInfo = comparisonData.basic_info || {};
                
                const companyNames = [
                    basicInfo.company1?.name,
                    basicInfo.company2?.name
                ];

                // 매출 우위 (financial_comparison에서 매출액 비교)
                let revenueWinner = '-';
                const corp1Data = financialComparison[basicInfo.company1?.corp_code] || {};
                const corp2Data = financialComparison[basicInfo.company2?.corp_code] || {};
                
                if (corp1Data.매출액 && corp2Data.매출액) {
                    revenueWinner = corp1Data.매출액 > corp2Data.매출액 ? companyNames[0] : companyNames[1];
                } else if (corp1Data.매출액 && !corp2Data.매출액) {
                    revenueWinner = companyNames[0];
                } else if (!corp1Data.매출액 && corp2Data.매출액) {
                    revenueWinner = companyNames[1];
                }
                
                // 로딩 제거하고 결과 표시
                const revenueElement = document.getElementById('revenueWinner');
                const revenueLoading = document.getElementById('revenueLoading');
                if (revenueLoading) revenueLoading.remove();
                revenueElement.textContent = revenueWinner;

                // 수익성 우위 (영업이익률 또는 ROE 비교)
                let profitWinner = '-';
                
                // 1순위: 영업이익률(OPM) 비교
                if (detailedRatios.company1?.OPM && detailedRatios.company2?.OPM) {
                    profitWinner = detailedRatios.company1.OPM > detailedRatios.company2.OPM ? companyNames[0] : companyNames[1];
                } else if (detailedRatios.company1?.OPM && !detailedRatios.company2?.OPM) {
                    profitWinner = companyNames[0];
                } else if (!detailedRatios.company1?.OPM && detailedRatios.company2?.OPM) {
                    profitWinner = companyNames[1];
                }
                // 2순위: ROE 비교 (영업이익률이 없을 경우)
                else if (detailedRatios.company1?.ROE && detailedRatios.company2?.ROE) {
                    profitWinner = detailedRatios.company1.ROE > detailedRatios.company2.ROE ? companyNames[0] : companyNames[1];
                } else if (detailedRatios.company1?.ROE && !detailedRatios.company2?.ROE) {
                    profitWinner = companyNames[0];
                } else if (!detailedRatios.company1?.ROE && detailedRatios.company2?.ROE) {
                    profitWinner = companyNames[1];
                }
                
                // 로딩 제거하고 결과 표시
                const profitElement = document.getElementById('profitWinner');
                const profitLoading = document.getElementById('profitLoading');
                if (profitLoading) profitLoading.remove();
                profitElement.textContent = profitWinner;

                // 자산 규모 - API에서 총자산 데이터가 없으므로 매출액으로 대체
                let assetWinner = '-';
                if (corp1Data.매출액 && corp2Data.매출액) {
                    assetWinner = corp1Data.매출액 > corp2Data.매출액 ? companyNames[0] : companyNames[1];
                } else if (corp1Data.매출액 && !corp2Data.매출액) {
                    assetWinner = companyNames[0];
                } else if (!corp1Data.매출액 && corp2Data.매출액) {
                    assetWinner = companyNames[1];
                }
                
                // 로딩 제거하고 결과 표시
                const assetElement = document.getElementById('assetWinner');
                const assetLoading = document.getElementById('assetLoading');
                if (assetLoading) assetLoading.remove();
                assetElement.textContent = assetWinner;

                // 안정성 우위 (detailed_ratios에서 부채비율 비교 - 낮을수록 좋음)
                let stabilityWinner = '-';
                if (detailedRatios.company1?.부채비율 && detailedRatios.company2?.부채비율) {
                    stabilityWinner = detailedRatios.company1.부채비율 < detailedRatios.company2.부채비율 ? companyNames[0] : companyNames[1];
                }
                
                // 로딩 제거하고 결과 표시
                const stabilityElement = document.getElementById('stabilityWinner');
                const stabilityLoading = document.getElementById('stabilityLoading');
                if (stabilityLoading) stabilityLoading.remove();
                stabilityElement.textContent = stabilityWinner;

                console.log('비교 요약 업데이트 완료:', {
                    revenueWinner, profitWinner, assetWinner, stabilityWinner
                });

            } catch (error) {
                console.error('API 비교 요약 업데이트 오류:', error);
                // 오류 시 기본값으로 설정
                document.getElementById('revenueWinner').textContent = '-';
                document.getElementById('profitWinner').textContent = '-';
                document.getElementById('assetWinner').textContent = '-';
                document.getElementById('stabilityWinner').textContent = '-';
            }
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
            alert('기업 분석 페이지로 이동합니다.');
            window.location.href = '/compare';
        }

        function openAIChat() {
            alert('AI 채팅을 시작합니다.');
        }

        // 기업 비교 데이터 로드 (localStorage 우선, 실패 시 API 호출)
        async function loadRealCompanyData() {
            try {
                console.log('기업 비교 데이터를 가져오는 중...');
                
                // 이전 캐시 정리 (기업 코드별 키가 아닌 이전 방식의 캐시)
                const oldCache = localStorage.getItem('comparisonResult');
                if (oldCache) {
                    console.log('이전 캐시 제거');
                    localStorage.removeItem('comparisonResult');
                }
                
                // 1. localStorage에서 비교 결과 확인 (기업 코드별로 구분)
                const comparisonKey = `comparisonResult_${selectedCompanies.company1.corp_code}_${selectedCompanies.company2.corp_code}`;
                const storedComparison = localStorage.getItem(comparisonKey);
                if (storedComparison) {
                    try {
                        const comparisonData = JSON.parse(storedComparison);
                        console.log('✅ localStorage에서 비교 데이터 로드:', comparisonData);
                        
                        // 저장된 데이터의 기업 코드가 현재 선택된 기업과 일치하는지 확인
                        const storedCorp1 = comparisonData.basic_info?.company1?.corp_code;
                        const storedCorp2 = comparisonData.basic_info?.company2?.corp_code;
                        
                        if (storedCorp1 === selectedCompanies.company1.corp_code && 
                            storedCorp2 === selectedCompanies.company2.corp_code) {
                            // 비교 데이터를 화면에 표시
                            displayComparisonResults(comparisonData);
                            return;
                        } else {
                            console.log('⚠️ 저장된 데이터의 기업 코드가 현재 선택과 다름, 새로 로드');
                            localStorage.removeItem(comparisonKey);
                        }
                    } catch (e) {
                        console.warn('⚠️ localStorage 데이터 파싱 실패:', e);
                        localStorage.removeItem(comparisonKey);
                    }
                }
                
                // 2. localStorage에 데이터가 없으면 API 호출
                console.log('localStorage에 데이터가 없어 API 호출 시작');
                
                // 동적 환경 설정 로드
                let API_BASE_URL = 'http://localhost:5001'; // 기본값
                
                try {
                    const configUrl = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' 
                        ? 'http://localhost:5001/api/config' 
                        : `http://${window.location.hostname}:5001/api/config`;
                        
                    const configResponse = await fetch(configUrl);
                    if (configResponse.ok) {
                        const configResult = await configResponse.json();
                        if (configResult.status === 'success') {
                            API_BASE_URL = configResult.data.api_base_url;
                            console.log('환경 설정 로드 성공:', configResult.data);
                        }
                    }
                } catch (error) {
                    console.warn('환경 설정 로드 실패, 기본값 사용:', error);
                    // 폴백: 기존 로직 사용
                    API_BASE_URL = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' 
                        ? 'http://localhost:5001' 
                        : 'http://43.203.170.37:5001';
                }
                
                // 기업 비교 API 호출
                const response = await fetch(`${API_BASE_URL}/api/compare-companies`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        corp_codes: [selectedCompanies.company1.corp_code, selectedCompanies.company2.corp_code],
                        company_names: [selectedCompanies.company1.corp_name, selectedCompanies.company2.corp_name]
                    })
                });

                if (!response.ok) {
                    throw new Error('기업 비교 데이터를 가져올 수 없습니다.');
                }

                const comparisonData = await response.json();
                console.log('API에서 비교 데이터 로드:', comparisonData);
                
                // 비교 데이터를 화면에 표시
                displayComparisonResults(comparisonData);

            } catch (error) {
                console.error('기업 비교 데이터 로드 실패:', error);
                alert('기업 비교 데이터를 불러오는 중 오류가 발생했습니다.');
            }
        }

        // 비교 결과를 화면에 표시하는 함수
        function displayComparisonResults(comparisonData) {
            try {
                console.log('비교 결과 화면 표시 시작:', comparisonData);
                
                const basicInfo = comparisonData.basic_info || {};
                const financialComparison = comparisonData.financial_comparison || {};
                const detailedRatios = comparisonData.detailed_ratios || {};
                const investmentGrades = comparisonData.investment_grades || {};
                const comparisonSummary = comparisonData.comparison_summary || {};
                
                // 기업 기본 정보 업데이트
                updateCompanyBasicInfo(basicInfo);
                
                // 재무 비교 차트 업데이트
                updateFinancialComparisonCharts(financialComparison, detailedRatios);
                
                // 투자 등급 표시
                updateInvestmentGrades(investmentGrades);
                
                // 비교 요약 표시
                updateComparisonSummaryFromAPI(comparisonData);
                
                console.log('비교 결과 화면 표시 완료');
                
            } catch (error) {
                console.error('비교 결과 표시 중 오류:', error);
            }
        }

        // 기업 기본 정보 업데이트
        function updateCompanyBasicInfo(basicInfo) {
            try {
                // 기업명 업데이트
                const company1Name = basicInfo.company1?.name || selectedCompanies.company1.corp_name;
                const company2Name = basicInfo.company2?.name || selectedCompanies.company2.corp_name;
                
                // 페이지 제목 업데이트
                document.title = company1Name + ' vs ' + company2Name + ' - 기업 비교 분석';
                
                // 화면의 기업명 직접 업데이트
                const company1Element = document.getElementById('company1Name');
                const company2Element = document.getElementById('company2Name');
                
                if (company1Element) {
                    company1Element.textContent = company1Name;
                }
                if (company2Element) {
                    company2Element.textContent = company2Name;
                }
                
                console.log('기업 기본 정보 업데이트 완료:', { company1Name, company2Name });
                
            } catch (error) {
                console.error('기업 기본 정보 업데이트 실패:', error);
            }
        }

        // 재무 비교 차트 업데이트
        function updateFinancialComparisonCharts(financialComparison, detailedRatios) {
            try {
                console.log('재무 비교 차트 업데이트:', { financialComparison, detailedRatios });
                
                // 기존 차트 업데이트 로직을 새로운 데이터로 교체
                const company1Data = detailedRatios.company1 || {};
                const company2Data = detailedRatios.company2 || {};
                
                // 차트 데이터 구성
                const chartData = {
                    company1: {
                        name: selectedCompanies.company1.corp_name,
                        data: company1Data
                    },
                    company2: {
                        name: selectedCompanies.company2.corp_name,
                        data: company2Data
                    }
                };
                
                // 기존 차트 업데이트 함수 호출 (있다면)
                if (typeof updateChartsWithNewData === 'function') {
                    updateChartsWithNewData(chartData);
                } else {
                    console.log('차트 업데이트 함수가 없어 데이터만 로그 출력:', chartData);
                }
                
            } catch (error) {
                console.error('재무 비교 차트 업데이트 실패:', error);
            }
        }

        // 투자 등급 표시
        function updateInvestmentGrades(investmentGrades) {
            try {
                const company1Grade = investmentGrades.company1?.grade || {};
                const company2Grade = investmentGrades.company2?.grade || {};
                
                console.log('투자 등급 업데이트:', { company1Grade, company2Grade });
                
                // 투자 등급 표시 영역이 있다면 업데이트
                const gradeElements = document.querySelectorAll('.investment-grade, .grade-display');
                if (gradeElements.length > 0) {
                    gradeElements.forEach((el, index) => {
                        const grade = index === 0 ? company1Grade : company2Grade;
                        if (grade.grade) {
                            el.textContent = `투자등급: ${grade.grade} (${grade.score}점)`;
                            el.style.color = grade.color || '#333';
                        }
                    });
                }
                
            } catch (error) {
                console.error('투자 등급 표시 실패:', error);
            }
        }

        // 비교 요약 표시
        function updateComparisonSummary(comparisonSummary, basicInfo) {
            try {
                console.log('비교 요약 표시:', comparisonSummary);
                
                const winnerCategories = comparisonSummary.winner_categories || {};
                const overallWinner = comparisonSummary.overall_winner;
                const keyInsights = comparisonSummary.key_insights || [];
                
                // 전체 승자 표시
                if (overallWinner && overallWinner !== 'tie') {
                    const winnerName = overallWinner === 'company1' 
                        ? basicInfo.company1?.name || selectedCompanies.company1.corp_name
                        : basicInfo.company2?.name || selectedCompanies.company2.corp_name;
                    
                    console.log(`전체 승자: ${winnerName}`);
                }
                
                // 카테고리별 승자 표시
                Object.entries(winnerCategories).forEach(([category, data]) => {
                    console.log(`${category}: ${data.winner} (${data.company1_value} vs ${data.company2_value})`);
                });
                
                // 핵심 인사이트 표시
                keyInsights.forEach((insight, index) => {
                    console.log(`인사이트 ${index + 1}: ${insight}`);
                });
                
            } catch (error) {
                console.error('비교 요약 표시 실패:', error);
            }
        }

        // 기존 코드와의 호환성을 위한 더미 함수
        function loadOldComparisonData() {
            try {
                console.log('기존 비교 데이터 로드 (호환성)');

                // API 응답에서 financial_data 추출 (대시보드 응답 구조에 맞게)
                const data1 = response1.financial_data || response1.data?.financial_data || response1;
                const data2 = response2.financial_data || response2.data?.financial_data || response2;

                console.log('추출된 재무 데이터:', { data1, data2 });

                // 실제 데이터로 대시보드 업데이트
                const realComparisonData = {
                    "comparison_info": {
                        "company1": {"corp_name": selectedCompanies.company1.corp_name},
                        "company2": {"corp_name": selectedCompanies.company2.corp_name}
                    },
                    "basic_financial_comparison": {
                        "company1": data1,
                        "company2": data2
                    },
                    "financial_indicators_comparison": {
                        "profitability": {
                            "company1": {"ROE": calculateROE(data1)},
                            "company2": {"ROE": calculateROE(data2)}
                        },
                        "stability": {
                            "company1": {"부채비율": calculateDebtRatio(data1)},
                            "company2": {"부채비율": calculateDebtRatio(data2)}
                        }
                    },
                    "comparison_summary": {
                        "revenue_comparison": {"winner": data1.revenue > data2.revenue ? selectedCompanies.company1.corp_name : selectedCompanies.company2.corp_name},
                        "profitability_comparison": {"winner": data1.net_profit > data2.net_profit ? selectedCompanies.company1.corp_name : selectedCompanies.company2.corp_name},
                        "asset_comparison": {"winner": data1.total_assets > data2.total_assets ? selectedCompanies.company1.corp_name : selectedCompanies.company2.corp_name}
                    }
                };

                updateDashboard(realComparisonData);

            } catch (error) {
                console.error('실제 데이터 로드 실패:', error);
                console.log('기본 데이터로 대시보드 표시');
                updateDashboard(comparisonData);
            }
        }

        // ROE 계산 (순이익 / 자기자본)
        function calculateROE(financialData) {
            const netProfit = financialData.net_profit || 0;
            const totalEquity = financialData.total_equity || 1;
            return ((netProfit / totalEquity) * 100).toFixed(2);
        }

        // 부채비율 계산 (총부채 / 자기자본 * 100)
        function calculateDebtRatio(financialData) {
            const totalDebt = financialData.total_debt || 0;
            const totalEquity = financialData.total_equity || 1;
            return ((totalDebt / totalEquity) * 100).toFixed(2);
        }

        // 페이지 로드 시 데이터 업데이트
        window.onload = function() {
            // 즉시 URL 파라미터에서 기업명 표시
            updateCompanyNamesFromURL();
            
            // 실제 데이터 로드 시도, 실패시 기본 데이터 사용
            loadRealCompanyData();
        };

        // URL 파라미터에서 기업명을 즉시 표시하는 함수
        function updateCompanyNamesFromURL() {
            const company1Name = selectedCompanies.company1.corp_name;
            const company2Name = selectedCompanies.company2.corp_name;
            
            if (company1Name && company2Name) {
                const company1Element = document.getElementById('company1Name');
                const company2Element = document.getElementById('company2Name');
                
                if (company1Element) {
                    company1Element.textContent = company1Name;
                }
                if (company2Element) {
                    company2Element.textContent = company2Name;
                }
                
                // 페이지 제목도 업데이트
                document.title = company1Name + ' vs ' + company2Name + ' - 기업 비교 분석';
                
                console.log('URL에서 기업명 즉시 표시:', { company1Name, company2Name });
            }
        }

        // 실제 API 데이터로 업데이트하는 함수
        function loadComparisonData(apiData) {
            updateDashboard(apiData.data);
        }
    </script>
</body>
</html>
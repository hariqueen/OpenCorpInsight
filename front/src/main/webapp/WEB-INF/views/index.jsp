<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>OpenCorpInsight</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600;800&display=swap" rel="stylesheet">
    <style>
        body {
            position: relative;
            margin: 0;
            background-color: #161e63;
            font-family: 'Poppins', 'Pretendard', sans-serif;
            color: #e6e6e6; /* 약간 부드러운 회색톤 */
            line-height: 1.6;
            letter-spacing: 0.3px;
        }

        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }

        h1 {
            font-family: 'Poppins', sans-serif;
            text-align: center;
            font-size: 2rem;
            font-weight: 400; /* 얇고 세련된 두께 */
            margin: 25px 0 15px;
            letter-spacing: 0.5px;
            color: #f0f0f0;
            animation: fadeIn 1s ease-in;
        }

        h1 + h1 {
            margin-top: 0; /* 연속 제목은 여백 줄임 */
            font-size: 1.5rem;
            font-weight: 300;
            color: #cfd4ff; /* 살짝 파스텔 톤 */
        }
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        img {
            width: 70%;
            display: block;
            margin: 30px auto;
            opacity: 0;
            transform: translateY(40px);
            transition: all 0.8s ease-out;
        }

        img.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .continue-btn {
            display: block;
            width: fit-content;
            margin: 20px auto 60px;
            padding: 12px 30px;
            background: linear-gradient(90deg, #00ffff, #0077ff);
            color: #161e63;
            font-weight: bold;
            border-radius: 30px;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 0 15px rgba(0, 255, 255, 0.6);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            animation: glowPulse 1.5s infinite alternate;
        }

        .continue-btn:hover {
            transform: scale(1.08);
            box-shadow: 0 0 25px rgba(0, 255, 255, 1);
        }

        @keyframes glowPulse {
            0% {
                box-shadow: 0 0 10px rgba(0, 255, 255, 0.5);
            }
            100% {
                box-shadow: 0 0 20px rgba(0, 255, 255, 1);
            }
        }

        .compare-title {
            text-align: center;
            font-size: 1.8rem;
            font-weight: bold;
            margin: 50px 0 30px;
        }

        .compare-box {
            display: flex;
            justify-content: space-around;
            align-items: center;
            margin-bottom: 20px;
        }

        .company {
            text-align: center;
        }

        .company img {
            width: 100px;
            height: 100px;
            background: white;
            border-radius: 20px;
        }

        .vs-text {
            font-size: 32px;
            font-weight: bold;
            margin: 0 20px;
        }

        .stats {
            display: flex;
            justify-content: space-around;
            gap: 40px;
            margin-top: 30px;
        }

        .stat-group {
            display: flex;
            flex-direction: column;
            gap: 20px;
            width: 40%;
        }

        .stat {
            background-color: #1c276e;
            padding: 15px;
            border-radius: 15px;
            text-align: center;
        }

        .bar {
            height: 20px;
            border-radius: 10px;
            margin-bottom: 5px;
        }

        .red-bar {
            background-color: #f48a8a;
        }

        .blue-bar {
            background-color: #9ccafc;
        }

        .video-container {
            width: 100%;
            max-width: 600px;
            margin: 20px auto;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .video-container video {
            width: 100%;
            height: auto;
            display: block;
        }

        .video-container img {
            width: 100%;
            height: auto;
            display: block;
        }

        .comparison-section {
            text-align: center;
            margin: 30px 0;
        }

        .comparison-title {
            text-align: center;
            margin-bottom: 20px;
        }

        .title {
            font-family: 'Poppins', 'Pretendard', sans-serif;
            font-size: 1.8rem;
            font-weight: bold;
            color: white;
            margin-bottom: 20px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
            letter-spacing: 0.5px;
        }

        .vs-select {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 20px;
            margin-bottom: 20px;
        }

        .vs-button {
            width: 80px;
            height: 60px;
            background: white;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Poppins', 'Pretendard', sans-serif;
            font-size: 2.5rem;
            font-weight: 300;
            color: #161e63;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(255, 255, 255, 0.2);
        }

        .vs-button:hover {
            transform: scale(1.05);
            box-shadow: 0 6px 20px rgba(255, 255, 255, 0.3);
        }

        .vs-text {
            font-family: 'Poppins', 'Pretendard', sans-serif;
            font-size: 2rem;
            font-weight: bold;
            color: white;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
            letter-spacing: 0.5px;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/layout/sideMenu.jsp" %>
<div class="container">
<%@ include file="/WEB-INF/views/layout/searchBar.jsp" %>
    <h1>어려운 재무제표? 한 줄로 물어보세요.</h1>
    <h1>기업 실적부터 리스크 이슈까지, AI 챗봇이 똑똑하게 정리해드립니다.</h1>

    <img src="/images/KakaoTalk_Photo_2025-08-19-17-39-28.gif" alt="chatbot 이미지" class="fade-img">
    <a href="/chatBot" class="continue-btn">AI 챗봇 바로가기</a>

    <div class="comparison-section">
        <div class="comparison-title">
            <div class="title">업계의 왕좌는 누구? <br>매치업을 만들어보세요!</div>
            <div class="vs-select">
                <div class="vs-button">+</div>
                <div class="vs-text">VS</div>
                <div class="vs-button">+</div>
            </div>
        </div>
        <div class="video-container">
            <img src="/images/social_u3814867885_httpss.gif" alt="비교 애니메이션" class="fade-img">
        </div>
    </div>

    <a href="/compare" class="continue-btn">기업 비교 바로가기</a>

    <%@ include file="/WEB-INF/views/layout/floating.jsp" %>
</div>
<script>
window.addEventListener('load', () => {
    const fadeImgs = document.querySelectorAll('.fade-img');
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });

    fadeImgs.forEach(img => observer.observe(img));
});

// VS 버튼 클릭 시 팝업 열기 (compare.jsp와 동일한 기능)
document.querySelectorAll('.vs-button').forEach((btn, index) => {
    btn.addEventListener('click', () => {
        console.log('홈페이지 VS 버튼 클릭: ' + (index === 0 ? '왼쪽' : '오른쪽') + ' 버튼');
        window.popupSide = index;
        // 비교 모드임을 명시
        window.open('/compare/compSearchPopUp?mode=compare', 'companyPopup', 'width=700,height=800');
    });
});

// 부모 페이지: 팝업에서 선택된 회사 처리
function onCompanySelected(corp) {
    const side = window.popupSide;
    const btns = document.querySelectorAll('.vs-button');

    console.log('기업 선택됨: ' + corp.corp_name + ' (' + corp.corp_code + ') - ' + (side === 0 ? '왼쪽' : '오른쪽') + ' 버튼');
    console.log('VS 버튼 개수:', btns.length, '선택된 side:', side);

    // 안전성 검사
    if (!btns || btns.length === 0) {
        console.error('VS 버튼을 찾을 수 없습니다');
        return;
    }
    
    if (side === undefined || side === null || side < 0 || side >= btns.length) {
        console.error('잘못된 side 값:', side, '버튼 개수:', btns.length);
        return;
    }

    const targetBtn = btns[side];
    if (!targetBtn) {
        console.error('대상 버튼을 찾을 수 없습니다. side:', side);
        return;
    }

    // VS 버튼에 회사명 표시 (텍스트 크기 조정)
    targetBtn.textContent = corp.corp_name.length > 4 ? corp.corp_name.substring(0, 4) + '...' : corp.corp_name;
    targetBtn.style.fontSize = '12px';
    targetBtn.style.fontWeight = 'bold';

    // 선택한 회사 정보 저장
    targetBtn.dataset.corpCode = corp.corp_code;
    targetBtn.dataset.corpName = corp.corp_name;
    targetBtn.dataset.ceoName = corp.ceo_name;
    targetBtn.dataset.businessName = corp.business_name;

    console.log('현재 선택된 기업들: 왼쪽=' + (btns[0].dataset.corpName || '미선택') + ', 오른쪽=' + (btns[1].dataset.corpName || '미선택'));

    // 두 회사 모두 선택되면 비교 페이지로 이동
    if (btns[0].dataset.corpCode && btns[1].dataset.corpCode) {
        console.log('두 기업 모두 선택됨! 비교 분석 시작: ' + btns[0].dataset.corpName + ' vs ' + btns[1].dataset.corpName);
        compareAndGoDetail(btns[0].dataset, btns[1].dataset);
    }
}

// 환경 설정 로드 함수
let API_BASE_URL = 'http://localhost:5001'; // 기본값

async function loadConfig() {
    try {
        const configUrl = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' 
            ? 'http://localhost:5001/api/config' 
            : 'http://' + window.location.hostname + ':5001/api/config';
            
        const response = await fetch(configUrl);
        if (response.ok) {
            const result = await response.json();
            if (result.status === 'success') {
                API_BASE_URL = result.data.api_base_url;
                console.log('환경 설정 로드 성공:', result.data);
                return result.data;
            }
        }
    } catch (error) {
        console.error('환경 설정 로드 실패:', error);
        // 기본값 유지
    }
}

// 기업 비교 분석 실행
async function compareAndGoDetail(company1, company2) {
    try {
        console.log('기업 비교 분석 시작');
        console.log('비교 기업 1: ' + company1.corpName + ' (' + company1.corpCode + ')');
        console.log('비교 기업 2: ' + company2.corpName + ' (' + company2.corpCode + ')');

        // 로딩 표시
        const loadingDiv = document.createElement('div');
        loadingDiv.id = 'comparisonLoading';
        loadingDiv.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.8);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 10000;
            color: white;
            font-size: 18px;
        `;
        loadingDiv.innerHTML = `
            <div style="text-align: center;">
                <div style="margin-bottom: 20px;">기업 비교 분석 중...</div>
                <div style="font-size: 14px;">` + company1.corpName + ` vs ` + company2.corpName + `</div>
            </div>
        `;
        document.body.appendChild(loadingDiv);

        // 환경 설정 로드
        console.log('환경 설정 로드 중');
        await loadConfig();
        console.log('API URL: ' + API_BASE_URL);

        // 기업 비교 API 호출
        const apiUrl = API_BASE_URL + '/api/compare-companies';
        const requestData = {
            corp_codes: [company1.corpCode, company2.corpCode],
            company_names: [company1.corpName, company2.corpName]
        };
        
        console.log('API 호출 시작: ' + apiUrl);
        console.log('요청 데이터:', requestData);
        
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(requestData)
        });
        
        console.log('API 응답: ' + response.status + ' ' + response.statusText);

        // 로딩 제거
        document.body.removeChild(loadingDiv);

        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.error || 'HTTP ' + response.status + ': ' + response.statusText);
        }

        const comparisonData = await response.json();
        console.log('비교 분석 결과:', comparisonData);

        // 비교 결과를 localStorage에 저장 (기업 코드별로 구분)
        const comparisonKey = `comparisonResult_${company1.corpCode}_${company2.corpCode}`;
        localStorage.setItem(comparisonKey, JSON.stringify(comparisonData));

        // 선택한 회사 정보를 query로 전달 (기존 compareDetail 페이지 호환)
        const queryParams = new URLSearchParams({
            corp1Code: company1.corpCode,
            corp1Name: company1.corpName,
            corp1Ceo: company1.ceoName,
            corp1Business: company1.businessName,
            corp2Code: company2.corpCode,
            corp2Name: company2.corpName,
            corp2Ceo: company2.ceoName,
            corp2Business: company2.businessName
        });

        // compareDetail 페이지로 이동
        window.location.href = '/compareDetail?' + queryParams.toString();

    } catch (err) {
        // 로딩 제거 (오류 시)
        const loadingDiv = document.getElementById('comparisonLoading');
        if (loadingDiv) {
            document.body.removeChild(loadingDiv);
        }
        
        console.error('기업 비교 분석 중 오류 발생:', err);
        alert('기업 비교 분석 중 오류가 발생했습니다: ' + err.message);
    }
}

</script>

</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
<html>
<head>
    <title>기업 검색</title>
    <style>
        body {
            font-family: 'Pretendard', sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }

        .popup-wrapper {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
        }

        .popup-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .popup-header h2 {
            margin: 0;
            font-size: 24px;
        }

        .close-btn {
            font-size: 24px;
            border: none;
            background: none;
            cursor: pointer;
        }

        .search-section {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        .search-section input {
            flex: 1;
            padding: 10px;
            font-size: 16px;
            border-radius: 6px;
            border: 1px solid #ccc;
        }

        .search-section button {
            padding: 10px 20px;
            font-size: 16px;
            background: linear-gradient(to right, #00ffff, #0077ff);
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: background 0.3s;
        }

        .search-section button:hover {
            background: linear-gradient(to right, #00ccff, #0055cc);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 15px;
        }

        table th, table td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: center;
        }

        table th {
            background-color: #f0f8ff;
        }

        table tbody tr:hover {
            background-color: #f9f9f9;
        }

    </style>
</head>
<body>

<div class="popup-wrapper">
    <div class="popup-header">
        <h2>회사명 찾기</h2>
        <button class="close-btn" onclick="window.close()">×</button>
    </div>

    <div class="search-section">
        <input type="text" id="popupSearchInput" placeholder="회사명을 입력하세요">
        <button id="popupSearchBtn">검색</button>
    </div>

    <table>
        <thead>
        <tr>
            <th>선택</th>
            <th>회사명</th>
            <th>대표자명</th>
            <th>종목명</th>
        </tr>
        </thead>
        <tbody id="popupResultBody">
        <tr>
            <td colspan="4">검색어를 입력해 주세요.</td>
        </tr>
        </tbody>
    </table>
</div>

<script>
// Spring Boot 백엔드 API 주소
const BACKEND_API = "/api/search";

// URL 파라미터에서 검색 텍스트 가져오기
function getSearchTextFromURL() {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get('searchText') || '';
}

// 페이지 로드 시 검색 텍스트 설정
window.addEventListener('load', function() {
    const searchText = getSearchTextFromURL();
    if (searchText) {
        document.getElementById('popupSearchInput').value = searchText;
        // 자동으로 검색 실행
        performSearch();
    }
});

// 검색 함수
async function performSearch() {
    const keyword = document.getElementById("popupSearchInput").value.trim();
    const resultBody = document.getElementById("popupResultBody");
    resultBody.innerHTML = "";

    if (!keyword) {
        resultBody.innerHTML = `<tr><td colspan="4">검색어를 입력해 주세요.</td></tr>`;
        return;
    }

    try {
        // Spring Boot 백엔드를 통해 검색
        const queryParams = new URLSearchParams({
            q: keyword,
            limit: '10',
            bgn_de: '20230701',
            end_de: '20240930'
        });

        const resp = await fetch(`${BACKEND_API}?${queryParams}`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });

        if (!resp.ok) throw new Error(`서버 응답 오류: ${resp.status}`);
        const data = await resp.json();

        console.log('API 응답:', data); // 디버깅용

        // 응답 구조 확인 및 처리
        let companies = [];
        if (data.companies) {
            companies = data.companies;
        } else if (data.list) {
            companies = data.list;
        } else if (Array.isArray(data)) {
            companies = data;
        }

        if (!companies || companies.length === 0) {
            resultBody.innerHTML = `<tr><td colspan="4">검색 결과가 없습니다.</td></tr>`;
            return;
        }

        // 테이블 채우기
        let html = '';
        companies.forEach(item => {
            const corpCode = item.corp_code || item.corpCode || '';
            const corpName = item.corp_name || item.corpName || '';
            const ceoName = item.ceo_name || item.ceoName || '';
            const businessName = item.business_name || item.businessName || '';
            const stockCode = item.stock_code || item.stockCode || '';
            const isListed = item.is_listed || item.isListed || false;

            html += `
            <tr>
                <td>
                    <button onclick="selectCompany('${corpCode}', '${corpName}', '${ceoName}', '${businessName}', '${stockCode}', ${isListed})">
                        선택
                    </button>
                </td>
                <td>${corpName}</td>
                <td>${ceoName}</td>
                <td>${businessName}</td>
            </tr>
            `;
        });
        resultBody.innerHTML = html;

    } catch (err) {
        console.error("검색 실패:", err);
        resultBody.innerHTML = `<tr><td colspan="4">오류 발생: ${err.message}</td></tr>`;
    }
}

// 검색 버튼 클릭 이벤트
document.getElementById("popupSearchBtn").addEventListener("click", performSearch);

// Enter 키 이벤트
document.getElementById("popupSearchInput").addEventListener("keydown", function(e) {
    if (e.key === 'Enter') {
        performSearch();
    }
});

// 회사 선택
async function selectCompany(corpCode, corpName, ceoName, businessName, stockCode, listed) {
    try {
        console.log('=== compSearchPopUp.jsp selectCompany 호출됨 ===');
        console.log('선택된 기업:', { corpCode, corpName, ceoName, businessName, stockCode, listed });
        
        // 연도 선택 모달 표시
        showYearSelectionModal(corpCode, corpName, ceoName, businessName, stockCode, listed);

    } catch (err) {
        console.error('데이터 전송 실패:', err);
        alert('데이터 전송 중 오류가 발생했습니다.');
    }
}

// 연도 옵션 생성 함수
function generateYearOptions(startYear, endYear, selectedYear) {
    let options = '';
    for (let year = endYear; year >= startYear; year--) {
        const selected = year == selectedYear ? 'selected' : '';
        options += `<option value="${year}" ${selected}>${year}년</option>`;
    }
    return options;
}

// 연도 선택 모달 표시
function showYearSelectionModal(corpCode, corpName, ceoName, businessName, stockCode, listed) {
    // 기존 모달이 있다면 제거
    const existingModal = document.getElementById('yearSelectionModal');
    if (existingModal) {
        existingModal.remove();
    }

    // 연도 선택 모달 생성
    const modal = document.createElement('div');
    modal.id = 'yearSelectionModal';
    modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.7);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 10000;
    `;

    modal.innerHTML = `
        <div style="background: white; padding: 30px; border-radius: 10px; min-width: 400px;">
            <h3 style="margin-bottom: 20px; color: #333;">📅 분석 연도 선택</h3>
            <p style="margin-bottom: 15px; color: #666;">${corpName} 기업 분석을 위한 연도 범위를 선택해주세요.</p>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">시작 연도:</label>
                <select id="startYear" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                    ${generateYearOptions(2005, 2025, 2020)}
                </select>
            </div>
            
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; font-weight: bold;">종료 연도:</label>
                                            <select id="endYear" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                                ${generateYearOptions(2005, 2025, new Date().getFullYear())}
                            </select>
            </div>
            
            <div style="display: flex; gap: 10px; justify-content: flex-end;">
                <button onclick="closeYearModal()" style="padding: 8px 16px; border: 1px solid #ddd; background: #f8f9fa; border-radius: 4px; cursor: pointer;">
                    취소
                </button>
                <button onclick="confirmYearSelection('${corpCode}', '${corpName}', '${ceoName}', '${businessName}', '${stockCode}', ${listed})" 
                        style="padding: 8px 16px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;">
                    분석 시작
                </button>
            </div>
        </div>
    `;

    document.body.appendChild(modal);
}

// 연도 선택 모달 닫기
function closeYearModal() {
    const modal = document.getElementById('yearSelectionModal');
    if (modal) {
        modal.remove();
    }
}

// 연도 선택 확인 및 부모 페이지로 데이터 전달
function confirmYearSelection(corpCode, corpName, ceoName, businessName, stockCode, listed) {
    try {
        const startYear = document.getElementById('startYear').value;
        const endYear = document.getElementById('endYear').value;
        
        console.log('선택된 연도:', { startYear, endYear });
        
        // localStorage에 데이터 저장 (백업용)
        const companyData = {
            corp_code: corpCode,
            corp_name: corpName,
            ceo_name: ceoName,
            business_name: businessName,
            stock_code: stockCode,
            is_listed: listed,
            start_year: startYear,
            end_year: endYear
        };
        
        localStorage.setItem('selectedCompany', JSON.stringify(companyData));
        console.log('localStorage에 데이터 저장:', companyData);
        
        // URL 파라미터 생성
        const queryParams = new URLSearchParams({
            corpCode: corpCode,
            startYear: startYear,
            endYear: endYear
        });
        const targetUrl = `/chatBotDash?${queryParams.toString()}`;
        
        console.log('대시보드로 이동할 URL:', targetUrl);
        
        // 부모 페이지로 직접 이동 (팝업 차단 문제 해결)
        if (window.opener) {
            console.log('부모 페이지로 직접 이동 중...');
            window.opener.location.href = targetUrl;
        } else {
            console.log('새 창에서 이동 중...');
            window.location.href = targetUrl;
        }

        // 성공 메시지
        alert(`✅ 분석 시작!\n회사명: ${corpName}\n분석 연도: ${startYear}년 ~ ${endYear}년`);

        // 모달 닫기
        closeYearModal();
        
        // 팝업 닫기
        window.close();

    } catch (err) {
        console.error('연도 선택 처리 중 오류:', err);
        alert('연도 선택 처리 중 오류가 발생했습니다.');
    }
}

</script>
</body>
</html>

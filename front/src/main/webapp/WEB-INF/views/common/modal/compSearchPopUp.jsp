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

        /* 로딩 스피너 스타일 */
        .loading-spinner {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #007bff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-right: 8px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .loading-text {
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            font-size: 16px;
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
    // console.log('회사명 찾기 팝업 로드됨');
    // console.log('URL에서 가져온 검색어:', searchText || '(없음)');
    
    if (searchText) {
        document.getElementById('popupSearchInput').value = searchText;
        // console.log('자동 검색 실행 시작:', searchText);
        // 자동으로 검색 실행
        performSearch();
    } else {
        // console.log('검색어가 없어서 대기 상태');
    }
});

// 검색 함수
async function performSearch() {
    const keyword = document.getElementById("popupSearchInput").value.trim();
    const resultBody = document.getElementById("popupResultBody");
    
    // console.log('기업 검색 시작');
    // console.log('검색 키워드:', keyword || '(빈 검색어)');
    
    if (!keyword) {
        resultBody.innerHTML = '<tr><td colspan="4">검색어를 입력해 주세요.</td></tr>';
        return;
    }
    
    // 서버에 팝업 검색 시작 로그 전송
    fetch('/api/log', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: '팝업창 기업 검색 시작', keyword: keyword })
    });

    // 로딩 스피너 표시
    // console.log('로딩 스피너 표시 및 API 호출 시작');
    resultBody.innerHTML = '<tr><td colspan="4"><div class="loading-text"><div class="loading-spinner"></div>기업 정보를 검색하고 있습니다...</div></td></tr>';

    try {
        // Spring Boot 백엔드를 통해 검색
        const queryParams = new URLSearchParams({
            q: keyword,
            limit: '10',
            bgn_de: '20230701',
            end_de: '20240930'
        });

        const apiUrl = `${BACKEND_API}?${queryParams}`;
        
        // 서버에 API 호출 로그 전송
        fetch('/api/log', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: '팝업창 API 호출', url: apiUrl, keyword: keyword })
        });
        // console.log('검색 파라미터:', {
        //     q: keyword,
        //     limit: '10',
        //     bgn_de: '20230701',
        //     end_de: '20240930'
        // });

        const resp = await fetch(apiUrl, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });

        // console.log('API 응답 상태:', resp.status, resp.statusText);
        
        // 서버에 API 응답 상태 로그 전송
        fetch('/api/log', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: '팝업창 API 응답', status: resp.status, keyword: keyword })
        });
        
        if (!resp.ok) {
            throw new Error('서버 응답 오류: ' + resp.status);
        }
        
        const data = await resp.json();
        
        // 서버에 API 응답 데이터 로그 전송
        fetch('/api/log', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: '팝업창 API 응답 데이터 수신', keyword: keyword, dataLength: JSON.stringify(data).length })
        });

        // 응답 구조 확인 및 처리
        let companies = [];
        if (data.companies) {
            companies = data.companies;
        } else if (data.list) {
            companies = data.list;
        } else if (Array.isArray(data)) {
            companies = data;
        }

        // console.log('파싱된 기업 목록:', companies);
        // console.log('검색된 기업 수:', companies ? companies.length : 0);

        if (!companies || companies.length === 0) {
            // console.log('검색 결과 없음');
            resultBody.innerHTML = '<tr><td colspan="4">검색 결과가 없습니다.</td></tr>';
            return;
        }

        // 테이블 채우기
        // console.log('검색 결과 테이블 생성 시작');
        let html = '';
        companies.forEach((item, index) => {
            // console.log('기업 ' + (index + 1) + ':', {
            //     corp_code: item.corp_code || item.corpCode,
            //     corp_name: item.corp_name || item.corpName,
            //     ceo_name: item.ceo_name || item.ceoName
            // });
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
        // console.log('검색 결과 테이블 생성 완료:', companies.length + '개 기업');

    } catch (err) {
        // 서버에 검색 오류 로그 전송
        fetch('/api/log', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                message: '기업 검색 실패', 
                error: err.message,
                keyword: keyword,
                url: apiUrl
            })
        });
        
        resultBody.innerHTML = '<tr><td colspan="4">검색 중 오류가 발생했습니다. 다시 시도해주세요.</td></tr>';
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
        // 서버에 기업 선택 로그 전송
        fetch('/api/log', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: 'selectCompany 호출됨', company: corpName + ' (' + corpCode + ')' })
        });
        
        // URL 파라미터에서 모드 확인
        const urlParams = new URLSearchParams(window.location.search);
        const mode = urlParams.get('mode');
        const parentUrl = window.opener ? window.opener.location.pathname : '';
        
        // 서버에 모드 및 부모 URL 정보 전송
        fetch('/api/log', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: '모드 및 부모 URL 확인', mode: mode, url: parentUrl })
        });
        
        if (mode === 'compare' || parentUrl === '/compare') {
            // 기업 비교 모드: 바로 선택 처리 (날짜 선택 없음)
            fetch('/api/log', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message: '기업 비교 모드 - 바로 선택', company: corpName })
            });
            
            if (window.opener && window.opener.onCompanySelected) {
                window.opener.onCompanySelected({
                    corp_code: corpCode,
                    corp_name: corpName,
                    ceo_name: ceoName,
                    business_name: businessName,
                    stock_code: stockCode,
                    is_listed: listed
                });
            }
            
            window.close();
        } else {
            // 대시보드 모드: 연도 선택 모달 표시
            fetch('/api/log', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message: '대시보드 모드 - 연도 선택', company: corpName })
            });
            
            showYearSelectionModal(corpCode, corpName, ceoName, businessName, stockCode, listed);
        }

    } catch (err) {
        // 서버에 오류 로그 전송
        fetch('/api/log', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                message: '데이터 전송 실패', 
                error: err.message,
                company: corpName,
                url: window.location.href
            })
        });
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
        
        // console.log('선택된 연도:', { startYear, endYear });
        
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
        // console.log('localStorage에 데이터 저장:', companyData);
        
        // URL 파라미터 생성
        const queryParams = new URLSearchParams({
            corpCode: corpCode,
            startYear: startYear,
            endYear: endYear
        });
        const targetUrl = `/chatBotDash?${queryParams.toString()}`;
        
        // 서버에 로그 전송 후 대시보드로 바로 이동 (서버 사이드에서 로그인 체크함)
        fetch('/api/log', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: '분석 시작', company: corpName, url: targetUrl })
        });
        
        // 대시보드로 바로 이동 (서버 사이드에서 로그인 체크 처리)
        if (window.opener) {
            window.opener.location.href = targetUrl;
        } else {
            window.location.href = targetUrl;
        }

        // 서버에 분석 시작 로그 전송
        fetch('/api/log', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: '분석 시작', company: corpName, url: targetUrl })
        });

        // 모달 닫기
        closeYearModal();
        
        // 팝업 닫기
        window.close();

    } catch (err) {
        // console.error('연도 선택 처리 중 오류:', err);
        alert('연도 선택 처리 중 오류가 발생했습니다.');
    }
}

</script>
</body>
</html>

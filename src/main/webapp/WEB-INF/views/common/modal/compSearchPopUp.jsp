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
// 서버 주소 설정
const API_BASE_URL = 'http://43.203.170.37:5001';

// --- 팝업 쪽 코드 ---
const popupSearchInput = document.getElementById('popupSearchInput');
const popupSearchBtn = document.getElementById('popupSearchBtn');
const popupResultBody = document.getElementById('popupResultBody');

popupSearchBtn.addEventListener('click', searchCompany);
popupSearchInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') searchCompany();
});

async function searchCompany() {
    const keyword = popupSearchInput.value.trim();
    popupResultBody.innerHTML = '';

    if (!keyword) {
        popupResultBody.innerHTML = '<tr><td colspan="4">검색어를 입력해 주세요.</td></tr>';
        return;
    }

    try {
        // GET 방식 호출
        const resp = await fetch(`${API_BASE_URL}/api/company/search?name=${encodeURIComponent(keyword)}`);
        const result = await resp.json();

        if (result.status !== 'success' || !result.data || result.data.length === 0) {
            popupResultBody.innerHTML = '<tr><td colspan="4">검색 결과가 없습니다.</td></tr>';
            return;
        }

        popupResultBody.innerHTML = '';
        result.data.forEach(item => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><button onclick="selectCompany('${item.corp_code}', '${item.company_name}')">선택</button></td>
                <td>${item.company_name}</td>
                <td>${item.ceo_name || '-'}</td>
                <td>${item.business_name || '-'}</td>
            `;
            popupResultBody.appendChild(tr);
        });

    } catch (err) {
        console.error(err);
        popupResultBody.innerHTML = `<tr><td colspan="4">오류 발생: ${err.message}</td></tr>`;
    }
}

function selectCompany(corpCode, corpName) {
    if (window.opener && window.opener.onCompanySelected) {
        window.opener.onCompanySelected({ corpCode, corpName });
        window.close();
    } else {
        alert('부모 페이지가 없습니다.');
    }
}

// --- 부모 페이지에서 팝업 선택 후 처리 ---
window.onCompanySelected = async function({ corpCode, corpName }) {
    console.log('선택된 기업:', corpCode, corpName);

    try {
        const data = await getDashboardData(corpCode);
        console.log('받은 대시보드 데이터:', data);

        // 예시: 화면 업데이트
        document.getElementById('companyNameDisplay').textContent = corpName;
        document.getElementById('financialSummary').textContent = JSON.stringify(data.financial_data, null, 2);
        document.getElementById('newsList').textContent = JSON.stringify(data.news_articles, null, 2);

    } catch (err) {
        console.error('데이터 로드 실패:', err);
    }
}

// --- 대시보드 데이터 호출 ---
async function getDashboardData(corpCode) {
    try {
        const resp = await fetch(`${API_BASE_URL}/api/dashboard/${corpCode}?start_year=2020&end_year=2023`);
        const result = await resp.json();

        if (result.status === 'success') {
            return result.data;
        } else {
            throw new Error(result.message);
        }
    } catch (err) {
        console.error('API 호출 오류:', err);
        throw err;
    }
}

</script>
</body>
</html>

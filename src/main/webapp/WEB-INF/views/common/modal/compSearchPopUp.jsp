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
const isLocal = location.hostname==='localhost' || location.hostname==='127.0.0.1';
const SERVER_BASE_URL = isLocal ? 'http://127.0.0.1:5001' : 'http://43.203.170.37:5001';
const API_SEARCH = `${SERVER_BASE_URL}/api/company/search`;

const searchInput = document.getElementById('popupSearchInput');
const searchBtn = document.getElementById('popupSearchBtn');
const resultBody = document.getElementById('popupResultBody');

searchBtn.addEventListener('click', searchCompany);
searchInput.addEventListener('keydown', (e)=>{ if(e.key==='Enter') searchCompany(); });

async function searchCompany() {
    const keyword = searchInput.value.trim();
    resultBody.innerHTML = '';

    if(!keyword){
        resultBody.innerHTML = '<tr><td colspan="4">검색어를 입력해 주세요.</td></tr>';
        return;
    }

    try {
        const resp = await fetch(`${API_SEARCH}?name=${encodeURIComponent(keyword)}`);
        const response = await resp.json();

        if(response.status !== 'success' || !response.data){
            resultBody.innerHTML = '<tr><td colspan="4">검색 결과가 없습니다.</td></tr>';
            return;
        }

        // response.data가 배열이든 객체든 대응
        const items = Array.isArray(response.data) ? response.data : [response.data];
        resultBody.innerHTML = '';
        items.forEach(item => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><button onclick="selectCompany('${item.corp_code}')">선택</button></td>
                <td>${item.company_name}</td>
                <td>${item.ceo_name || '-'}</td>
                <td>${item.business_name || '-'}</td>
            `;
            resultBody.appendChild(tr);
        });

    } catch(err) {
        console.error(err);
        resultBody.innerHTML = `<tr><td colspan="4">오류 발생: ${err.message}</td></tr>`;
    }
}

// 선택 시 부모 페이지로 전달 + startChatWithCompany 자동 호출
function selectCompany(corp_code) {
    if(window.opener) {
        if(window.opener.startChatWithCompany){
            window.opener.startChatWithCompany(corp_code);
        } else {
            console.warn('부모 페이지에 startChatWithCompany 함수가 없습니다.');
        }
        window.close();
    } else {
        alert('부모 페이지가 없습니다.');
    }
}
</script>
</body>
</html>

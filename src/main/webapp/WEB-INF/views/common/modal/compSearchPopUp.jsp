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
// Lambda API 주소
const FINAL_API = "https://xp5bdl3ftqldheyokoroxvcocm0eorbe.lambda-url.ap-northeast-2.on.aws/";

// 검색 버튼 이벤트
document.getElementById("popupSearchBtn").addEventListener("click", async function () {
    const keyword = document.getElementById("popupSearchInput").value.trim();
    const resultBody = document.getElementById("popupResultBody");
    resultBody.innerHTML = "";

    if (!keyword) {
        resultBody.innerHTML = `<tr><td colspan="4">검색어를 입력해 주세요.</td></tr>`;
        return;
    }

    try {
        // Lambda API POST 요청
        const resp = await fetch(FINAL_API, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                q: keyword,
                limit: 10,
                bgn_de: "20230701",
                end_de: "20240930"
            })
        });

        if (!resp.ok) throw new Error(`서버 응답 오류: ${resp.status}`);
        const data = await resp.json();

        if (!data.companies || data.companies.length === 0) {
            resultBody.innerHTML = `<tr><td colspan="4">검색 결과가 없습니다.</td></tr>`;
            return;
        }

        // 테이블 채우기
        let html = '';
        data.companies.forEach(item => {
            html += `
            <tr>
                <td>
                    <button onclick="selectCompany(
                        '${item.corp_code}',
                        '${item.corp_name}',
                        '${item.ceo_name}',
                        '${item.business_name}',
                        '${item.stock_code || ''}',
                        ${item.is_listed})">
                        선택
                    </button>
                </td>
                <td>${item.corp_name}</td>
                <td>${item.ceo_name}</td>
                <td>${item.business_name}</td>
            </tr>
            `;
        });
        resultBody.innerHTML = html;

    } catch (err) {
        console.error("검색 실패:", err);
        resultBody.innerHTML = `<tr><td colspan="4">오류 발생: ${err.message}</td></tr>`;
    }
});

// 회사 선택 이벤트
async function selectCompany(corpCode, corpName, ceoName, businessName, stockCode, listed) {
    const startDate = window.defaultStartDate || "20190101";
    const endDate = window.defaultEndDate || "20241231";

    try {
        // 선택한 회사 상세 API 호출
        const resp = await fetch(FINAL_API, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                corp_code: corpCode,
                bgn_de: startDate,
                end_de: endDate
            })
        });

        if (!resp.ok) throw new Error(`서버 응답 오류: ${resp.status}`);
        const result = await resp.json();

        console.log('선택 기업 데이터:', result);
        alert(`회사명: ${corpName}\n대표자명: ${ceoName}\n종목명: ${businessName}\n상장여부: ${listed ? '상장' : '비상장'}`);

        // 팝업에서 선택 완료 → 챗봇 대시보드 페이지로 이동
        window.location.href = `http://43.203.170.37:5001/chatBotDash?corpCode=${corpCode}`;

    } catch (err) {
        console.error('데이터 전송 실패:', err);
        alert('데이터 전송 중 오류가 발생했습니다.');
    }
}

</script>
</body>
</html>

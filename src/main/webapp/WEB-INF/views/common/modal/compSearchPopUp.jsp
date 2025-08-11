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
    const apiUrl = '/api/search'; // Spring Boot 프록시 경로

    document.getElementById("popupSearchBtn").addEventListener("click", function () {
        const keyword = document.getElementById("popupSearchInput").value.trim();
        const resultBody = document.getElementById("popupResultBody");

        resultBody.innerHTML = "";

        if (!keyword) {
            resultBody.innerHTML = `<tr><td colspan="4">검색어를 입력해 주세요.</td></tr>`;
            return;
        }

        const params = {
            q: keyword,
            limit: "10",
            bgn_de: "20230701",
            end_de: "20240930"
        };

        const queryString = Object.keys(params)
            .map(key => `${key}=${encodeURIComponent(params[key])}`)
            .join('&');

        const fullUrl = `${apiUrl}?${queryString}`;

        fetch(fullUrl)
            .then(response => response.json())
            .then(data => {
                if (!data.companies || data.companies.length === 0) {
                    resultBody.innerHTML = `<tr><td colspan="4">검색 결과가 없습니다.</td></tr>`;
                    return;
                }

                let html = '';
                data.companies.forEach(item => {
                    html += `
                    <tr>
                      <td>
                        <button onclick="selectCompany('${item.corp_code}', '${item.corp_name}', '${item.ceo_name}', '${item.business_name}')">
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
            })
            .catch(error => {
                console.error("요청 실패:", error);
                resultBody.innerHTML = `<tr><td colspan="4">오류가 발생했습니다. (${error.message})</td></tr>`;
            });
    });
    const FINAL_API = "https://xp5bdl3ftqldheyokoroxvcocm0eorbe.lambda-url.ap-northeast-2.on.aws/";

    async function selectCompany(corpCode, corpName, ceoName, businessName, stockCode, listed) {
        const startDate = window.defaultStartDate || "20190101";
        const endDate = window.defaultEndDate || "20241231";

        try {
            const response = await fetch(FINAL_API, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    corp_code: corpCode,
                    bgn_de: startDate,
                    end_de: endDate
                })
            });

            if (!response.ok) {
                throw new Error(`서버 응답 오류: ${response.status}`);
            }

            const result = await response.json();
            console.log('서버 응답:', result);

            alert(`회사명: ${corpName}\n대표자명: ${ceoName}\n종목명: ${businessName}\n상장여부: ${listed ? '상장' : '비상장'}`);
                    window.close();

            // if(window.opener) window.opener.receiveSelectedCompany({ corpCode, corpName, ceoName, businessName, startDate, endDate });

        } catch (error) {
            console.error('전송 실패:', error);
            alert('데이터 전송 중 오류가 발생했습니다.');
        }
    }

</script>

</body>
</html>

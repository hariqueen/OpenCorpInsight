<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>기업분석</title>
    <style>
        body {
            position: relative;
            margin: 0;
            background-color: #161e63;
            font-family: 'Pretendard', sans-serif;
            color: white;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
        }

        .title {
            text-align: center;
            margin: 30px 0 20px;
            font-size: 18px;
        }

        .vs-select {
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-bottom: 20px;
        }

        .vs-button {
            background-color: white;
            color: black;
            padding: 20px;
            width: 50px;
            border-radius: 20%;
            font-size: 24px;
            cursor: pointer;
            text-align: center;
        }

        .vs-text {
            font-size: 32px;
            font-weight: bold;
        }

    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/layout/sideMenu.jsp" %>

<div class="container">
<%@ include file="/WEB-INF/views/layout/searchBar.jsp" %>

    <!-- 메인 타이틀 -->
    <div class="title">업계의 왕좌는 누구? <br>매치업을 만들어보세요!</div>

    <!-- 기업 선택 버튼 -->
    <div class="vs-select">
        <div class="vs-button">+</div>
        <div class="vs-text">VS</div>
        <div class="vs-button">+</div>
    </div>

<%@ include file="/WEB-INF/views/layout/floating.jsp" %>
</div>
<script>
// VS 버튼 클릭 시 팝업 열기
document.querySelectorAll('.vs-button').forEach((btn, index) => {
    btn.addEventListener('click', () => {
        window.popupSide = index;
        window.open('/compare/compSearchPopUp', 'companyPopup', 'width=700,height=800');
    });
});

// 부모 페이지: 팝업에서 선택된 회사 처리
function onCompanySelected(corp) {
    const side = window.popupSide;
    const btns = document.querySelectorAll('.vs-button');

    // VS 버튼에 회사명 표시
    btns[side].textContent = corp.corp_name;

    // 선택한 회사 정보 저장
    btns[side].dataset.corpCode = corp.corp_code;
    btns[side].dataset.ceoName = corp.ceo_name;
    btns[side].dataset.businessName = corp.business_name;

    // 두 회사 모두 선택되면 비교 API 호출 후 compareDetail 페이지 이동
    if (btns[0].dataset.corpCode && btns[1].dataset.corpCode) {
        compareAndGoDetail(btns[0].dataset, btns[1].dataset);
    }
}

// API 호출 후 compareDetail 페이지 이동
async function compareAndGoDetail(company1, company2) {
    try {
        // API 호출
        const response = await fetch('/api/compareCompanies', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ company1, company2 })
        });

        if (!response.ok) throw new Error(`서버 응답 오류: ${response.status}`);

        const result = await response.json();
        console.log('기업 비교 결과:', result);

        // 필요시 result를 세션/로컬에 저장하거나 query로 전달 가능
        // 예제는 선택한 회사 정보 query로 전달
        const queryParams = new URLSearchParams({
            corp1Code: company1.corpCode,
            corp1Name: company1.corpName || company1.corp_name,
            corp1Ceo: company1.ceoName || company1.ceo_name,
            corp1Business: company1.businessName || company1.business_name,
            corp2Code: company2.corpCode,
            corp2Name: company2.corpName || company2.corp_name,
            corp2Ceo: company2.ceoName || company2.ceo_name,
            corp2Business: company2.businessName || company2.business_name
        });

        window.location.href = `/compareDetail?${queryParams.toString()}`;

    } catch (err) {
        console.error('기업 비교 중 오류 발생:', err);
        alert('기업 비교 중 오류가 발생했습니다.');
    }
}

// 팝업에서 호출하는 예시 (popupCompanySearch.jsp)
// window.opener.onCompanySelected({
//     corp_code: '12345',
//     corp_name: '회사A',
//     ceo_name: '홍길동',
//     business_name: 'IT'
// });
// window.close();

</script>
</body>
</html>

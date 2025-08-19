<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
.navbar {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 20px;
    padding: 15px 0;
    flex-wrap: wrap;
}

/* 네온 검색창 */
.search-bar {
    width: 60%;
    padding: 10px 15px;
    border-radius: 30px;
    border: 2px solid #00ffff;
    background-color: #161e63;
    color: #fff;
    font-size: 16px;
    box-shadow: 0 0 10px rgba(0, 255, 255, 0.5), 0 0 20px rgba(0, 119, 255, 0.4);
    transition: box-shadow 0.3s ease, transform 0.2s ease;
}

.search-bar:focus {
    outline: none;
    box-shadow: 0 0 20px rgba(0, 255, 255, 0.8), 0 0 40px rgba(0, 119, 255, 0.6);
    transform: scale(1.02);
}


.search-btn {
    background: linear-gradient(90deg, #00ffff, #0077ff);
    color: #161e63;
    padding: 10px 20px;
    border-radius: 25px;
    font-weight: bold;
    font-size: 14px;
    text-shadow: 0 0 5px rgba(0, 255, 255, 0.8);
    box-shadow: 0 0 15px rgba(0, 255, 255, 0.6);
    cursor: pointer;
    transition: transform 0.2s ease, box-shadow 0.3s ease;
    border: none;
}

.search-btn:hover {
    transform: scale(1.05);
    box-shadow: 0 0 25px rgba(0, 255, 255, 1);
}
<script>
const mainSearchInput = document.getElementById('mainSearchInput');
const searchBtn = document.getElementById('searchBtn');

// 팝업 열기
function openSearchPopup() {
    window.open(
        '/compare/compSearchPopUp',
        'companyPopup',
        'width=700,height=800,scrollbars=yes,resizable=yes'
    );
}

// 검색 버튼 / 엔터 이벤트
searchBtn.addEventListener('click', openSearchPopup);
mainSearchInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') openSearchPopup();
});

// 팝업에서 선택된 회사 처리
window.onCompanySelected = async function(company) {
    console.log('선택된 기업:', company);

    try {
        const userSno = getCurrentUserSno();
        if (!userSno) throw new Error('사용자 정보가 없습니다.');

        // 1️⃣ 대시보드 API 호출
        const dashboardResp = await fetch('/api/dashboard', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ corp_code: company.corp_code, user_sno: userSno })
        });
        if (!dashboardResp.ok) throw new Error('대시보드 API 호출 실패');
        const dashboardData = await dashboardResp.json();
        console.log('대시보드 데이터:', dashboardData);

        // 2️⃣ Chatbot API 호출
        const chatResp = await fetch('/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                chat_type: 'company_analysis',
                message: `${company.corp_name} 기업 분석`,
                user_sno: userSno,
                company_data: dashboardData
            })
        });
        if (!chatResp.ok) throw new Error('Chatbot API 호출 실패');

        // 3️⃣ chatBotDash 페이지로 이동 (URL에 corpCode 파라미터 포함)
        window.location.href = `/chatBotDash?corpCode=${encodeURIComponent(company.corp_code)}`;

    } catch (err) {
        console.error('기업 선택 처리 중 오류:', err);
        alert('기업 선택 처리 중 오류가 발생했습니다.\n' + err.message);
    }
};

// 로컬 스토리지에서 현재 로그인한 사용자 user_sno 가져오기
function getCurrentUserSno() {
    const user = localStorage.getItem('currentUser');
    return user ? JSON.parse(user).user_sno : null;
}
</script>

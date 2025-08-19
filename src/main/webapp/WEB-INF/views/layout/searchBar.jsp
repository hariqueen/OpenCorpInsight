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
</style>

<div class="navbar" style="position: relative;">
    <input id="mainSearchInput" class="search-bar" placeholder="어떤 기업의 현황이 궁금하신가요?">
    <button id="searchBtn" class="search-btn">검색</button>
</div>

<script>
const mainSearchInput = document.getElementById('mainSearchInput');
const searchBtn = document.getElementById('searchBtn');

// 팝업 열기
function openSearchPopup() {
    window.open('/compare/compSearchPopUp', 'companyPopup', 'width=700,height=800,scrollbars=yes,resizable=yes');
}

// 검색 버튼/엔터 이벤트
searchBtn.addEventListener('click', openSearchPopup);
mainSearchInput.addEventListener('keydown', (e)=>{ if(e.key==='Enter') openSearchPopup(); });

// 팝업에서 선택된 회사 처리
window.onCompanySelected = async function(company) {
    console.log('선택된 기업:', company);

    try {
        // 대시보드 API 호출
        const dashboardResp = await fetch('/api/dashboard', {
            method:'POST',
            headers:{ 'Content-Type':'application/json' },
            body: JSON.stringify({ corp_code: company.corp_code, user_sno: getCurrentUserSno() })
        });
        const dashboardData = await dashboardResp.json();
        console.log('대시보드 데이터:', dashboardData);

        // Chatbot API 호출
        await fetch('/api/chat', {
            method:'POST',
            headers:{ 'Content-Type':'application/json' },
            body: JSON.stringify({
                chat_type:'company_analysis',
                message:`${company.corp_name} 기업 분석`,
                user_sno:getCurrentUserSno(),
                company_data: dashboardData
            })
        });

        // chatBotDash 페이지로 이동
        window.location.href = `/chatBotDash?corpCode=${company.corp_code}`;

    } catch(err){
        console.error(err);
        alert('기업 선택 처리 중 오류 발생');
    }
};

// 로컬 스토리지에서 user_sno 가져오기
function getCurrentUserSno() {
    const user = localStorage.getItem('currentUser');
    return user ? JSON.parse(user).user_sno : null;
}
</script>
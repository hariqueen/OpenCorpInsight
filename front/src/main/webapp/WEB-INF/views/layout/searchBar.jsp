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
    const searchText = mainSearchInput.value.trim();
    console.log('대시보드 검색 버튼 클릭됨');
    console.log('검색어:', searchText || '(빈 검색어)');
    
    let popupUrl = '/compare/compSearchPopUp';
    
    // 대시보드 모드임을 명시
    const params = new URLSearchParams();
    params.set('mode', 'dashboard');
    
    if (searchText) {
        params.set('searchText', searchText);
        console.log('검색어와 함께 팝업 열기:', popupUrl);
    } else {
        console.log('빈 검색어로 팝업 열기:', popupUrl);
    }
    
    popupUrl += '?' + params.toString();
    
    window.open(popupUrl, 'companyPopup', 'width=700,height=800,scrollbars=yes,resizable=yes');
}

// 검색 버튼/엔터 이벤트
searchBtn.addEventListener('click', openSearchPopup);
mainSearchInput.addEventListener('keydown', (e)=>{ if(e.key==='Enter') openSearchPopup(); });

// 팝업에서 선택된 회사 처리
window.onCompanySelected = function(company) {
    console.log('=== searchBar.jsp onCompanySelected 호출됨 ===');
    console.log('선택된 기업 객체:', company);
    console.log('기업코드:', company.corp_code);
    console.log('기업명:', company.corp_name);
    console.log('시작연도:', company.start_year);
    console.log('종료연도:', company.end_year);
    console.log('대시보드로 이동 준비 중...');

    try {
        // chatBotDash 페이지로 이동 (기업코드와 연도 정보를 URL 파라미터로 전달)
        const queryParams = new URLSearchParams({
            corpCode: company.corp_code,
            startYear: company.start_year || '2020',
            endYear: company.end_year || '2023'
        });
        const targetUrl = `/chatBotDash?${queryParams.toString()}`;
        console.log('이동할 URL:', targetUrl);
        console.log('현재 URL:', window.location.href);
        
        // 페이지 이동
        window.location.href = targetUrl;

    } catch(err){
        console.error('기업 선택 처리 중 오류:', err);
        alert('기업 선택 처리 중 오류 발생');
    }
};

// 로컬 스토리지에서 user_sno 가져오기
function getCurrentUserSno() {
    const user = localStorage.getItem('currentUser');
    return user ? JSON.parse(user).user_sno : null;
}
</script>
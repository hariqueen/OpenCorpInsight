<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>초기</title>
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

        /* 네온 상세 조건 버튼 */
        .dropdown {
            background: linear-gradient(90deg, #00ffff, #0077ff);
            color: #161e63;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
            text-shadow: 0 0 5px rgba(0, 255, 255, 0.8);
            box-shadow: 0 0 15px rgba(0, 255, 255, 0.6);
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.3s ease;
        }

        .dropdown:hover {
            transform: scale(1.05);
            box-shadow: 0 0 25px rgba(0, 255, 255, 1);
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

        .modal {
            display: none;
            position: absolute;
            top: calc(100% + 10px);
            left: 0;
            z-index: 1000;
            width: 450px;
            background-color: #e0e0e0;
            border-radius: 20px;
            padding: 20px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
        }

        .modal-inner {
            background-color: white;
            border-radius: 15px;
            padding: 20px;
            width: 100%;
            box-sizing: border-box;
            box-shadow: inset 0 0 3px rgba(0, 0, 0, 0.05);
        }

        .label {
            display: block;
            font-weight: bold;
            font-size: 14px;
            margin-bottom: 8px;
            color: black;
        }

        .input {
            padding: 8px 12px;
            height: 36px;
            width: 80px;
            border-radius: 8px;
            border: 1px solid #ccc;
            font-size: 14px;
            margin-bottom: 10px;
        }

        .date-range {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 10px;
        }

        .dash {
            font-size: 16px;
            font-weight: bold;
            color: #555;
        }

        .period-buttons {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
        }

        .period-btn {
            flex: 1;
            width: 50px;
            height: 36px;
            background-color: white;
            border: 1px solid #ccc;
            border-radius: 10px;
            font-size: 13px;
            cursor: pointer;
            color: #333;
        }

        .input-underline {
            border: none;
            border-bottom: 2px solid #ccc;
            background: transparent;
            font-size: 14px;
            padding: 8px 0;
            width: 100%;
            color: black;
        }

        .input-underline:focus {
            outline: none;
            border-bottom: 2px solid #161e63;
        }

        .search-btn {
            margin-left: 10px;
            padding: 8px 16px;
            background-color: #161e63;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
        }

        .search-btn:hover {
            background-color: #1e2e8a;
        }

        .popup-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 2000;
        }

        .popup {
            background: white;
            border-radius: 15px;
            padding: 30px;
            max-width: 400px;
            width: 90%;
            color: black;
        }

        .popup h3 {
            margin-top: 0;
        }

        #companyList {
            list-style: none;
            padding: 0;
        }

        #companyList li {
            padding: 10px;
            border-bottom: 1px solid #ccc;
            cursor: pointer;
        }

        #companyList li:hover {
            background-color: #f0f0f0;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/layout/sideMenu.jsp" %>

<div class="container">

    <!-- 상단 네비게이션 -->
    <div class="navbar" style="position: relative;">
        <input id="mainSearchInput" class="search-bar" placeholder="어떤 기업의 현황이 궁금하신가요?">
        <div class="dropdown">상세 조건 ▼</div>

        <div id="detailModal" class="modal">
            <div class="modal-inner">
                <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 20px;">
                    <input type="text" id="modalSearchInput" class="input-underline" placeholder="기업명을 검색해 보세요.">
                    <button id="popupSearchBtn" class="search-btn">검색</button>
                </div>

                <ul id="searchResults" style="padding-left: 15px; color: black;"></ul>

                <div class="date-range">
                    <label class="label">기간</label>
                    <input type="text" class="input" id="startDateInput" readonly>
                    <span class="dash">-</span>
                    <input type="text" class="input" id="endDateInput" readonly>
                    <div class="period-buttons">
                        <button class="period-btn" data-months="6">6개월</button>
                        <button class="period-btn" data-months="12">1년</button>
                        <button class="period-btn" data-months="36">3년</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

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

<!-- JavaScript -->
<script>
    const dropdownBtn = document.querySelector('.dropdown');
    const detailModal = document.getElementById('detailModal');
    const mainSearchInput = document.getElementById('mainSearchInput');
    const modalSearchInput = document.getElementById('modalSearchInput');
    const startDateInput = document.getElementById('startDateInput');
    const endDateInput = document.getElementById('endDateInput');
    const periodButtons = detailModal.querySelectorAll('.period-btn');
    const modalSearchBtn = detailModal.querySelector('.search-btn');

    // yyyyMMdd 형식으로 변환
    function formatDate(date) {
        const yyyy = date.getFullYear();
        const mm = String(date.getMonth() + 1).padStart(2, '0');
        const dd = String(date.getDate()).padStart(2, '0');
        return `${yyyy}${mm}${dd}`;
    }

    // 날짜 세팅 함수 (기본 3년)
    function setDefaultDates() {
        const today = new Date();
        const threeYearsAgo = new Date();
        threeYearsAgo.setFullYear(today.getFullYear() - 3);

        startDateInput.value = formatDate(threeYearsAgo);
        endDateInput.value = formatDate(today);
    }

    // 기간 버튼 클릭 시 날짜 세팅
    periodButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const months = parseInt(btn.getAttribute('data-months'));
            const today = new Date();
            const startDate = new Date();

            // months가 36이면 3년 전, 그 외는 해당 월수만큼 과거로 계산
            if (months === 36) {
                startDate.setFullYear(today.getFullYear() - 3);
            } else {
                startDate.setMonth(today.getMonth() - months);
            }

            startDateInput.value = formatDate(startDate);
            endDateInput.value = formatDate(today);
        });
    });

    function openDetailModal(keyword = '') {

        modalSearchInput.value = keyword;

        setDefaultDates();

        detailModal.style.display = 'block';
    }

    mainSearchInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            openDetailModal(mainSearchInput.value.trim());
        }
    });

    dropdownBtn.addEventListener('click', () => {
        openDetailModal(mainSearchInput.value.trim());
    });

    modalSearchBtn.addEventListener('click', () => {
        mainSearchInput.value = modalSearchInput.value.trim();
        openDetailModal(modalSearchInput.value.trim());
    });

    // 모달 밖 클릭시 닫기
    window.addEventListener('click', (e) => {
        if (!detailModal.contains(e.target) && !dropdownBtn.contains(e.target)) {
            detailModal.style.display = 'none';
        }
    });

     document.getElementById('popupSearchBtn').addEventListener('click', () => {
        const url = 'compare/compSearchPopUp';
        const popupWidth = 900;
        const popupHeight = 700;
        const left = (window.screen.width / 2) - (popupWidth / 2);
        const top = (window.screen.height / 2) - (popupHeight / 2);

        window.open(
          'compare/compSearchPopUp',
          'compSearchPopup',
          `width=${popupWidth},height=${popupHeight},left=${left},top=${top},scrollbars=yes,resizable=yes`
        );
      });
</script>
</body>
</html>

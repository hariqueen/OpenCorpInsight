<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>통합 chatBot</title>
    <style>
        body {
            margin: 0;
            background-color: #161e63;
            font-family: 'Pretendard', sans-serif;
            color: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .container {
            flex: 1;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            display: flex;
            justify-content: center; /* 가로 가운데 */
            align-items: center; /* 세로 가운데 */
        }

        /* 검색창을 화면 하단에 고정 */
        .bottom-search-bar {
            position: fixed;
            bottom: 40;
            left: 0;
            width: 100%;
            background: rgba(22, 30, 99, 0.95);
            padding: 15px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.3);
            backdrop-filter: blur(8px);
        }

        .search-bar {
            flex: 1;
            max-width: 600px;
            padding: 14px 20px;
            border-radius: 30px;
            border: 2px solid #00ffcc;
            background: #1c1f4a;
            color: white;
            font-size: 16px;
            outline: none;
            transition: all 0.3s ease;
        }

        .search-bar:focus {
            border-color: #00ffff;
            box-shadow: 0 0 15px #00ffff;
        }

        .search-btn {
            background: linear-gradient(90deg, #00ffff, #0077ff);
            color: #161e63;
            padding: 12px 18px;
            border-radius: 50%;
            font-weight: bold;
            cursor: pointer;
            border: none;
            box-shadow: 0 0 10px rgba(0, 255, 255, 0.5);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .search-btn:hover {
            transform: scale(1.1);
            box-shadow: 0 0 20px rgba(0, 255, 255, 0.8);
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/layout/sideMenu.jsp" %>

<div class="container">
    <h1>아무거나 질문해보세요!</h1>
</div>

<!-- 하단 고정 검색바 -->
<div class="bottom-search-bar">
    <input class="search-bar" placeholder="하태지와 에이아이들에게 물어보기">
    <button class="search-btn">↑</button>
</div>

<script>
    // 검색 버튼 클릭 시 페이지 이동 예시
    document.querySelector('.search-btn').addEventListener('click', function () {
        const query = document.querySelector('.search-bar').value.trim();
        if (query) {
            window.location.href = '/companyAnalysis?query=' + encodeURIComponent(query);
        }
    });
</script>

</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>OpenCorpInsight</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600;800&display=swap" rel="stylesheet">
    <style>
        body {
            position: relative;
            margin: 0;
            background-color: #161e63;
            font-family: 'Poppins', 'Pretendard', sans-serif;
            color: #e6e6e6; /* 약간 부드러운 회색톤 */
            line-height: 1.6;
            letter-spacing: 0.3px;
        }

        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }

        h1 {
            font-family: 'Poppins', sans-serif;
            text-align: center;
            font-size: 2rem;
            font-weight: 400; /* 얇고 세련된 두께 */
            margin: 25px 0 15px;
            letter-spacing: 0.5px;
            color: #f0f0f0;
            animation: fadeIn 1s ease-in;
        }

        h1 + h1 {
            margin-top: 0; /* 연속 제목은 여백 줄임 */
            font-size: 1.5rem;
            font-weight: 300;
            color: #cfd4ff; /* 살짝 파스텔 톤 */
        }
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        img {
            width: 70%;
            display: block;
            margin: 30px auto;
            opacity: 0;
            transform: translateY(40px);
            transition: all 0.8s ease-out;
        }

        img.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .continue-btn {
            display: block;
            width: fit-content;
            margin: 20px auto 60px;
            padding: 12px 30px;
            background: linear-gradient(90deg, #00ffff, #0077ff);
            color: #161e63;
            font-weight: bold;
            border-radius: 30px;
            text-decoration: none;
            cursor: pointer;
            box-shadow: 0 0 15px rgba(0, 255, 255, 0.6);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            animation: glowPulse 1.5s infinite alternate;
        }

        .continue-btn:hover {
            transform: scale(1.08);
            box-shadow: 0 0 25px rgba(0, 255, 255, 1);
        }

        @keyframes glowPulse {
            0% {
                box-shadow: 0 0 10px rgba(0, 255, 255, 0.5);
            }
            100% {
                box-shadow: 0 0 20px rgba(0, 255, 255, 1);
            }
        }

        .compare-title {
            text-align: center;
            font-size: 1.8rem;
            font-weight: bold;
            margin: 50px 0 30px;
        }

        .compare-box {
            display: flex;
            justify-content: space-around;
            align-items: center;
            margin-bottom: 20px;
        }

        .company {
            text-align: center;
        }

        .company img {
            width: 100px;
            height: 100px;
            background: white;
            border-radius: 20px;
        }

        .vs-text {
            font-size: 32px;
            font-weight: bold;
            margin: 0 20px;
        }

        .stats {
            display: flex;
            justify-content: space-around;
            gap: 40px;
            margin-top: 30px;
        }

        .stat-group {
            display: flex;
            flex-direction: column;
            gap: 20px;
            width: 40%;
        }

        .stat {
            background-color: #1c276e;
            padding: 15px;
            border-radius: 15px;
            text-align: center;
        }

        .bar {
            height: 20px;
            border-radius: 10px;
            margin-bottom: 5px;
        }

        .red-bar {
            background-color: #f48a8a;
        }

        .blue-bar {
            background-color: #9ccafc;
        }

        .video-container {
            width: 100%;
            max-width: 600px;
            margin: 20px auto;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .video-container video {
            width: 100%;
            height: auto;
            display: block;
        }

        .video-container img {
            width: 100%;
            height: auto;
            display: block;
        }

        .comparison-section {
            text-align: center;
            margin: 30px 0;
        }

        .comparison-title {
            text-align: center;
            margin-bottom: 20px;
        }

        .title {
            font-family: 'Poppins', 'Pretendard', sans-serif;
            font-size: 1.8rem;
            font-weight: bold;
            color: white;
            margin-bottom: 20px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
            letter-spacing: 0.5px;
        }

        .vs-select {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 20px;
            margin-bottom: 20px;
        }

        .vs-button {
            width: 80px;
            height: 60px;
            background: white;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Poppins', 'Pretendard', sans-serif;
            font-size: 2.5rem;
            font-weight: 300;
            color: #161e63;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(255, 255, 255, 0.2);
        }

        .vs-button:hover {
            transform: scale(1.05);
            box-shadow: 0 6px 20px rgba(255, 255, 255, 0.3);
        }

        .vs-text {
            font-family: 'Poppins', 'Pretendard', sans-serif;
            font-size: 2rem;
            font-weight: bold;
            color: white;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
            letter-spacing: 0.5px;
        }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/layout/sideMenu.jsp" %>
<div class="container">
<%@ include file="/WEB-INF/views/layout/searchBar.jsp" %>
    <h1>어려운 재무제표? 한 줄로 물어보세요.</h1>
    <h1>기업 실적부터 리스크 이슈까지, AI 챗봇이 똑똑하게 정리해드립니다.</h1>

    <img src="/images/KakaoTalk_Photo_2025-08-19-17-39-28.gif" alt="chatbot 이미지" class="fade-img">
    <a href="/chatBot" class="continue-btn">AI 챗봇 바로가기</a>

    <div class="comparison-section">
        <div class="comparison-title">
            <div class="title">업계의 왕좌는 누구? <br>매치업을 만들어보세요!</div>
            <div class="vs-select">
                <div class="vs-button">+</div>
                <div class="vs-text">VS</div>
                <div class="vs-button">+</div>
            </div>
        </div>
        <div class="video-container">
            <img src="/images/social_u3814867885_httpss.gif" alt="비교 애니메이션" class="fade-img">
        </div>
    </div>

    <a href="/compare" class="continue-btn">기업 비교 바로가기</a>

    <%@ include file="/WEB-INF/views/layout/floating.jsp" %>
</div>
<script>
window.addEventListener('load', () => {
    const fadeImgs = document.querySelectorAll('.fade-img');
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });

    fadeImgs.forEach(img => observer.observe(img));
});

</script>

</body>
</html>

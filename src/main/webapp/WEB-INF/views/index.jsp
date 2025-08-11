<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>기업분석</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600;800&display=swap" rel="stylesheet">
    <style>
        body {
            position: relative;
            margin: 0;
            background-color: #161e63;
            font-family: 'Pretendard', sans-serif;
            color: white;
            line-height: 1.6;
        }

        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }

        h1 {
            font-family: 'Poppins', sans-serif;
            text-align: center;
            font-size: 2.5rem;
            font-weight: 800;
            margin: 20px 0;
            letter-spacing: -0.5px;
            animation: fadeIn 1s ease-in;
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
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/layout/sideMenu.jsp" %>

<div class="container">
    <h1>어려운 재무제표? 한 줄로 물어보세요.</h1>
    <h1>기업 실적부터 리스크 이슈까지, AI 챗봇이 똑똑하게 정리해드립니다.</h1>

    <img src="/images/chatBotEX.png" alt="chatbot 이미지" class="fade-img">
    <a href="/chatBot" class="continue-btn">AI 챗봇 바로가기</a>

    <h1>업계의 왕좌는 누구?</h1>
    <h1>매치업을 만들어보세요!</h1>
    <img src="/images/compareEX.png" alt="compare 이미지" class="fade-img">

    <div class="compare-title">식품업계 진짜 승자는?</div>

    <div class="compare-box">
        <div class="company">
            <img src="/images/ottogi.jpeg" alt="오뚜기"><br>오뚜기
        </div>
        <div class="vs-text">VS</div>
        <div class="company">
            <img src="/images/cj.png" alt="CJ제일제당" style=" display: block !important; "><br>CJ
        </div>
    </div>

    <div class="stats">
        <div class="stat-group">
            <div class="stat">
                <div class="bar red-bar" style="width: 89%"></div>
                <div>89점<br>부채, 자산 등</div>
            </div>
            <div class="stat">
                <div class="bar red-bar" style="width: 70%"></div>
                <div>1조 2,123억<br>매출액</div>
            </div>
            <div class="stat">
                <div class="bar red-bar" style="width: 65%"></div>
                <div>영업이익</div>
            </div>
        </div>

        <div class="stat-group">
            <div class="stat">
                <div class="bar blue-bar" style="width: 92%"></div>
                <div>92.1점<br>부채, 자산 등</div>
            </div>
            <div class="stat">
                <div class="bar blue-bar" style="width: 80%"></div>
                <div>1조 1,230억<br>매출액</div>
            </div>
            <div class="stat">
                <div class="bar blue-bar" style="width: 75%"></div>
                <div>영업이익</div>
            </div>
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

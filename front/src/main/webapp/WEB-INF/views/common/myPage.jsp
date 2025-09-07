<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.corpIns.dto.User" %>
<%
    // 로그인한 사용자 정보 가져오기
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<html>
<head>
    <title>My Profile</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family: 'Pretendard', sans-serif;
            background: #161e63;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            color: white;
        }

        .profile-container {
            background-color: rgba(255, 255, 255, 0.05);
            border-radius: 20px;
            padding: 40px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 0 20px rgba(0, 255, 255, 0.3);
            text-align: center;
            animation: fadeIn 1s ease;
        }

        .title {
            font-size: 2rem;
            font-weight: 700;
            color: #00ffff;
            margin-bottom: 10px;
            animation: glowText 1.5s infinite alternate;
        }

        .form-group { margin-bottom: 20px; text-align:left; }
        .form-label { display:block; font-size:14px; font-weight:600; color:#e0e7ff; margin-bottom:5px; }

        input, select {
            width: 100%;
            padding: 12px 15px;
            border-radius: 10px;
            font-size: 16px;
            outline: none;
            border: none;
            background-color: white;
            color: #161e63;
        }
        input::placeholder { color:#94a3b8; }
        select option { background-color:white; color:#1e1e3a; }

        /* 난이도 선택 */
       .difficulty-group { display: flex; gap: 10px; }
       .difficulty-option { flex:1; }
       .difficulty-radio { display:none; }
       .difficulty-label {
           display: block;
           padding: 12px 0;
           border-radius: 10px;
           text-align: center;
           background-color: rgba(255,255,255,0.1);
           color: white;
           cursor: pointer;
           font-weight: 500;
           transition: all 0.3s ease;
       }
       .difficulty-radio:checked + .difficulty-label {
           background: linear-gradient(90deg, #00ffff, #0077ff);
           color: #161e63;
           font-weight: 600;
           box-shadow: 0 0 10px #00ffff;
       }

        .submit-btn {
            width: 100%;
            padding: 14px 0;
            border: none;
            border-radius: 30px;
            font-size: 16px;
            font-weight: bold;
            color: #161e63;
            background: linear-gradient(90deg, #00ffff, #0077ff);
            cursor: pointer;
            box-shadow: 0 0 15px rgba(0,255,255,0.6);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            animation: glowPulse 1.5s infinite alternate;
            margin-top:20px;
        }
        .submit-btn:hover { transform: scale(1.05); box-shadow:0 0 25px rgba(0,255,255,1); }

        @keyframes glowText { 0%{text-shadow:0 0 5px rgba(0,255,255,0.5);} 100%{text-shadow:0 0 15px rgba(0,255,255,1);} }
        @keyframes glowPulse { 0%{box-shadow:0 0 10px rgba(0,255,255,0.5);} 100%{box-shadow:0 0 20px rgba(0,255,255,1);} }
        @keyframes fadeIn { from{opacity:0; transform:translateY(20px);} to{opacity:1; transform:translateY(0);} }

        @media (max-width:480px){ .profile-container{padding:30px 20px;} .difficulty-group{flex-direction:column; gap:10px;} }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/views/layout/sideMenu.jsp" %>
<div class="profile-container">
    <h1 class="title">My Profile</h1>

    <form id="profileForm">
        <div class="form-group">
            <label class="form-label" for="userId">아이디</label>
            <input type="text" id="userId" name="userId" value="<%= loginUser.getEmail() %>" readonly>
        </div>

        <div class="form-group">
            <label class="form-label" for="nickname">닉네임</label>
            <input type="text" id="nickname" name="nickname" value="" placeholder="닉네임을 입력하세요">
        </div>

        <div class="form-group">
            <label class="form-label" for="interest">관심분야</label>
            <select id="interest" name="interest">
                <option value="">선택</option>
                <option value="it-dev" selected>IT/개발</option>
                <option value="finance">금융/보험</option>
                <option value="marketing">마케팅/광고</option>
            </select>
        </div>

        <div class="form-group">
            <label class="form-label" for="purpose">목적</label>
            <select id="purpose" name="purpose">
                <option value="">선택</option>
                <option value="career" selected>업무/실무</option>
                <option value="hobby">취미/여가</option>
                <option value="self-dev">자기계발</option>
            </select>
        </div>

        <div class="form-group">
            <label class="form-label">난이도</label>
            <div class="difficulty-group">
                <div class="difficulty-option">
                    <input type="radio" id="beginner" name="difficulty" value="beginner" checked class="difficulty-radio">
                    <label for="beginner" class="difficulty-label">입문자</label>
                </div>
                <div class="difficulty-option">
                    <input type="radio" id="expert" name="difficulty" value="expert" class="difficulty-radio">
                    <label for="expert" class="difficulty-label">전문가</label>
                </div>
            </div>
        </div>

        <button type="submit" class="submit-btn">수정하기</button>
    </form>
</div>

<script>
    // 페이지 로드 시 현재 닉네임 로드
    document.addEventListener('DOMContentLoaded', function() {
        // 임시로 비워둠 - 사용자가 직접 입력하도록
        console.log('프로필 페이지 로드 완료');
    });

    document.getElementById('profileForm').addEventListener('submit', async function(e){
        e.preventDefault();

        const nickname = document.getElementById('nickname').value;
        
        if (!nickname || nickname.trim() === '') {
            alert('닉네임을 입력해주세요.');
            return;
        }

        try {
            const response = await fetch('/updateProfile', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `nickname=${encodeURIComponent(nickname)}`
            });

            const result = await response.json();
            
            if (result.status === 'success') {
                alert('프로필이 성공적으로 업데이트되었습니다!');
                // 페이지 새로고침하여 상단 이름 표시 업데이트
                window.location.reload();
            } else {
                alert('오류: ' + result.message);
            }
        } catch (error) {
            console.error('프로필 업데이트 오류:', error);
            alert('프로필 업데이트 중 오류가 발생했습니다.');
        }
    });
</script>

</body>
</html>

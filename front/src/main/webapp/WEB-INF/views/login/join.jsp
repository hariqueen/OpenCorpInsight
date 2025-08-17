<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <title>회원가입</title>
    <style>
        body {
            margin: 0;
            background-color: #161e63;
            font-family: 'Pretendard', sans-serif;
            color: white;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .join-box {
            background-color: rgba(255, 255, 255, 0.05);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 0 20px rgba(0, 255, 255, 0.3);
            width: 360px;
            animation: fadeIn 1s ease;
        }

        h2 {
            text-align: center;
            color: #00ffff;
            font-size: 2rem;
            font-weight: bold;
            animation: glowText 1.5s infinite alternate;
        }

        @keyframes glowText {
            0% {
                text-shadow: 0 0 5px rgba(0, 255, 255, 0.5);
            }
            100% {
                text-shadow: 0 0 15px rgba(0, 255, 255, 1);
            }
        }

        input {
            width: 100%;
            padding: 12px;
            margin: 12px 0;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            outline: none;
        }

        .join-btn {
            margin-top: 20px;
            padding: 12px 0;
            width: 100%;
            border: none;
            border-radius: 30px;
            background: linear-gradient(90deg, #00ffff, #0077ff);
            font-weight: bold;
            font-size: 16px;
            color: #161e63;
            cursor: pointer;
            box-shadow: 0 0 15px rgba(0, 255, 255, 0.6);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            animation: glowPulse 1.5s infinite alternate;
        }

        .join-btn:hover {
            transform: scale(1.05);
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

        .error-msg {
            color: #ff8080;
            font-size: 14px;
            margin-top: -8px;
            margin-bottom: 10px;
            display: none;
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
    </style>
</head>
<body>
<form  id="joinForm" class="join-box">
    <h2>회원가입</h2>

    <input type="text" id="email" name="email" placeholder="이메일" required>
    <div id="emailError" class="error-msg">올바른 이메일 형식을 입력하세요.</div>

    <input type="password" name="password" placeholder="비밀번호" required>

    <input type="password" name="confirmPassword" placeholder="비밀번호 확인" required>

    <button type="submit" class="join-btn">가입하기</button>
</form>

<script>
$('#joinForm').on('submit', function(e) {
   e.preventDefault();

   // 이메일 유효성 검사
   const email = $('#email').val().trim();
   const emailPattern = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
   if (!emailPattern.test(email)) {
       $('#emailError').show();
       return;
   } else {
       $('#emailError').hide();
   }

   // Ajax 요청
   $.ajax({
       url: '/joinAction',
       type: 'POST',
       data: $(this).serialize(),
       success: function(response) {
           if (response.status === 'success') {
               window.location.href = '/setProfile';
           } else {
               alert(response.message || '회원가입 실패!');
           }
       },
       error: function() {
           alert('서버 오류가 발생했습니다.');
       }
   });
});
</script>
</body>
</html>

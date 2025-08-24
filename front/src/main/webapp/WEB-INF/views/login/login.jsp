<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <title>로그인</title>
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
            overflow: hidden;
        }

        .login-box {
            background-color: rgba(255, 255, 255, 0.05);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 0 20px rgba(0, 255, 255, 0.3);
            text-align: center;
            width: 320px;
            animation: fadeIn 1s ease;
        }

        h2 {
            margin-bottom: 30px;
            font-size: 2rem;
            font-weight: 700;
            color: #00ffff;
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

        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            outline: none;
        }

        .login-btn {
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

        .login-btn:hover {
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
<form id="loginForm" class="login-box">
    <h2>로그인</h2>
    <input type="text" name="email" placeholder="아이디를 입력하세요" required>
    <input type="password" name="password" placeholder="비밀번호를 입력하세요" required>
    <button type="submit" class="login-btn">LOGIN</button>
    

</form>
<script>
  $('#loginForm').on('submit', function(e) {
    e.preventDefault();

    $.ajax({
      url: '/loginAction',
      type: 'POST',
      data: $(this).serialize(),
      success: function(response) {
        if (response.status === 'success') {
          window.location.href = '/';
        } else {
          alert(response.message || '로그인 실패!');
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

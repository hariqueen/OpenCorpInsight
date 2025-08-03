<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>메뉴$</title>
</head>
<style>
    .menu-btn {
      position: fixed;
      top: 20px;
      left: 20px;
      font-size: 28px;
      color: white;
      cursor: pointer;
      z-index: 1001;
    }

    .sidebar {
      position: fixed;
      top: 0;
      left: -250px;
      width: 220px;
      height: 100%;
      background-color: #121943;
      box-shadow: 2px 0 5px rgba(0,0,0,0.3);
      padding: 60px 20px;
      box-sizing: border-box;
      transition: left 0.3s ease-in-out;
      z-index: 1000;
    }
   .sidebar-item {
     color: white;
     font-size: 18px;
     display: block;
     cursor: pointer;
     padding: 10px;
     border-radius: 8px;
   }


    .sidebar-item:hover {
      background-color: #2a3470;
    }

    .overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0,0,0,0.4);
      display: none;
      z-index: 999;
    }
    a {
      text-decoration: none;
    }

    .profile-btn {
      position: fixed;
      top: 20px;
      right: 20px;
      width: 50px;
      height: 50px;
      border-radius: 50%;
      background-color: #ffffff;
      color: #161e63;
      font-size: 24px;
      font-weight: bold;
      display: flex;
      justify-content: center;
      align-items: center;
      cursor: pointer;
      z-index: 1001;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
    }

    .profile-menu {
      display: none;
      position: fixed;
      top: 80px; /* 버튼 아래로 위치 */
      right: 20px;
      background-color: white;
      color: black;
      border-radius: 10px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
      padding: 10px;
      width: 140px;
      z-index: 1000;
    }

    .profile-menu button {
      width: 100%;
      background: none;
      border: none;
      padding: 10px 0;
      text-align: left;
      cursor: pointer;
      font-size: 14px;
      color: #161e63;
      border-radius: 6px;
    }

    .profile-menu button:hover {
      background-color: #f0f0f0;
    }
    </style>
<body>
<!-- 햄버거 메뉴 버튼 -->
<div class="menu-btn" onclick="toggleMenu()">☰</div>

<!-- 사이드 메뉴 -->
<div id="sidebar" class="sidebar">
<div><a href="/" class="sidebar-item" onclick="closeMenu()">Home</a></div>
<div><a href="/compare" class="sidebar-item" onclick="closeMenu()">기업 비교</a></div>
<div><a href="/chatBot" class="sidebar-item" onclick="closeMenu()">기업 분석</a></div>
</div>

<!-- 오버레이 -->
<div id="overlay" class="overlay" onclick="closeMenu()"></div>

<!-- 프로필 동그란 버튼 -->
<div class="profile-btn" onclick="toggleProfileMenu()">👤</div>

<!-- 프로필 메뉴 -->
<div id="profileMenu" class="profile-menu">
  <button onclick="alert('로그인')">로그인</button>
  <button onclick="alert('회원가입')">회원가입</button>
  <button onclick="alert('내 프로필')">내 프로필</button>
</div>

  <script>
    function toggleMenu() {
      const sidebar = document.getElementById('sidebar');
      const overlay = document.getElementById('overlay');

      if (sidebar.style.left === '0px') {
        sidebar.style.left = '-250px';
        overlay.style.display = 'none';
      } else {
        sidebar.style.left = '0px';
        overlay.style.display = 'block';
      }
    }

    function closeMenu() {
      document.getElementById('sidebar').style.left = '-250px';
      document.getElementById('overlay').style.display = 'none';
    }
    function toggleProfileMenu() {
      const menu = document.getElementById('profileMenu');
      menu.style.display = (menu.style.display === 'block') ? 'none' : 'block';
    }

    // 다른 곳 클릭하면 닫기
    window.addEventListener('click', function(e) {
      const menu = document.getElementById('profileMenu');
      const button = document.querySelector('.profile-btn');
      if (!menu.contains(e.target) && !button.contains(e.target)) {
        menu.style.display = 'none';
      }
    });
  </script>

</body>
</html>

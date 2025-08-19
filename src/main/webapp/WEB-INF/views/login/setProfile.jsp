<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>프로필 세팅</title>
   <style>
       /* 공통 */
       * { margin:0; padding:0; box-sizing:border-box; }
       body {
           font-family: 'Pretendard', sans-serif;
           background: #161e63;
           min-height: 100vh;
           display: flex;
           align-items: center;
           justify-content: center;
           padding: 20px;
           color: white;
       }

       .signup-container {
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

       .subtitle {
           font-size: 16px;
           color: #a5b4fc;
           margin-bottom: 30px;
       }

       .form-group { margin-bottom: 20px; text-align: left; }

       .form-label {
           display: block;
           font-size: 14px;
           font-weight: 600;
           color: #e0e7ff;
           margin-bottom: 5px;
       }

       /* input 필드 - 흰색 */
       .form-input {
           width: 100%;
           padding: 12px 15px;
           border-radius: 10px;
           font-size: 16px;
           outline: none;
           border: none;
           background-color: white;
           color: #161e63;
       }

       .form-input::placeholder {
           color: #94a3b8;
       }

       /* select 박스 - 평소 흰색, 열렸을 때 어둡게 */
       .form-select {
           width: 100%;
           padding: 12px 15px;
           border-radius: 10px;
           font-size: 16px;
           background-color: white;
           color: #161e63;
           border: none;
           outline: none;
           appearance: none;
           -webkit-appearance: none;
           -moz-appearance: none;
           cursor: pointer;
           position: relative;
       }

       /* select open 스타일 */
       .form-select option {
           background-color: white;
           color: #161e63; /* 글씨 검정 */
       }

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

       /* 제출 버튼 */
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
           box-shadow: 0 0 15px rgba(0, 255, 255, 0.6);
           transition: transform 0.3s ease, box-shadow 0.3s ease;
           animation: glowPulse 1.5s infinite alternate;
           margin-top: 20px;
       }
       .submit-btn:hover {
           transform: scale(1.05);
           box-shadow: 0 0 25px rgba(0, 255, 255, 1);
       }

       /* 애니메이션 */
       @keyframes glowText {
           0% { text-shadow: 0 0 5px rgba(0,255,255,0.5); }
           100% { text-shadow: 0 0 15px rgba(0,255,255,1); }
       }
       @keyframes glowPulse {
           0% { box-shadow: 0 0 10px rgba(0,255,255,0.5); }
           100% { box-shadow: 0 0 20px rgba(0,255,255,1); }
       }
       @keyframes fadeIn {
           from { opacity:0; transform: translateY(20px); }
           to { opacity:1; transform: translateY(0); }
       }

       @media (max-width:480px){
           .signup-container { padding: 30px 20px; }
           .difficulty-group { flex-direction: column; gap: 10px; }
       }
   </style>

</head>
<body>
    <div class="signup-container">
        <h1 class="title">추가 정보 입력</h1>
        <p class="subtitle">프로필을 완성해주세요!</p>

        <form id="signupForm">
            <div class="form-group">
                <label class="form-label" for="nickname">닉네임</label>
                <input type="text" id="nickname" name="nickname" class="form-input" placeholder="사용할 닉네임을 입력해주세요" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="interest">관심 분야</label>
                <select id="interest" name="interest" class="form-select" required>
                    <option value="">관심 분야를 선택해주세요</option>
                    <option value="it-dev">IT/개발</option>
                    <option value="finance">금융/보험</option>
                    <option value="marketing">마케팅/광고</option>
                    <option value="design">디자인</option>
                    <option value="business">경영/비즈니스</option>
                    <option value="language">외국어</option>
                    <option value="art">예술/창작</option>
                    <option value="health">건강/의료</option>
                    <option value="education">교육</option>
                    <option value="science">과학/공학</option>
                    <option value="law">법률</option>
                    <option value="cooking">요리/제빵</option>
                    <option value="sports">스포츠/운동</option>
                    <option value="music">음악</option>
                    <option value="etc">기타</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label" for="purpose">학습 목적</label>
                <select id="purpose" name="purpose" class="form-select" required>
                    <option value="">학습 목적을 선택해주세요</option>
                    <option value="hobby">취미/여가</option>
                    <option value="self-dev">자기계발</option>
                    <option value="career">업무/실무</option>
                    <option value="job">취업/이직</option>
                    <option value="startup">창업</option>
                    <option value="certification">자격증 취득</option>
                    <option value="academic">학업/연구</option>
                    <option value="etc">기타</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">난이도</label>
                <div class="difficulty-group">
                    <div class="difficulty-option">
                        <input type="radio" id="beginner" name="difficulty" value="beginner" class="difficulty-radio" required>
                        <label for="beginner" class="difficulty-label">입문자</label>
                    </div>
                    <div class="difficulty-option">
                        <input type="radio" id="expert" name="difficulty" value="expert" class="difficulty-radio">
                        <label for="expert" class="difficulty-label">전문가</label>
                    </div>
                </div>
            </div>

            <button type="submit" class="submit-btn">완료하기</button>
        </form>
    </div>

    <script>
        document.getElementById('signupForm').addEventListener('submit', function(e) {
            e.preventDefault();

            const formData = {
                nickname: document.getElementById('nickname').value,
                interest: document.getElementById('interest').value,
                purpose: document.getElementById('purpose').value,
                difficulty: document.querySelector('input[name="difficulty"]:checked')?.value
            };

            console.log('회원가입 데이터:', formData);

            // 간단한 유효성 검사
            if (!formData.nickname || !formData.interest || !formData.purpose || !formData.difficulty) {
                alert('모든 항목을 입력해주세요!');
                return;
            }

            // 성공 메시지
            alert('회원가입이 완료되었습니다! 🎉');
            window.location.href = '/login';
            // 여기에 실제 서버 전송 코드 추가
            // fetch('/api/signup', { method: 'POST', body: JSON.stringify(formData) })
        });

        // 입력 필드 포커스 효과
        const inputs = document.querySelectorAll('.form-input, .form-select');
        inputs.forEach(input => {
            input.addEventListener('focus', function() {
                this.parentElement.style.transform = 'translateY(-2px)';
            });

            input.addEventListener('blur', function() {
                this.parentElement.style.transform = 'translateY(0)';
            });
        });
    </script>
</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>프로필 세팅</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #1e3a8a 0%, #1e40af 50%, #2563eb 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .signup-container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        }

        .title {
            text-align: center;
            color: #1e40af;
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .subtitle {
            text-align: center;
            color: #64748b;
            font-size: 16px;
            margin-bottom: 40px;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-label {
            display: block;
            color: #374151;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .form-input {
            width: 100%;
            padding: 15px 20px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 16px;
            transition: all 0.3s ease;
            background-color: #f9fafb;
        }

        .form-input:focus {
            outline: none;
            border-color: #06b6d4;
            background-color: white;
            box-shadow: 0 0 0 3px rgba(6, 182, 212, 0.1);
        }

        .form-select {
            width: 100%;
            padding: 15px 20px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 16px;
            background-color: #f9fafb;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .form-select:focus {
            outline: none;
            border-color: #06b6d4;
            background-color: white;
            box-shadow: 0 0 0 3px rgba(6, 182, 212, 0.1);
        }

        .difficulty-group {
            display: flex;
            gap: 15px;
        }

        .difficulty-option {
            flex: 1;
            position: relative;
        }

        .difficulty-radio {
            display: none;
        }

        .difficulty-label {
            display: block;
            padding: 15px 20px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            background-color: #f9fafb;
            font-weight: 500;
        }

        .difficulty-radio:checked + .difficulty-label {
            background-color: #06b6d4;
            border-color: #06b6d4;
            color: white;
        }

        .difficulty-label:hover {
            border-color: #06b6d4;
            background-color: rgba(6, 182, 212, 0.1);
        }

        .submit-btn {
            width: 100%;
            background: linear-gradient(135deg, #06b6d4, #0891b2);
            color: white;
            border: none;
            padding: 18px;
            border-radius: 12px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 30px;
        }

        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(6, 182, 212, 0.3);
        }

        .submit-btn:active {
            transform: translateY(0);
        }

        @media (max-width: 480px) {
            .signup-container {
                padding: 30px 20px;
            }

            .difficulty-group {
                flex-direction: column;
                gap: 10px;
            }
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

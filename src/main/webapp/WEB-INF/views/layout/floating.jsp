<style>
.floating-btn {
    position: absolute;
    right: 30px;
    bottom: 30px; /* 초기 위치 */
    background: linear-gradient(90deg, #00ffff, #0077ff);
    color: #161e63;
    font-weight: bold;
    border: none;
    width: 90px;
    height: 90px;
    border-radius: 50%;
    box-shadow: 0 0 15px rgba(0, 255, 255, 0.6);
    cursor: pointer;
    transition: top 0.5s ease; /* 스크롤 이동 부드럽게 */
    animation: floatUpDown 2s ease-in-out infinite; /* 둥실둥실 */
    z-index: 1000;

    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 20px;
}

.floating-btn:hover {
    transform: scale(1.1);
    box-shadow: 0 0 25px rgba(0, 255, 255, 1);
}

@keyframes floatUpDown {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-8px); }
}
</style>

<button class="floating-btn" id="floatBtn">AI</button>

<script>
const floatBtn = document.getElementById('floatBtn');

window.addEventListener('scroll', function () {
    const scrollY = window.scrollY;
    const targetTop = scrollY + window.innerHeight - 150; // 스크롤 따라 아래쪽 위치
    floatBtn.style.top = targetTop + 'px';
});

floatBtn.addEventListener('click', function () {
    window.location.href = '/chatBot';
});
</script>

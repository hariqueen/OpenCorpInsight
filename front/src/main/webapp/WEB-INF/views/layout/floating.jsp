<style>
.floating-btn {
    position: absolute;
    right: 30px;
    background: linear-gradient(90deg, #00ffff, #0077ff);
    color: #161e63;
    font-weight: bold;
    border: none;
    padding: 30px 30px;
    border-radius: 50%;
    box-shadow: 0 0 15px rgba(0, 255, 255, 0.6);
    cursor: pointer;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    animation: floatUpDown 2s ease-in-out infinite;
    z-index: 1000;
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
    const targetTop = scrollY + window.innerHeight - 200;
    floatBtn.style.top = targetTop + 'px';
});

floatBtn.addEventListener('click', function () {
    window.location.href = '/chatBot';
});
</script>

// ストップウォッチのスタート
function startStopwatch() {
    const startTime = Date.now();
    localStorage.setItem('stopwatchStart', startTime);

    updateStopwatch(); // 表示更新を開始
}

// ストップウォッチをクリア
function clearStopwatch() {
    localStorage.removeItem('stopwatchStart');
    document.getElementById('stopwatch').textContent = "0.000 秒";
}

// ストップウォッチの表示更新
function updateStopwatch() {
    const startTime = parseInt(localStorage.getItem('stopwatchStart'), 10);

    if (!startTime) {
        document.getElementById('stopwatch').textContent = "0.000 秒";
        return;
    }

    const elapsedTime = (Date.now() - startTime) / 1000; // ミリ秒から秒に変換
    document.getElementById('stopwatch').textContent = elapsedTime.toFixed(3) + " 秒"; // 小数点以下3桁まで表示

    // 1フレームごとに更新
    requestAnimationFrame(updateStopwatch);
}

function clearCookie() {
    console.log("clearCookie")
    document.cookie = "q=; max-age=0"
}
// ページ読み込み時にストップウォッチを復元
document.addEventListener('DOMContentLoaded', () => {
    if (localStorage.getItem('stopwatchStart')) {
        updateStopwatch();
    }
});

// 使用例: HTMLボタンと連携
document.getElementById('startButton').addEventListener('click', startStopwatch);
document.getElementById('clearButton').addEventListener('click', clearStopwatch);
document.getElementById('clearCookieButton').addEventListener('click', clearCookie);

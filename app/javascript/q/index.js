// ストップウォッチのスタート
function startStopwatch() {
    const startTime = Date.now();
    localStorage.setItem('stopwatchStart', startTime);
    updateStopwatch(); // 表示更新を開始
}

// ストップウォッチをクリア
function clearStopwatch() {
    const sw = document.getElementById('stopwatch');
    localStorage.removeItem('stopwatchStart');
    sw.textContent = "0.00 秒";
}

// ストップウォッチの表示更新
function updateStopwatch() {
    const sw = document.getElementById('stopwatch');
    const startTime = parseInt(localStorage.getItem('stopwatchStart'), 10);

    if (!sw) {
        return
    }
    
    if (!startTime) {
        sw.textContent = "0.00 秒";
        return;
    }

    const elapsedTime = (Date.now() - startTime) / 1000; // ミリ秒から秒に変換
    sw.textContent = elapsedTime.toFixed(2) + " 秒"; // 小数点以下3桁まで表示

    // 1フレームごとに更新
    requestAnimationFrame(updateStopwatch);
}

document.addEventListener('turbo:load', () => {
    // 問題画面での処理
    if (document.getElementById('stopwatch')) {
        // ストップウォッチ
        if (!localStorage.getItem('stopwatchStart')) {
            startStopwatch(); // 初回訪問時に開始
        } else {
            updateStopwatch(); // 再訪問時に更新
        }
    }
    // クリアボタン
    const cl = document.getElementById('clearButton')
    if (cl) {
        cl.addEventListener('click', () => {
            localStorage.removeItem('stopwatchStart');
        })
    }
    // ギブアップ画面での処理
    if (document.getElementById("giveup")) {
        localStorage.removeItem('stopwatchStart');
    }
});


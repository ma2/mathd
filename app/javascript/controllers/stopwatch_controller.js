import { Controller } from "@hotwired/stimulus"
import { get, post } from "@rails/request.js"

// 画面表示の更新間隔 (ms)
const UPDATE_INTERVAL = 10

export default class extends Controller {
  static targets = ["display", "complete", "failure"]

  initialize() {
    console.log("initialize")
  }

  async connect() {
    console.log("connect")
    // // 1) localStorage に匿名ユーザー用トークンがあるか確認
    // this.token = localStorage.getItem("stopwatchToken")
    // if (!this.token) {
    //   // なければ生成 (UUID相当のランダム文字列)
    //   this.token = crypto.randomUUID()
    //   localStorage.setItem("stopwatchToken", this.token)
    // }

    // // 2) サーバーから現在の状態を取得
    // // Request.js の get() は CSRFトークンも含めて自動的にリクエストする
    // // responseKind: 'json' を指定すると parse された JSON が得られる
    // const response = await get(`/stopwatch?token=${this.token}`, { responseKind: "json" })
    // if (response.ok) {
    //   const data = await response.json
    //   this.baseElapsedMs = data.current_elapsed_milliseconds
    //   this.lastUpdateTime = performance.now()

    //   // running が false なら自動スタート (要件次第で不要なら削除)
    //   if (!data.running) {
    //     await this.startStopwatch()
    //   }

    //   // 3) 画面表示の定期更新を開始
    //   if (data.running) {
    //     this.startUpdatingDisplay()
    //   }
    // } else {
    //   // エラー時の処理 (任意)
    //   console.error("Failed to fetch initial status", response)
    // }
  }

  async displayTargetConnected(target) {
    console.log("displayTargetConnected")
    // 1) localStorage に匿名ユーザー用トークンがあるか確認
    this.token = localStorage.getItem("stopwatchToken")
    if (!this.token) {
      // なければ生成 (UUID相当のランダム文字列)
      this.token = crypto.randomUUID()
      localStorage.setItem("stopwatchToken", this.token)
    }

    // 2) サーバーから現在の状態を取得
    // Request.js の get() は CSRFトークンも含めて自動的にリクエストする
    // responseKind: 'json' を指定すると parse された JSON が得られる
    const response = await get(`/stopwatch?token=${this.token}`, { responseKind: "json" })
    if (response.ok) {
      const data = await response.json
      this.baseElapsedMs = data.current_elapsed_milliseconds
      this.lastUpdateTime = performance.now()

      // running が false なら自動スタート (要件次第で不要なら削除)
      if (!data.running) {
        await this.startStopwatch()
      }

      // 3) 画面表示の定期更新を開始
      if (data.running) {
        this.startUpdatingDisplay()
      }
    } else {
      // エラー時の処理 (任意)
      console.error("Failed to fetch initial status", response)
    }
  }

  async completeTargetConnected(target) {
    console.log("completeTargetConnected")
    await this.resetStopwatch()
    this.stopUpdatingDisplay()
  }

  async failureTargetConnected(target) {
    console.log("failureTargetConnected")
  }

  async disconnect() {
    console.log("disconnect")
    // Stimulusコントローラが外れるときにインターバルを停止
    // await this.resetStopwatch()
    // this.stopUpdatingDisplay()
  }

  // ---------------------------------------------------
  // ストップウォッチ操作
  // ---------------------------------------------------
  async startStopwatch() {
    // Request.js の post()
    const response = await post(`/stopwatch/start?token=${this.token}`, {
      responseKind: "json"
    })
    if (response.ok) {
      const data = await response.json
      this.baseElapsedMs = data.current_elapsed_milliseconds
      this.lastUpdateTime = performance.now()
      this.startUpdatingDisplay()
    }
  }

  async stopStopwatch() {
    const response = await post(`/stopwatch/stop?token=${this.token}`, {
      responseKind: "json"
    })
    if (response.ok) {
      const data = await response.json
      this.stopUpdatingDisplay()
    }
  }

  async resetStopwatch() {
    const response = await post(`/stopwatch/reset?token=${this.token}`, {
      responseKind: "json"
    })
    if (response.ok) {
      const data = await response.json
      this.updateDisplayDirect(data.current_elapsed_milliseconds)
    }
  }

  async giveup() {
    this.resetStopwatch()
    location.href = "/q/giveup"
  }

  async retry() {
    location.href = "/q/start"
  }

  // ---------------------------------------------------
  // 画面表示更新ロジック
  // ---------------------------------------------------
  startUpdatingDisplay() {
    if (!this.timer) {
      this.timer = setInterval(() => this.updateDisplay(), UPDATE_INTERVAL)
    }
  }

  stopUpdatingDisplay() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }

  updateDisplay() {
    const now = performance.now()
    const delta = now - this.lastUpdateTime
    const current = this.baseElapsedMs + delta
    this.displayTarget.textContent = this.formatMilliseconds(current)
  }

  updateDisplayDirect(serverMs) {
    this.displayTarget.textContent = this.formatMilliseconds(serverMs)
    this.baseElapsedMs = serverMs
    this.lastUpdateTime = performance.now()
  }

  // ---------------------------------------------------
  // ミリ秒 → 表示文字列変換
  // ---------------------------------------------------
  formatMilliseconds(ms) {
    const totalSeconds = Math.floor(ms / 1000)
    const minutes = Math.floor(totalSeconds / 60)
    const seconds = totalSeconds % 60
    const msec = Math.floor(ms % 1000)

    const mm = String(minutes).padStart(2, "0")
    const ss = String(seconds).padStart(2, "0")
    const xxx = String(msec).padStart(3, "0")

    return `${totalSeconds}.${xxx}`
  }
}
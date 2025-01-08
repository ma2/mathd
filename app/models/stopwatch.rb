class Stopwatch < ApplicationRecord
  # -- バリデーション（必要に応じて）
  validates :anonymous_user_token, presence: true

  # -- 現在の実際の経過ミリ秒を計算して返すメソッド
  def current_elapsed_milliseconds
    if running?
      elapsed_milliseconds + ((Time.current - started_at) * 1000).to_i
    else
      elapsed_milliseconds
    end
  end

  # -- 開始
  # runningをtrueにする
  def start!
    return if running?

    update!(
      running: true,
      started_at: Time.current
    )
  end

  # -- 停止
  # 経過時間を記録する
  # runningをfalseにする
  def stop!
    return unless running?

    now = Time.current
    update!(
      elapsed_milliseconds: elapsed_milliseconds + ((now - started_at) * 1000).to_i,
      running: false
    )
  end

  # -- リセット
  # 経過時間を0にする
  # runningをfalseにする
  def reset!
    update!(
      running: false,
      elapsed_milliseconds: 0,
      started_at: nil
    )
  end
end

class StopwatchesController < ApplicationController
  before_action :set_stopwatch

  # GET /stopwatch
  def show
    render json: {
      running: @stopwatch.running,
      current_elapsed_milliseconds: @stopwatch.current_elapsed_milliseconds
    }
  end

  # POST /stopwatch/start
  def start
    @stopwatch.start!
    render_json_state
  end

  # POST /stopwatch/stop
  def stop
    @stopwatch.stop!
    render_json_state
  end

  # POST /stopwatch/reset
  def reset
    @stopwatch.reset!
    render_json_state
  end

  private

  def set_stopwatch
    # フロントが送ってくる token (パラメータ) を取得
    token = params[:token]

    # token が無い場合は 400エラーなど返してもよい
    # ここでは「token が無いなら新しく作る」という挙動にしてもOK
    if token.blank?
      # 例: 400 Bad Request
      render json: { error: "Token is missing" }, status: :bad_request
      return
    end

    # Stopwatch を (anonymous_user_token) で検索 or 作成
    @stopwatch = Stopwatch.find_or_create_by!(anonymous_user_token: token) do |sw|
      # 新規作成の場合は初期値を設定
      sw.running = false
      sw.elapsed_milliseconds = 0
      sw.started_at = nil
    end
  end

  def render_json_state
    render json: {
      running: @stopwatch.running,
      current_elapsed_milliseconds: @stopwatch.current_elapsed_milliseconds
    }
  end
end

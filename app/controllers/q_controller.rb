class QController < ApplicationController
  def index
    @rexp = session[:rexp]
    @lexp = session[:lexp]
    @disabled = session[:disabled]
    @buttons = session[:buttons]
    @shake = "noshake"
    @complete = "invisible"
    @wrong = "invisible"
    # セッションにlexp（ユーザ入力）が入っていなければ初期化する
    if session[:result].blank? || session[:result] == "init"
      # タイマースタート
      # 日時を取得（タイムゾーン依存）
      now = get_now
      # Questionテーブルから右辺を取得
      @rexp = get_rexp(now)
      @buttons = now.split("") + "＋－×÷".split("")
      @lexp = ""
      # ボタンの活性、非活性の配列
      init_disabled
      session[:buttons] = @buttons
      session[:lexp] = @lexp
      session[:rexp] = @rexp
      session[:disabled] = @disabled
      session[:click_history] = []
    elsif session[:result] == "retry"
      init_disabled
      @lexp = ""
      session[:lexp] = ""
      session[:disabled] = @disabled
      session[:click_history] = []
    end
    # 結果間違っているなら初期に戻す
    if session[:result] == "wrong"
      @shake = "shake"
      @wrong = "visible"
      puts session[:value]
      @value = session[:value].end_with?("/1") ? session[:value].to_i : session[:value]
      session[:result] = "retry"
    end
    # 許容できない選択の場合は画面を揺らす
    if session[:result] == "error"
      @shake = "shake"
    end
    # 正解したら表示する
    if session[:result] == "complete"
      @complete = "visible"
      reset_session
    end
  end

  def update
    # クリックしたボタンと式から新しい式を作り評価する
    params.permit([ :clicked ])
    clicked = params[:clicked].to_i
    click_history = session[:click_history] || []
    # BSクリックの場合、クリック履歴を1つ戻す
    if clicked == 100
      click_history.pop
      new_lexp = session[:lexp][0..-2]
    else
      click_history << clicked
      new_lexp = session[:lexp] + session[:buttons][clicked]
    end
    session[:result] = false
    # ユーザー入力式が不正なら何もせずに:errorで返す
    unless lexp_is_good(new_lexp)
      session[:result] = :error
      redirect_to action: :index
      return
    end
    # click_historyからクリック済みボタンのdisableをtrueに設定する
    init_disabled
    click_history.each do |clicked|
      @disabled[clicked] = true if clicked < 8
    end
    session[:disabled] = @disabled
    session[:lexp] = new_lexp
    session[:click_history] = click_history
    # まだ入力途中なら:continueで返す
    unless input_done(new_lexp)
      session[:result] = :continue
      redirect_to action: :index
      return
    end
    # 入力完了。検算する
    disable_operation
    session[:disabled] = @disabled
    result, value = all_ok(new_lexp, session[:rexp])
    session[:result] = result ? :complete : :wrong
    session[:value] = value
    redirect_to action: :index
  end

  def ranking
  end

  def giveup
    reset_session
  end

  private

  # ボタンを初期化する
  def init_disabled
    @disabled = [ false, false, false, false, false, false, false, false, false, false, false, false ]
  end

  # 加減乗除とBSを非活性にする
  def disable_operation
    @disabled[8..12] = [ true, true, true, true, true ]
  end

  def get_now(tz = "Asia/Tokyo")
    Time.use_zone(tz) { Time.zone.now.strftime("%m%d%H%M") }
  end

  def get_rexp(now)
    q = Question.find_by(date: now)
    q.value
  end

  #
  # 式がルール通りか
  def lexp_is_good(exp)
    # 0で始まる数字
    return nil if exp.match?(/(^|[＋－×÷])0[0-9]/)
    # * 0 または / 0
    return nil if exp.match?(/[×÷]0/)
    # 演算子 0 *
    # 演算子 0 /
    return nil if exp.match?(/(^|[＋－])0[×÷]/)
    # 連続演算子
    return nil if exp.match?(/[＋－×÷][＋－×÷]/)
    # 行頭演算子
    return nil if exp.match?(/^[＋－×÷]/)
    true
  end

  # expの評価結果がexpにあるかどうかと, 計算結果を返す
  # 例外時にはnil, nil
  def all_ok(exp, rexp)
    e_exp = to_evalable(exp)
    result = eval(e_exp)
    return (result == rexp), result
  rescue RuntimeError
    return nil, nil
  end

  # eval可能な式に変換する
  def to_evalable(expression)
    # 数値（整数）を検出し、末尾に `r` を追加
    result = expression.gsub(/(\d+)/, '\1r')
    # 加減乗除を変換
    result.tr("＋－×÷", "+\\-*/")
  end

  # 式入力が完了していればtrue
  def input_done(exp)
    # 演算子を削除して8文字なら完了
    exp.delete("＋－×÷").size == 8
  end
end

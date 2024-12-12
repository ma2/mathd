class QController < ApplicationController
  def index
    @rexp = session[:rexp]
    @lexp = session[:lexp]
    @disabled = session[:disabled]
    @buttons = session[:buttons]
    @cls = "noshake"
    @visible = "invisible"
    # cookieにqが入っていなければ初期化する
    if session[:lexp].blank?
      # タイマースタート
      # 日時を取得（タイムゾーン依存）
      now = get_now
      # Questionテーブルから答えを取得
      @rexp = get_rexp(now)
      @buttons = now.split("") + "＋－×÷".split("")
      @lexp = ""
      # ボタンの活性、非活性の配列
      @disabled = [ false, false, false, false, false, false, false, false, false, false, false, false ]
      session[:buttons] = @buttons
      session[:lexp] = @lexp
      session[:rexp] = @rexp
      session[:disabled] = @disabled
    else
      i = session[:clicked].to_i
      @buttons = session[:buttons]
      # 加減乗除は何度でも使えるので非活性にならない
      @disabled[i] = true if i < 8
    end
    puts "--result--"
    puts session[:result]
    # 結果間違っているなら初期に戻す
    if session[:result] == "wrong"
      @cls = "shake"
      @lexp = ""
      @disabled = [ false, false, false, false, false, false, false, false, false, false, false, false ]
      session[:lexp] = @lexp
      session[:disabled] = @disabled
    end
    # 許容できない選択の場合
    if session[:result] == "error"
      @cls = "shake"
    end
    if session[:result] == "complete"
      @cls = "shake"
      @visible = "visible"
      reset_session
    end
    puts "continue"
  end

  def update
    # クリックしたボタンと式から新しい式を作る
    # 式がvalidならresult=true、lexp=新しい式、button=クリックしたボタン
    # invalidならresult=false、lexp=元の式、button=クリックしたボタン
    # をCookieに格納して、indexにredirect
    params.permit([ :clicked ])
    i = params[:clicked].to_i
    buttons = session[:buttons]
    new_lexp = session[:lexp] + buttons[i]
    session[:result] = false
    # ユーザー入力式が不正なら何もせずに:errorで返す
    puts new_lexp
    unless lexp_is_good(new_lexp)
      puts "lexp_is_bad"
      session[:result] = :error
      redirect_to action: :index
      return
    end
    session[:lexp] = new_lexp
    session[:clicked] = i
    session[:disabled][i] = true if i < 8
    # まだ入力途中なら:continueで返す
    unless input_done(new_lexp)
      session[:result] = :continue
      redirect_to action: :index
      return
    end
    session[:result] = all_ok(new_lexp, session[:rexp]) ? :complete : :wrong
    redirect_to action: :index
  end

  def ranking
  end

  def giveup
    reset_session
  end

  def get_now
    "10291334"
  end

  def get_rexp(now)
    86
  end

  # 式がルール通りか
  def lexp_is_good(exp)
    # 0で始まる数字
    return nil if exp.match?(/(^|[＋－×÷])0[0-9]/)
    # * 0 または / 0
    return nil if exp.match?(/[×÷]0/)
    # 演算子 0 *
    # 演算子 0 /
    return nil if exp.match?(/[＋－×÷]0[×÷]/)
    # 連続演算子
    return nil if exp.match?(/[＋－×÷][＋－×÷]/)
    # 行頭演算子
    return nil if exp.match?(/^[＋－×÷]/)
    true
  end

  # expを評価してrexpになればtrue
  def all_ok(exp, rexp)
    e_exp = to_evalable(exp)
    result = eval(e_exp)
    puts result
    result == rexp
  rescue RuntimeError
    nil
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

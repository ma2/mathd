class QController < ApplicationController
  def index
    @rexp = session[:rexp]
    @lexp = session[:exression]
    @disabled = session[:disabled]
    # cookieにqが入っていなければ初期化する
    if session[:numbers].blank?
      # タイマースタート
      # 日時を取得（タイムゾーン依存）
      now = get_now
      # Questionテーブルから答えを取得
      @rexp = get_rexp(now)
      @numbers = now.split("") + "＋－×÷".split("")
      @lexp = ""
      # ボタンの活性、非活性の配列
      @disabled = [ false, false, false, false, false, false, false, false, false, false, false, false ]
      session[:numbers] = @numbers
      session[:lexp] = @lexp
      session[:rexp] = @rexp
      session[:disabled] = @disabled
    else
      i = session[:clicked].to_i
      @numbers = session[:numbers]
      # 加減乗除は何度でも使えるので非活性にならない
      @disabled[i] = true if i < 8
    end
    # 結果OK
    if session[:result]
      # 式を新しいものに置き換え
      @lexp = session[:lexp]
    end
  end

  def update
    # クリックしたボタンと式から新しい式を作る
    # 式がvalidならresult=true、lexp=新しい式、button=クリックしたボタン
    # invalidならresult=false、lexp=元の式、button=クリックしたボタン
    # をCookieに格納して、indexにredirect
    params.permit([ :numbers, :clicked, :lexp ])
    i = params[:clicked].to_i
    numbers = session[:numbers]
    new_exp = session[:lexp] + numbers[i]
    session[:result] = false
    if lexp_is_good(new_exp)
      session[:result] = true
      session[:clicked] = i
      session[:lexp] = new_exp
    end
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
    110
  end

  # 式がルール通りか
  def lexp_is_good(exp)
    # 行頭の0 *
    # 行頭の0 /
    return nil if exp.match?(/^0[\*\/]/)
    # * 0 または /0
    return nil if exp.match?(/[\*\/]0/)
    # 演算子 0 *
    # 演算子 0 /
    return nil if exp.match?(/[\+\-\*\/]0[\*\/]/)
    # 連続演算子
    return nil if exp.match?(/[\+\-\*\/][\+\-\*\/]/)
    # 行頭演算子
    return nil if exp.match?(/^[\+\-\*\/]/)
    true
  end

  # expを評価してrexpになればtrue
  def result_is_correct(exp, rexp)
    true
  end

  # 式入力が完了していればtrue
  def lexp_completed?(exp)
    # 演算子を削除して8文字なら完了
    exp.delete("+\-*/").size == 8
  end
end

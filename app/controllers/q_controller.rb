class QController < ApplicationController
  def start
    restore_from_session
    @shake = "noshake"
    # resultがerrorまたはcontinue以外なら初期化する
    if @result != "error" && @result != "continue"
      logger.debug("--init--")
      @result = ""
      # ボタンをすべて活性に初期化
      init_disabled
      # 日時を取得
      now = get_now
      # Questionテーブルから右辺を取得
      @rexp = get_rexp(now)
      @buttons = now.split("") + "＋－×÷".split("")
      @lexp = ""
      @click_history = []
    end

    # 許容できない選択の場合は画面を揺らす
    if @result == "error"
      @shake = "shake"
    end

    # result==continueの場合は何もしない
    save_to_session
  end

  def update
    # 他のアクションとインスタンス変数は共有されないのでセッションから復元
    restore_from_session
    # クリックしたボタンと式から新しい式を作り評価する
    params.permit([ :clicked, :authenticity_token ])
    clicked = params[:clicked].to_i
    # click_history = session[:click_history] || []
    # BSクリックの場合、クリック履歴を1つ戻す
    if clicked == 100
      @click_history.pop
      new_lexp = @lexp[0..-2]
    else
      @click_history << clicked
      new_lexp = @lexp + @buttons[clicked]
    end
    # ユーザー入力式が不正なら何もせずに"error"で返す
    unless lexp_is_good(new_lexp)
      @result = "error"
      save_to_session
      redirect_to action: :start
      return
    end
    # click_historyからクリック済みボタンのdisableをtrueに設定する
    init_disabled
    @click_history.each do |clicked|
      @disabled[clicked] = true if clicked < 8
    end
    @lexp = new_lexp
    # @click_history = click_history
    # まだ入力途中なら"continue"で返す
    unless input_done(new_lexp)
      @result = "continue"
      save_to_session
      redirect_to action: :start
      return
    end
    # 入力完了。検算する
    disable_operation
    @result, @value = all_ok(@lexp, @rexp)
    save_to_session
    if @result == "complete"
      redirect_to action: :complete
      return
    end
    redirect_to action: :failure
  end

  def complete
    restore_from_session
    if @result != "complete"
      # エラーにする
      render plain: "ERR: not complete but #{@result}", status: :unprocessable_entity
    end
    # 正解ならランキングに保存する
    question = Question.find(session[:qid])
    @ranking = question.rankings.create(rexp: @rexp, lexp: @lexp, seconds: 12.3)
    reset_session
  end

  def failure
    restore_from_session
    if @result != "failure"
      # エラーにする
      render plain: "ERR: not failure but #{@result}", status: :unprocessable_entity
    end
    @value = @value.end_with?("/1") ? @value.to_i : @value
    @click_history = []
    # retry用にセッションを変えておく
    @result = "retry"
    save_to_session
  end

  def retry
    restore_from_session
    if @result != "retry"
      # エラーにする
      render plain: "ERR: not retry but #{@result}", status: :unprocessable_entity
    end
    # BSボタンをすべて活性に初期化
    init_disabled
    @lexp = ""
    save_to_session
  end

  def ranking
  end

  def giveup
    reset_session
  end

  private

  # トークンを生成する
  def create_token
    @token = cookies.signed[:anonymous_token]
    if @token.blank?
      @token = SecureRandom.uuid
      # Cookie に保存 (暗号化 or 署名のため signed Cookie)
      cookies.signed[:anonymous_token] = {
        value: token,
        httponly: true,
        expires: 30.day.from_now
      }
    end
  end
  # ボタンを初期化する
  def init_disabled
    @disabled = [ false, false, false, false, false, false, false, false, false, false, false, false ]
  end

  # 加減乗除とBSを非活性にする
  def disable_operation
    @disabled[8..12] = [ true, true, true, true, true ]
  end

  # インスタンス変数の内容をセッションに反映する
  def save_to_session
    session[:qid] = @q.id if @q
    session[:lexp] = @lexp
    session[:rexp] = @rexp
    session[:value] = @value
    session[:result] = @result
    session[:buttons] = @buttons
    session[:disabled] = @disabled
    session[:click_history] = @click_history || []
  end

  # セッションの内容をインスタンス変数に反映する
  def restore_from_session
    @qid = session[:qid]
    @rexp = session[:rexp]
    @lexp = session[:lexp]
    @value = session[:value]
    @result = session[:result]
    @buttons = session[:buttons]
    @disabled = session[:disabled]
    @click_history = session[:click_history]
  end

  def get_now(tz = "Asia/Tokyo")
    Time.use_zone(tz) { Time.zone.now.strftime("%m%d%H%M") }
  end

  def get_rexp(now)
    @q = Question.find_by(date: now)
    @q.value
  end

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
    return (result == rexp ? "complete" : "failure"), result
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

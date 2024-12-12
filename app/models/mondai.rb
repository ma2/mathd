class Mondai
  attr_accessor :buttons, :disabled, :rexp, :lexp, :clicked, :result

  def initialize
    # 日時を取得（タイムゾーン依存）
    now = get_now
    @buttons = now.split("") + "＋－×÷".split("")
    @disabled = [ false, false, false, false, false, false, false, false, false, false, false, false ]
    @rexp = get_rexp(now)
    @lexp = ""
    @clicked = ""
    @result = :continue
  end

  def self.new_from_session
    session[:mondai] || new
  end

  # 現状を評価して、変数を更新する
  def update(clicked)
    # ユーザー入力式が不正なら何もせずに:errorで返す
    new_lexp = @lexp + @buttons[clicked]
    unless validate_lexp(new_lexp)
      @result = :error
      session[:mondai] = self
      return
    end
    @lexp = new_lexp
    @clicked = clicked
    @disabled[clicked] = true if clicked < 8
    # まだ入力途中なら:continueで返す
    unless input_done
      @result = :continue
      session[:mondai] = self
      return
    end
    # 入力完成していればユーザー入力式の評価結果をセットして返す
    @result = all_ok ? :complete : :wrong
    session[:mondai] = self
  end

  # 式がルール通りか
  def validate_lexp(exp)
    # 行頭の0 *
    # 行頭の0 /
    return nil if lexp.match?(/^0[\*\/]/)
    # * 0 または /0
    return nil if lexp.match?(/[\*\/]0/)
    # 演算子 0 *
    # 演算子 0 /
    return nil if lexp.match?(/[\+\-\*\/]0[\*\/]/)
    # 連続演算子
    return nil if lexp.match?(/[\+\-\*\/][\+\-\*\/]/)
    # 行頭演算子
    return nil if lexp.match?(/^[\+\-\*\/]/)
    true
  end

  # @lexpを評価して@rexpと等しければtrue
  def all_ok
    # lexpのすべての演算子の前に「r」を入れ、evalする
    # 結果が @rexpと等しければtrue、それ以外はfalse
    true
  rescue RuntimeError
    nil
  end

  def add_r_to_numbers(expression)
    # 数値（整数）を検出し、末尾に `r` を追加
    expression.gsub(/(\d+)/, '\1r')
  end

  # 式入力が完了していればtrue
  def input_done
    # 演算子を削除して8文字なら完了
    @lexp.delete("+\-*/").size == 8
  end

  # セッションをリセットする
  def self.reset
    reset_session
  end
end

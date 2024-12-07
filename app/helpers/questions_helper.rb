module QuestionsHelper
  # 現在時刻をmmddHHMM形式の文字列に変換する
  # @param timezone [String] タイムゾーン（デフォルト: 'Asia/Tokyo'）
  # @return [String] mmddHHMM形式の文字列
  def current_time_str(timezone = "Asia/Tokyo")
    Time.use_zone(timezone) { Time.zone.now.strftime("%m%d%H%M") }
  end

  # mmddHHMM形式の文字列を数値の配列に変換する
  # @param date_str [String] mmddHHMM形式の文字列
  # @return [Array<Integer>] 数値の配列
  def date_to_a(date_str)
    date_str.chars.map(&:to_i)
  end

  # 整数の配列を受け取り、ランダムに並び替え、加減乗除記号を要素間にランダムに挿入した式を生成する
  # 数値の末尾には「r」を追加する
  # @param numbers [Array<Integer>] 整数の配列
  # @return [String] 生成した式の文字列
  def add_operators(numbers)
    operators = %w[+ - * /]
    # operators2 = %w[+ -]
    result = []
    part_nums = []

    # numbersに0があるときかけ算は使えない
    # operators = numbers.include?(0) ? operators2 : operators

    # ランダムに並び替え
    shuffled_numbers = numbers.shuffle

    shuffled_numbers.each_with_index do |num, index|
      result << num
      part_nums << num

      # 最後の要素でない場合に処理を行う
      if index < shuffled_numbers.size - 1
        # 数値が2つ続いていたら演算子を挿入
        # 0始まりなら演算子を挿入
        if part_nums.size > 1 || part_nums == [ 0 ]
          # 数値をRationalにするためrを挿入
          result << "r"
          result << operators.sample
          part_nums.clear
        # 50%の確率で演算子を挿入
        elsif rand < 0.5
          # 数値をRationalにするためrを挿入
          result << "r"
          result << operators.sample
          part_nums.clear
        end
      end
    end
    result.join
  end

  # 式がルール通りか検証する
  # 0を乗算する、0を除算するのはNG
  def expression_is_good(exp)
    # 行頭の0r *
    # 行頭の0r /
    return nil if exp.match?(/^0r[\*\/]/)
    # 行末の*0（手を抜いてrを付けていないため）
    return nil if exp.match?(/\*0$/)
    # * 0r
    return nil if exp.include?("*0r")
    # * /0r
    return nil if exp.include?("/0r")
    # 演算子 0r *
    # 演算子 0r /
    return nil if exp.match?(/[\+\-\*\/]0r[\*\/]/)
    # 連続演算子
    return nil if exp.match?(/[\+\-\*\/][\+\-\*\/]/)
    # 行頭演算子
    return nil if exp.match?(/^[\+\-\*\/]/)
    true
  end

  # mmddHHMM形式の文字列から式を作り、評価して整数の答えとなればその式と答えを返す
  # 答えの範囲は-9～9
  def mk_expression(time_str)
    loop do
      # time_str = current_time_str
      numbers = date_to_a(time_str)
      exp = add_operators(numbers)
      next unless expression_is_good(exp)
      begin
        result = eval(exp)
      rescue ZeroDivisionError
        next
      end
      # if result.denominator == 1 && result <= 10r && result >= 0r
      if result.denominator == 1 && [ 0r, 1r, 10r, 11r, 100r, 110r, 111r ].include?(result)
        return time_str, exp, result
      end
    end
  end
end

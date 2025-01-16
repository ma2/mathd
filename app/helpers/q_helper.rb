module QHelper
  def format_value(value)
    v = value.to_s
    return "" if v.blank?
    v = v[0..-3] if v.end_with?("/1")
    "　= #{v}"
  end
end

class DateTime

  # Makes sure that DateTime are exported with ISO8601
  # conventions when using to_json and to_csv
  def to_s(*args)
    iso8601
  end

end

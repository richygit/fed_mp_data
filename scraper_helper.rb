module ScraperHelper
  def senator_key(last_name, state)
    "#{last_name}-#{state}"
  end

  def mp_key(last_name, electorate)
    "#{last_name}-#{electorate}"
  end
end

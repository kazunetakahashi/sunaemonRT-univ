class Result
  require 'twitter'
  require 'time'
  require 'active_support/all'
  attr_accessor :hash, :retweeted, :time, :id, :url

  def initialize(hash, retweeted, time, id, url)
    if !(hash["adult"].nil?) &&
       !(hash["adult"]["isAdultContent"].nil?) &&
       !(hash["adult"]["isRacyContent"].nil?)
      @hash = hash
    else
      @hash = nil
    end
    @retweeted = retweeted
    @time = time.in_time_zone("Tokyo")
    @id = id.to_i
    @url = url.to_s
  end

  def to_s()
    ans = {}
    ans[:hash] = @hash
    ans[:retweeted] = @retweeted
    ans[:time] = @time.in_time_zone("Tokyo").to_s
    ans[:id] = @id.to_i
    ans[:url] = @url.to_s
    return ans.to_s
  end

  def Result.hash_to_result(from)
    h = from[:hash]
    if h.nil? || h == ""
      return nil
    end
    return Result.new(h,
                      from[:retweeted],
                      Time.parse(from[:time]).in_time_zone("Tokyo"),
                      from[:id].to_i,
                      from[:url].to_s)
  end

  def is_picture?()
    return !(@hash.nil?)
  end

  def appropriate?()
    return is_picture?() &&
           !@hash["adult"]["isAdultContent"] &&
           !@hash["adult"]["isRacyContent"]
  end

  def retweetable?()
    return appropriate?() && !retweeted
  end

  def adult?()
    return is_picture?() &&
           @hash["adult"]["isAdultContent"]
  end

  def racy?()
    return is_picture?() &&
           !@hash["adult"]["isAdultContent"] &&
           @hash["adult"]["isRacyContent"]
  end

end

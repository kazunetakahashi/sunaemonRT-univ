# coding: utf-8
class SunaemonRT
  require 'twitter'
  require 'active_support/all'
  require './loadkey.rb'
  include LoadKey
  load './result.rb'
  load './computervision.rb'

  attr_accessor :client, :dic, :cv
  # dic["20170420"][(int tweet id)] = [result, result2, \dots ]

  def initialize()
    @client = Twitter::REST::Client.new {|config|
      config.consumer_key = load_key("twitter-consumer-key.txt")
      config.consumer_secret = load_key("twitter-consumer-secret.txt")
      config.access_token = load_key("twitter-access-token.txt")
      config.access_token_secret = load_key("twitter-access-token-secret.txt")
    }
    read_dic()
    @cv = ComputerVision.new()
  end

  def work()
    read_dic()
    check()
    write_dic()
    retweet()
    write_dic()
  end

  def report()
    read_dic()
    tweet_report()
  end

  def check()
    retweets = @client.retweeted_by_user("sunaemonRT")
    retweets.each{|tweet|
      if tweet.created_at < Time.now - 2.day
        next
      end
      str = SunaemonRT.daystr(tweet.created_at)
      if count_pictures(str) >= 100
        next
      end
      if @dic[str].has_key?(tweet.id) || !tweet.media?
        next
      end
      ary = []
      ok = true
      tweet.media.each{|md|
        if md.class == Twitter::Media::Photo
          url = md.media_uri.to_s
          begin
            sleep(1)
            hash = @cv.api(url)
            puts "url = #{url}"
            p hash
            ary << Result.new(hash, false, tweet.created_at, tweet.id, url)
          rescue => e
            puts e
            ok = false
          end
        else
          ok = false
        end
        if !ok
          break
        end
      }
      if !ok
        next
      end
      dic[str][tweet.id] = ary
    }
  end

  def retweet()
    @dic.each{|str, ids|
      ids.each{|id, ary|
        ok = true
        ary.each{|res|
          if !res.retweetable?
            ok = false
            break
          end
        }
        if ok
          puts "retweet: #{id}"
          begin
            sleep(1)
            @client.retweet(id)
          rescue => e
            puts e
          end
          ary.each{|res|
            res.retweeted = true
          }
        end
      }
    }
  end

  def tweet_report()
    time = Time.now - 1.hour
    str = SunaemonRT.daystr(time)
    adult = 0
    racy = 0
    app = 0
    dic[str].each{|id, ary|
      level = 0
      ok = true
      ary.each{|res|
        if !(res.is_picture?)
          ok = false
          break
        elsif level < 2 && res.adult?
          level = 2
          break
        elsif level < 1 && res.racy?
          level = 1
        end 
      }
      if ok
        if level == 2
          adult += 1
        elsif level == 1
          racy += 1
        elsif level == 0
          app += 1
        end
      end
    }
    sum = adult + racy + app
    text = "#{time.strftime("%Y 年 %m 月 %d 日")}の @sunaemonRT のリツイートのうち #{sum} 件を判定しました。\n健全: #{app} 件\nきわどい: #{racy} 件\n18 禁: #{adult} 件"
    @client.update(text)
  end

  def read_dic()
    @dic = {}
    now = Time.now
    for i in 0..3
      str = SunaemonRT.daystr(now - i.days)
      path = File.expand_path("../dic/#{str}.txt", __FILE__)
      if FileTest.exist?(path)
        open(path) {|input|
          @dic[str] = eval(input.read.to_s)
        }
        @dic[str].each{|id, val|
          @dic[str][id].map!{|res|
            Result.hash_to_result(eval(res))           
          }
        }
      else
        @dic[str] = {}
      end
    end
  end

  def write_dic()
    @dic.each{|str, ids|
      nids = {}
      ids.each{|id, ary|
        nids[id] = []
        ary.each{|res|
          nids[id] << res.to_s
        }
      }
      path = File.expand_path("../dic/#{str}.txt", __FILE__)
      open(path, 'w') {|output|
        output.write(nids.to_s)
      }
    }
  end

  def count_pictures(str)
    ans = 0
    @dic[str].each{|id, ary|
      ans += ary.size
    }
    return ans
  end

  def follow_return()
    begin
      followers = @client.follower_ids.attrs[:ids]
      followers.each{|id|
        if !@client.friendship?("sunaemonRT_univ", id)
          @client.follow(id)
          sleep(1)
        end
      }
    rescue => e
      puts e
    end
  end

  def SunaemonRT.daystr(time)
    time.strftime("%Y%m%d")
  end
  
end

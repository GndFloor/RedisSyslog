require "redis_syslog/version"

class RedisSyslog::RedisSyslog
  PREFIX = "redis_syslog://"

  def self.list_used_namespaces
    #Return a list of used namespaces
  end

  def initialize(redisrb:, namespace:)
    @redis = redisrb
    @namespace = namespace
  end

  #This is the actual list key
  def _key
    return "#{PREFIX}#{@namespace}"
  end

  def delete!
    @redis.del _key
  end

  def last_n_entries n
    raise "n cannot be 0" unless n > 0
    #Return the last N entries of this log
    results = @redis.zrevrange _key, 0, n-1, :with_scores => true
    results = results.map{|e| {:time => Time.at(e[1]), :message => e[0]} }
  end

  def write message
    @redis.zadd _key, Time.now.to_i, message
  end
end

module RedisSyslog
  def self.new(redisrb:, namespace:)
    return RedisSyslog.new redisrb: redisrb, namespace: namespace
  end
end

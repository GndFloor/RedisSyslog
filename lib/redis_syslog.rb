require "redis_syslog/version"

module RedisSyslog::MessageEncoder
  #Encode a message with a timestamp fit for inserting into a redis set.  This must include the index itself because
  #a non-unique message could end up getting ignored by redis because it's technically a duplicate if the timestamp
  #happened to be the same.
  #We're encoding to INDEX\nTIMESTAMP\nMESSAGE
  def self.encode(index:, timestamp:, message:)
    "#{index}\n#{timestamp}\n#{message}"
  end

  def self.decode(data)
    info = data.split("\n")
    index = info.shift.to_i
    timestamp = info.shift.to_i

    #Retrieve by inverting the rest
    message = data.gsub(self.encode(index: index, timestamp: timestamp, message:""), "")

    return {index: index, timestamp: timestamp, message: message}
  end
end

class RedisSyslog::RedisSyslog
  PREFIX = "redis_syslog://"
  NAMESPACES_LIST_KEY = "redis_syslog://namespaces" #A list of used namespaces

  #First N characters of key are magic random characters because we are using a sorted set
  #to store these lists and redis will not allow two duplicate entries (even with different scores)
  RANDOM_WORD_PREFIX_CHARACTER_COUNT = 8

  #List currently used namespaces
  def namespaces
    return @redis.smembers NAMESPACES_LIST_KEY
  end

  def initialize(redis)
    @redis = redis
  end

  #This is the actual list key
  def _key_for_namespace namespace
    return "#{PREFIX}#{namespace}"
  end

  def delete namespace
    @redis.del _key_for_namespace(namespace)
    @redis.srem NAMESPACES_LIST_KEY, namespace
  end

  def drop_all
    self.namespaces.each do |namespace|
      self.delete namespace
    end

    #For good measure
    @redis.del NAMESPACES_LIST_KEY
  end

  def tail namespace, n=1
    raise "n cannot be 0" unless n > 0
    #Return the last N entries of this log
    results = @redis.zrevrange _key_for_namespace(namespace), 0, n-1

    results.map! do |result|
      result = RedisSyslog::MessageEncoder.decode result
      result[:timestamp] = Time.at(result[:timestamp].to_i)
      result
    end

    results
  end

  def write namespace, message
    index = @redis.zcard(_key_for_namespace(namespace))
    encoded_message = RedisSyslog::MessageEncoder.encode index: @redis.zcard(_key_for_namespace(namespace)), timestamp: Time.now.to_i, message: message

    @redis.zadd _key_for_namespace(namespace), index, encoded_message
    @redis.sadd NAMESPACES_LIST_KEY, namespace
  end
end

module RedisSyslog
  def self.new(redis)
    return RedisSyslog.new redis
  end
end

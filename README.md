RedisSyslog
===================
RedisSyslog is a simple ruby gem that allows ruby to log directly to redis in a high performance environment.  We do rely on [redis-rb](https://github.com/redis/redis-rb "redis-rb"), so go grab a copy if you haven't already!  We originally wrote for Fittr® because our remote scripts needed to be easily checked to see if they were working or not.  We now deploy RedisSyslog as a general purpose logging utility where our many services are able to concurrently log to.

Let's get you started real quick.
-------------

1. Include the gem in your Gemfile
 ```ruby
source "https://rubygems.org"
gem 'redis_syslog'
```

2. Initalize an object.  Or as many as you'd like! Thread safety, hurray!
 ```ruby
#Create a redis-rb intsance
@redis = Redis.new

#Create an instance of RedisSyslog 
@logger = RedisSyslog.new redisrb: @redis
```

3. Profit
 ```ruby
#Write a new entry
@logger.write "com.bar.sobriety", "Ordered a beer"
@logger.write "com.bar.sobriety", "Hiccup!"

#Get last 2 entries
puts @logger.tail "com.bar.sobriety", 2
>[{:index => 1, :timestamp=>2014-1027 18:48:28 -0400, :message => "Hiccup!"},
   {:index => 0, :timestamp=>2014-1027 18:48:28 -0400, :message => "Ordered a beer"}]

#View all namespaces used
puts @logger.namespaces ["com.bar.sobriety"]

#Drop this namespace
@logger.delete "com.bar.sobriety"

#Delete all data including indexes
@logger.drop_all
```

How is it stored?
------------
Each namespace (i.e. each log name) uses the one key with a redis sorted set. `` redis_syslog://#{namespace} ``<br />
Then, we have one index key which contains an unsorted set of keys. `` redis_syslog://namespaces ``

For each entry in the sorted set of some namespace, we follow the simple protocol.
```ruby
 ###########################################################################
 #index     - Number that should be monotonically increasing for each entry
 #timestamp - A time in seconds from unix epoch
 #message   - Your message
 ###########################################################################
 @encoded_message = "#{index}\n#{timestamp}\n#{message}"
```


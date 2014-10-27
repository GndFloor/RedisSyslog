RedisSyslog
===================
RedisSyslog is a simple ruby gem that allows ruby to log directly to redis in a high performance environment.  We do rely on [redis-rb](https://github.com/redis/redis-rb "redis-rb"), so go grab a copy if you haven't already!  We originally wrote for Fittr® because our remote scripts needed to be easily checked to see if they were working or not.  We now deploy RedisSyslog as a general purpose logging utility where our many services are able to concurrently log to.

Let's get you started real quick.
-------------

1. Include the gem in your Gemfile
 
<code>gem 'redis_syslog'</code>
 2. Initalize an object.  Or as many as you'd like! Thread safety, hurray!
 <code>#Create a redis-rb intsance
            @redis = Redis.new<br />
            #Create an instance of RedisSyslog 
            @logger = RedisSyslog.new redisrb: @redis, namespace: "com.fittr.periodic"
            </code>
            <br />
 3. Profit

<code>#Write a new entry<br />
            @logger.write "This is my message"<br />
            #Get last 1 entry
            @logger.last_n_entries(1) #[{:time=>TimeClass, :message => "This is my message"]<br />
      #Delete all entries
      @logger.delete!
            </code>

That's it.  That's the entire API.
------------
How is it stored?  Simple.  Each namespace uses the one key with a redis sorted set.  The key follows this format.

`` redis_syslog://#{namespace} ``

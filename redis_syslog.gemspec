# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis_syslog/version'

Gem::Specification.new do |spec|
  spec.name          = "redis_syslog"
  spec.version       = RedisSyslog::VERSION
  spec.authors       = ["Seo Townsend"]
  spec.email         = ["seotownsend@icloud.com"]
  spec.summary       = %q{A very simple and high performance universal logging utility for ruby and redis.}
  spec.description   = %q{RedisSyslog is a simple ruby gem that allows ruby to log directly to redis in a high performance environment. We do rely on redis-rb, so go grab a copy if you haven't already! We originally wrote for Fittr® because our remote scripts needed to be easily checked to see if they were working or not. We now deploy RedisSyslog as a general purpose logging utility where our many services are able to concurrently log to.}
  spec.homepage      = "https://github.com/GndFloor/RedisSyslog"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end

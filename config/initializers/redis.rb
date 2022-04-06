require 'mock_redis'
$REDIS = Rails.env == 'test' ? MockRedis.new : Redis.new

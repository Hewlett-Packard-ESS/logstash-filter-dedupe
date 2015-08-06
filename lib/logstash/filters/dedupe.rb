require 'logstash/filters/base'
require 'logstash/namespace'
require 'redis'

class LogStash::Filters::DeDupe < LogStash::Filters::Base
  config_name 'dedupe'

  # Filter configuration
  config :keys, :validate => :array

  # Redis configuration
  config :host, :validate => :string,  :default => 'redis'
  config :port, :validate => :number,  :default => 6379
  config :ttl,  :validate => :number,  :default => 30

  public
  def register
  end

  public
  def filter(event)
    return unless filter?(event)

    # Generate a flat hash of the keys in question
    hash = generate_hash(event.to_hash)
    
    # Perform a getset which will determine if we've processed
    # this event already
    previous = redis.getset(hash, 1).to_i

    if previous == 1
      # Tag it because it was already there
      event["tags"] ||= []
      event["tags"] << 'duplicate' unless event["tags"].include?('duplicate')
    end

    # Set the TTL on the key
    redis.expire(hash, @ttl)

    # Dedupe away
    filter_matched(event)
  end

  private
  def redis
    return @redis if not @redis.nil?
    redis_config = {
      :host => @host, 
      :port => @port
    }
    Redis.new(redis_config)
  end

  private
  def generate_hash(event)
    keys = event.slice(*@keys)
    Digest::MD5.hexdigest( keys_flat keys )
  end

  private
  # We need to ensure the keys passed are encoded in
  # a consistent order so the MD5 is the same each time
  def keys_flat(body)
    if body.class == Hash
      arr = []
      body.each do |key, value|
        arr << "#{keys_flat key}=>#{keys_flat value}"
      end
      body = arr
    end
    if body.class == Array
      str = ''
      body.map! do |value|
        keys_flat value
      end.sort!.each do |value|
        str << value
      end
    end
    if body.class != String
      body = body.to_s << body.class.to_s
    end
    body
  end
end

require 'logstash/logging'
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
    $logger ||= LogStash::Logger.new(STDOUT)
  end

  public
  def filter(event)
    return unless filter?(event)
    
    # Perform a getset which will determine if we've processed
    # this event already
    previous = tag_processed(event.to_hash, @keys)

    if previous == 1
      # Tag it because it was already there
      event["tags"] ||= []
      event["tags"] << 'duplicate' unless event["tags"].include?('duplicate')
    end

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
    @redis = Redis.new(redis_config)
    @redis
  end

  private
  # Tags the current event as processed
  # in redis based on the keys were looking for 
  def tag_processed(hash, keys) 
    # Generate a flat md5 of the keys in question
    md5 = generate_md5(hash, keys)
    $logger.info "MD5 Generated: #{md5}"
    previous = redis.getset(md5, 1).to_i
    $logger.info "Previous Redis Value: #{previous}"
    # Set the TTL on the key
    redis.expire(md5, @ttl)
    previous
  end

  private
  # Generates an MD5 sig of the requested keys
  # from the hash of the event
  def generate_md5(hash, keys)
    data = keys.map{|key|
      extract_key(hash, key)
    }
    Digest::MD5.hexdigest( keys_flat data )
  end

  private 
  # Allows for the extraction of keys which are
  # defined in a nested way, for example a.b.c
  def extract_key(obj, key)
    if obj.respond_to?(:key?) && obj.key?(key)
      obj[key]
    elsif obj.respond_to?(:each)
      r = nil
      obj.find{ |*a| r=extract_key(a.last,key) }
      r
    end
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

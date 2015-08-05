require 'logstash/filters/base'
require 'logstash/namespace'

class LogStash::Filters::DeDupe < LogStash::Filters::Base
  config_name 'dedupe'

  config :keys, :validate => :array
  
  public
  def register
  end

  public
  def filter(event)
    return unless filter?(event)

    # Tag
    event["tags"] ||= []
    event["tags"] << 'duplicate' unless event["tags"].include?('duplicate')

    # Dedupe away
    filter_matched(event)
  end
end

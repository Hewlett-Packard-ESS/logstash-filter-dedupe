require 'logstash/devutils/rspec/spec_helper'
require 'logstash/filters/dedupe'
require 'redis'

redis = Redis.new({
  :host => 'redis',
  :port => 6379
})
 
describe LogStash::Filters::DeDupe do

  before(:all) do
    redis.flushall
  end

  describe 'Detects a duplicate' do
    config <<-CONFIG
      filter {
        dedupe {
          keys => ["id"]
        }
      }
    CONFIG

    sample("id" => "abc") do
      insist { subject['tags'] } == nil
    end

    sample("id" => "abc") do
      insist { subject['tags'] } == ['duplicate']
    end
  end

end

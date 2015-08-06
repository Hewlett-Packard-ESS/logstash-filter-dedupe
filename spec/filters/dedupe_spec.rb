require 'logstash/devutils/rspec/spec_helper'
require 'logstash/filters/dedupe'
require 'redis'

redis = Redis.new({
  :host => 'redis',
  :port => 6379
})
 
describe LogStash::Filters::DeDupe do

  base = LogStash::Filters::DeDupe.new({})
  base.register
 
  before(:each) do
    puts "flushing redis"
    redis.flushall
    sleep 1
  end

  context 'top level keys' do
    config <<-CONFIG
      filter {
        dedupe {
          keys => ["id"]
        }
      }
    CONFIG

    test_data = {
      "id" => "1" 
    }
 
    context 'the first one shouldnt be a duplicate' do
      sample(test_data) do
        insist { subject['tags'] } == nil
      end
    end

    context 'the second one should be detected as a duplicate' do
      before(:each) do
        base.tag_processed(test_data, ["id"])
        sleep 1
      end
      sample(test_data) do
        insist { subject['tags'] } == ['duplicate']
      end
    end

  end
end

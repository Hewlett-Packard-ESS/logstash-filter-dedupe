require 'logstash/devutils/rspec/spec_helper'
require 'logstash/filters/dedupe'
require 'redis'

redis = Redis.new({
  :host => 'redis',
  :port => 6379
})
 
describe LogStash::Filters::DeDupe do

  describe 'Detects a duplicate' do
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
 
    sample(test_data) do
      insist { subject['tags'] } == nil
    end

    sample(test_data) do
      insist { subject['tags'] } == ['duplicate']
    end
  end

  describe 'Allows for deep nested keys' do
    config <<-CONFIG
      filter {
        dedupe {
          keys => ["some.key"]
        }
      }
    CONFIG

    test_data = {
      "some" => {
        "key" => "2"
      }
    }
    
    sample(test_data) do
      insist { subject['tags'] } == nil
    end

    sample(test_data) do
      insist { subject['tags'] } == ['duplicate']
    end
  end

end

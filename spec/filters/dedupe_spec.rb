require 'logstash/devutils/rspec/spec_helper'
require 'logstash/filters/dedupe'

describe LogStash::Filters::DeDupe do

  describe 'Detects a duplicate' do
    config <<-CONFIG
      filter {
        dedupe {
          keys => ["id"]
        }
      }
    CONFIG

    sample("id" => "abc") do
      insist { subject['tags'] }.include?('duplicate')
    end
  end

end

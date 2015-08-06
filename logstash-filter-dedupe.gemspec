Gem::Specification.new do |s|

  s.name            = 'logstash-filter-dedupe'
  s.version         = '0.1.0'
  s.licenses        = ['Apache License (2.0)']
  s.summary         = "Dedupes incoming messages on the configured fields"
  s.description     = 'You can specify any number of fields to decide if this message is a duplicate'
  s.authors         = ['Hewlett-Packard-ESS', 'Stono']
  s.email           = 'karl.stoney@hp.com'
  s.homepage        = 'https://www.hp.com' 
  s.require_paths   = ['lib']

  # Files
  s.files = `git ls-files`.split($\)

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", '>= 1.4.0', '< 2.0.0'

  s.add_runtime_dependency 'redis'

  s.add_development_dependency 'logstash-devutils'
end


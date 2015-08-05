__NOTE__: Work in progress and most def not working right now!

# Logstash Dedupe Plugin

This is a plugin for [Logstash](https://github.com/elasticsearch/logstash) which is designed to handle the de-duplication of events coming into a Logstash cluster in a HA architecture.

We achieve this by hashing the fields you wish to dedupe on and store those in a data store which we then check against.  Should a match be found, we will tag it.  You can then go on to drop {} it, or something similar.

The README from this point down is primarily from the plugin template for a README.

## Plugin Developement and Testing
You can use a docker container with all of the requirements pre installed to save you installing the development environment on your host.

### 1. Development

#### 1.1 Starting the container
Simply type `docker-compose run --rm devenv` and you'll be entered into the container. 

#### 1.2 Running tests
Once you've done #1 above, you can run your tests with `jruby -S bundle exec rspec`

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-filter-awesome", :path => "/your/local/logstash-filter-dedupe"
```
- Install plugin
```sh
bin/plugin install --no-verify
```
- Run Logstash with your plugin
```sh
bin/logstash -e 'filter {dedupe {}}'
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

#### 2.2 Run in an installed Logstash

You can use the same **2.1** method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-filter-awesome.gemspec
```
- Install the plugin from the Logstash home
```sh
bin/plugin install /your/local/plugin/logstash-filter-dedupe.gem
```
- Start Logstash and proceed to test the plugin

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elasticsearch/logstash/blob/master/CONTRIBUTING.md) file.

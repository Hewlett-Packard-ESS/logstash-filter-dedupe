FROM hpess/devenv-jruby:master
ADD ./*.gemspec /storage/
ADD Gemfile /storage/

RUN jruby -S bundle install

ENTRYPOINT ['/bin/bash']

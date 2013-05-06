#!/usr/bin/env ruby
$:.unshift "./docker_builder/lib"

require "docker/builder"

Docker.build("base" => "brianm/buildy") do |b|
  #:author => "Brian McCallister <brianm@skife.org>") do |b|
  b.put "./bd.rb" => "/really_long_name.rb",
        "./a_dir" => "/my_sweet_dir"

  b.bash "apt-get install -y build-essential curl ruby1.9.1 ruby1.9.1-dev git"  
  b.bash "curl -L https://www.opscode.com/chef/install.sh | bash"
  b.bash "gem install berkshelf"
end


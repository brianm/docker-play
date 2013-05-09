#!/usr/bin/env ruby
$:.unshift "./docker_builder/lib"

require "docker/builder"

Docker.build(from: "ubuntu:12.10", to: "brianm/buildy") do |b|
#Docker.build(from: "brianm/buildy", to: "brianm/buildy") do |b|
  b.maintainer "Brian McCallister <brianm@skife.org>"
  b.bash <<-EOS
    DEBIAN_FRONTEND=noninteractive 
    if [ ! -f /var/lib/apt/periodic/update-success-stamp ]; then
      apt-get update
    else
      ts=$(echo "$(date +%s) - $(stat -c %Y /var/lib/apt/periodic/update-success-stamp)" | bc)
      if [ $ts -gt 86400 ]
      then
        apt-get update
      fi 
    fi
    apt-get install -y netcat python python-pip
    pip install honcho
  EOS
  b.put "Procfile" => "/Procfile"

  # required for honcho
  b.env "USER" => "xncore"
  b.cmd ["/bin/bash", "-c", "honcho start"]
  b.expose "8000"
end


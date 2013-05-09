#!/usr/bin/env ruby
$:.unshift "./docker_builder/lib"

require "docker/builder"

#Docker.build(from: "ubuntu:12.10", to: "brianm/buildy") do |b|
Docker.build(from: "brianm/buildy", to: "brianm/buildy") do |b|
  b.maintainer "Brian McCallister <brianm@skife.org>"
  b.env "DEBIAN_FRONTEND" => "noninteractive",
        "USER" => "xncore"

  b.bash <<-EOS
    DEBIAN_FRONTEND=noninteractive 
    apt-get install -y bc
    if [ ! -f /var/apt-updated ]; then
      apt-get update
      touch /var/apt-updated
    else
      ts=$(echo "$(date +%s) - $(stat -c %Y /var/apt-updated)" | bc)
      if [ $ts -gt 86400 ]
      then
        apt-get update
        touch /var/apt-updated
      fi 
    fi
    apt-get install -y netcat python python-pip
    pip install honcho
  EOS

  b.put "Procfile" => "/Procfile"
  b.cmd ["/bin/bash", "-c", "honcho start"]
  b.expose "8000"

end


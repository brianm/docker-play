#!/usr/bin/env ruby
require "docker/maker"

Docker.make(from: "ubuntu:12.10", to: "brianm/buildy") do |b|
  b.maintainer "Brian McCallister <brianm@skife.org>"
  b.env "DEBIAN_FRONTEND" => "noninteractive",
        "USER" => "xncore"
  b.bash <<-EOS
    apt-get install -y bc
    if [ ! -f /var/apt-updated ]; then
      apt-get update
      touch /var/apt-updated
    fi
    apt-get install -y netcat python python-pip
    pip install honcho
  EOS
  b.put "Procfile" => "/Procfile"
  b.cmd ["/bin/bash", "-c", "honcho start"]
  b.expose "7000"
end


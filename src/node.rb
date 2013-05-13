#!/usr/bin/env ruby
require "docker/maker"

Docker.make(from: "ubuntu:12.10", to: "brianm/ana") do |b|
  b.maintainer "Brian McCallister <brianm@skife.org>"
  b.env "DEBIAN_FRONTEND" => "noninteractive",
        "USER" => "xncore",
        "PORT" => "8000"

  b.put "." => "/app"
 
  b.cmd ["/bin/bash", "-c", "cd app; /app/node-v0.10.5-linux-x64/bin/node app"]
  b.expose "8000"

end


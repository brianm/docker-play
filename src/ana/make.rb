#!/usr/bin/env ruby
require "docker/maker"

Docker.make(from: "ubuntu:12.10", to: "brianm/ana") do |b|
  b.maintainer "Brian McCallister <brianm@skife.org>"  
  b.env "DEBIAN_FRONTEND" => "noninteractive",
        "USER" => "xncore",
        "PORT" => "8000"
  b.bash <<-EOS
    if [ ! -e /usr/local/bin/node ]
    then
      apt-get install -y curl
      cd /var/tmp/
      curl -O http://nodejs.org/dist/v0.10.5/node-v0.10.5-linux-x64.tar.gz
      tar -zxvf node-v0.10.5-linux-x64.tar.gz
      mv node-v0.10.5-linux-x64 /usr/local/
      ln -s /usr/local/node-v0.10.5-linux-x64/bin/node /usr/local/bin/
    fi
    rm -rf /app
  EOS
  b.put "." => "/app" 
  b.cmd ["/bin/bash", "-c", "cd /app; node app"]
  b.expose "8000"
end


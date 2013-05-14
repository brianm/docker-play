#
# Cookbook Name:: docker-play
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#


apt_repository "docker" do
  uri "http://ppa.launchpad.net/dotcloud/lxc-docker/ubuntu"
  distribution "precise" #node['lsb']['codename']
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "E61D797F63561DC6"
end

package "linux-image-extra-virtual"
package "ruby1.9.1"
gem_package "docker_maker"
package "emacs24-nox"
package "build-essential"
package "lxc"
package "bsdtar"
package "lxc-docker" do 
  action :upgrade
end

#
# Cookbook Name:: docker-play
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

=begin
apt_repository "docker" do
  uri "http://ppa.launchpad.net/dotcloud/lxc-docker/ubuntu"
  distribution "precise" #node['lsb']['codename']
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "E61D797F63561DC6"
end

package "linux-image-extra-virtual"
package "lxc"
package "bsdtar"
package "lxc-docker"
=end

package "linux-image-extra-virtual"
package "lxc"
package "bsdtar"

docker_tarball_path = "/var/tmp/docker-latest.tgz"

remote_file docker_tarball_path do
  source "http://get.docker.io/builds/Linux/x86_64/docker-latest.tgz"
  action :create_if_missing
end

bash "extract_docker" do
  code <<-EOH
    mkdir -p /var/tmp/docker-extract
    cd /var/tmp/docker-extract
    tar -zxf #{docker_tarball_path}
    mv docker-*/docker /usr/bin
  EOH
  not_if { ::File.exists? "/usr/bin/docker" }
end

cookbook_file "/etc/init/docker.conf" do
  source "docker.upstart"
  owner "root"
  group "root"
end

service "docker" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end


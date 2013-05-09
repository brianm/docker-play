#!/usr/bin/env ruby

require "open3"
require "json"

class Docker
  attr_reader :docker, :name
  
  def initialize base, name, path="/usr/bin/docker"
    @docker = path
    @name = name
    @ports = []
    @env = []

    _, s = _exec [docker, "images", "|", "grep", base]
    unless s
      msg, s = _exec [docker, "pull", base]      
      raise msg unless s
    end
    @img, s = _exec [docker, "run", "-d", base, "/bin/bash", "-c", "ls"]
    raise out unless s
    _commit
  end
  
  def _exec args, input=nil
    puts "#{args.join(" ")}"
    Open3.popen3(*args) do |sin, sout, serr, wait|
      if input 
        while buff = input.read(4096)
          sin.write buff
        end
      end
      sin.close      
      status = wait.value
      m = sout.read.strip
      [m, status.success?]
    end    
  end
  
  def _commit
    c = [docker, "commit"]
    run = {"PortSpecs" => @ports,
           "Env" => @env}

    run['Cmd'] = @cmd if @cmd
    run['User'] = @user if @user
    if @maint
      c << "-m"
      c << @maint
    end
    out, s = _exec [docker, "commit", "-run", JSON.dump(run),  @img, @name]
    raise "commit failed: #{out}" unless s
  end

  def _wait
    out, s = _exec [docker, "wait", @img]
    raise "commit failed: #{out}" unless s
  end

  def _bash cmd, input=nil
    cmd = [docker, "run", "-d", @name, "/bin/bash", "-c", cmd]    
    @img, s = _exec cmd, input
    raise @img unless s
    s
  end

  def bash cmd
    _bash cmd
    _wait
    _commit
  end 

  def cmd c
    @cmd = Array(c)
    _commit    
  end

  def maintainer mnt
    @maint = mnt
    _commit
  end

  def expose port
    puts "exposing #{port}"
    @ports << port
    _commit
  end

  def user usr
    @user = usr
  end

  def env hash
    @env = @env + hash.inject([]) {|a, (k, v)| a << "#{k}=#{v}"}
    _commit
  end

  # IMG=$(docker run -i -a stdin brianm/ruby /bin/bash -c "/bin/cat >
  # /echo.rb" < ./echo.rb)
  def put vals
    vals.each do |k, v|
      if File.directory? k
        # mkdir foo; bsdtar -cf - -C adir . | (bsdtar xpf - -C foo )
        open("|tar -cf - -C #{k} .") do |input|
          bash "mkdir -p #{v}"
          cmd = [docker, "run", "-i","-a", "stdin", @name, 
                 "/bin/bash", "-c", "tar xpf - -C #{v}"]
          @img, s = _exec cmd, input
          raise @img unless s
          _wait
          _commit
        end
      else    
        File.open(k, "r") do |input|
          cmd = [docker, "run", "-i","-a", "stdin", @name, 
                 "/bin/bash", "-c", "/bin/cat >  #{v}"]
          @img, s = _exec cmd, input
          raise @img unless s
          _wait
          _commit
        end
      end
    end
  end

  def self.build(args)
    from = args[:from]
    to = args[:to]
    d = Docker.new(from, to)
    yield d
  end
end

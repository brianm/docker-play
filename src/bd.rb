#!/usr/bin/env ruby

require "open3"


class Docker
  attr_reader :docker, :name
g  
  def initialize base, name, path="/usr/bin/docker"
    @docker = path
    @name = name
    # yes, we run this twice, in case base isn't here yet
    _exec [docker, "run", "-d", base, "/bin/bash", "-c", "ls"]
    @img, s = _exec [docker, "run", "-d", base, "/bin/bash", "-c", "ls"]
    raise @img unless s
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
    out, s = _exec [docker, "commit", @img, @name]
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

  # IMG=$(docker run -i -a stdin brianm/ruby /bin/bash -c "/bin/cat > /echo.rb" < ./echo.rb)
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

  def self.build names, &block
    base, target = names.inject {|a, (k, v)| [k, v]}
    d = Docker.new(base, target)
    block.call(d)
  end
end

Docker.build("base" => "brianm/buildy") do |b|
  #:author => "Brian McCallister <brianm@skife.org>") do |b|
  b.bash "touch '*'"
  b.put "./bd.rb" => "/really_long_name.rb",
        "./a_dir" => "/my_sweet_dir"
  
end

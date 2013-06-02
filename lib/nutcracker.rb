require 'nutcracker/version'
require 'socket'
require 'json'
require 'yaml'

module Nutcracker

  def self.start options
    Nutcracker::Wrapper.new(options).start
  end

  def self.executable
    File.expand_path("../../ext/nutcracker/src/nutcracker", __FILE__)
  end

  def self.version
    Nutcracker::VERSION
  end

  class Wrapper
    attr_reader :pid, :config_file

    def initialize options
      @config_file = options.fetch :config_file
    end

    def start
      return if running?
      @pid = ::Process.spawn Nutcracker.executable, '-c', config_file
      Kernel.at_exit { kill if running? }
      self
    end

    def running?
      !!(pid and ::Process.getpgid pid rescue false)
    end

    def stop
      sig :TERM
    end

    def kill
      sig :KILL
    end

    def join
      running! and ::Process.waitpid2 pid
    end

    def stats
      JSON.parse TCPSocket.new('localhost',22222).read rescue {}
    end

    def config
      @config ||= YAML.load_file config_file
    end

    # syntactic sugar for initialize plugins
    def use plugin, *args
      Nutcracker.const_get(plugin.to_s.capitalize).start(self,*args)
    end

    private

    def running!
      running? or raise RuntimeError, "Nutcracker isn't running..." 
    end

    def sig term
      running! and ::Process.kill(term, pid)
    end

  end
end

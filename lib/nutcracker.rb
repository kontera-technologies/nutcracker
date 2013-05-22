require 'nutcracker/version'
require 'socket'
require 'json'

module Nutcracker

  def self.start options
    Nutcracker::Process.new(options).start
  end

  def self.executable
    File.expand_path("../../ext/nutcracker/src/nutcracker", __FILE__)
  end

  def self.version
    Nutcracker::VERSION
  end

  class Process
    attr_reader :pid, :options

    def initialize options
      @options = options
    end

    def start
      raise RuntimeError, "Nutcracker is already running (#{pid})..." if running?
      @pid = ::Process.spawn("#{Nutcracker.executable} -c #{options.fetch(:config_file).inspect}")
      Kernel.at_exit { stop if running? }
      self
    end

    def running?
      !!(pid and ::Process.getpgid pid rescue false)
    end

    def stop
      signal :TERM
    end

    def kill
      signal :KILL
    end

    def join
      verify_running! and ::Process.waitpid2 pid
    end

    def stats
      JSON.parse TCPSocket.new('localhost',22222).read rescue {}
    end

    private

    def verify_running!
      running? or raise RuntimeError, "Nutcracker isn't running..." 
    end

    def signal term
      verify_running! and ::Process.kill(term, pid)
    end

  end

end

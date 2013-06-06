require 'nutcracker/version'
require 'socket'
require 'json'
require 'yaml'
require 'redis'

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


    def config
      @config ||= YAML.load_file config_file
    end

    # syntactic sugar for initialize plugins
    def use plugin, *args
      Nutcracker.const_get(plugin.to_s.capitalize).start(self,*args)
    end

    def overview
      { :clusters => {} }.tap do |data|
        (stats).each do |key, value|
          (data[key] = value and next) if !value.is_a? Hash
          next unless ( config[key]["redis"] rescue false ) # skip memcached

          data[:clusters][key] = value
          data[:clusters][key][:nodes] = {}
          data[:clusters][key].each do |node,node_value|
            url = "redis://#{node}" unless node =~ /redis\:\/\//
            if node_value.kind_of? Hash and node.is_a? String
              data[:clusters][key][:nodes][url] = data[:clusters][key].delete(node)
              data[:clusters][key][:nodes][url][:info] = redis_info(url)
            end
          end
        end
      end
    end

    def redis_info url
      redis = Redis.connect url: url
      info = redis.info
      db_size     = redis.dbsize
      max_memory  = redis.config(:get, 'maxmemory')['maxmemory'].to_i
      redis.quit
      {
        'connections'     => info['connected_clients'].to_i,
        'used_memory'     => info['used_memory'].to_f,
        'used_memory_rss' => info['used_memory_rss'].to_f,
        'fragmentation'   => info['mem_fragmentation_ratio'].to_f,
        'expired_keys'    => info['expired_keys'].to_i,
        'evicted_keys'    => info['evicted_keys'].to_i,
        'hits'            => info['keyspace_hits'].to_i,
        'misses'          => info['keyspace_misses'].to_i,
        'keys'            => db_size,
        'max_memory'      => max_memory,
        'hit_ratio'       => 0
      }.tap {|d| d['hit_ratio'] = d['hits'].to_f / (d['hits']+d['misses']).to_f if d['hits'] > 0 }
    end

    def stats
      JSON.parse TCPSocket.new('localhost',22222).read rescue {}
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

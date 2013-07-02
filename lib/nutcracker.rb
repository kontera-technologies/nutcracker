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

    # Different structure to stats and with more infomation from Redis.info
    # {
    #   :clusters => [
    #     {
    #       :nodes => [
    #         {
    #           :server_url => "redis://redis.com",
    #           :server_eof => 9,
    #           :server_err => 20,
    #           :info => {
    #             :connections => 10
    #             :used_memory => 1232132
    #             :used_memory_rss => 2323132
    #             :fragmentation => 1.9
    #             :expired_keys => 2132
    #             :evicted_keys => 23223
    #             :hits => 2321
    #             :misses => 234232
    #             :keys => 2121
    #             :max_memory => 123233232
    #             :hit_ratio => 0.9
    #           },
    #           ...
    #         }
    #       ]
    #       :client_eof => 2,
    #       :client_connections => 3,
    #       ...
    #     }
    #   ],
    #   :server_attribute1 => "server_value1",
    #   :server_attribute2 => "server_value2",
    # }
    def overview
      data = { :clusters => [], :config => config }

      stats.each do |cluster_name, cluster_data|

        # Setting global server attributes ( like hostname, version etc...)
        unless cluster_data.is_a? Hash
          data[cluster_name] = cluster_data
          next
        end

        # Adding cluster
        next unless redis? cluster_name # only support redis clusters
        cluster = { nodes: [], name: cluster_name }
        cluster_data.each do |node, node_value|
          
          # Adding cluster Node
          if node_value.kind_of? Hash
            url = ( node =~ /redis\:\/\// ) ? node : "redis://#{node}"
            info = redis_info(url)
            cluster[:nodes] << {
              server_url: url, info: info, running: info.any?
            }.merge(cluster_data[node])
          else # Cluster attribute
            cluster[node] = node_value
          end

        end
        data[:clusters].push cluster
      end
      data
    end

    def redis? cluster
      config[cluster]["redis"] rescue false
    end

    def redis_info url
      begin
        redis = Redis.connect(url: url) 
      rescue
        return Hash.new
      end
       
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

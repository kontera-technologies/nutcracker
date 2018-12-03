require 'nutcracker/version'
require 'socket'
require 'json'
require 'yaml'
require 'redis'
require 'timeout'
require 'uri'

module Nutcracker
  # Syntactic sugar for launching the Nutcracker service ( see {Wrapper#initialize} )
  # @return [Wrapper] Nutcracker process wrapper
  # @example
  #  Nutcracker.start config_file: 'conf/nutcracker.yaml'
  def self.start options
    Nutcracker::Wrapper.new(options).start
  end

  # Connect to a running instance of Nutcracker ( see {Wrapper#initialize} )
  # @return [Wrapper] Nutcracker process wrapper
  # @example
  #  Nutcracker.attach :config_file: 'conf/nutcracker.yaml', :stats_port => 22222
  def self.attach options
    Nutcracker::Wrapper.new options.merge attached: true
  end

  # Returns the Nutcracker executable path that is embeded with the gem
  def self.executable
    File.expand_path("../../ext/nutcracker/src/nutcracker", __FILE__)
  end

  # Returns the version string
  def self.version
    Nutcracker::VERSION
  end

  class Wrapper
    attr_reader :pid

    # Initialize a new Nutcracker process wrappper
    # @param [Hash] options
    # @option options [String] :config_file (conf/nutcracker.yaml) path to nutcracker's configuration file
    # @option options [String] :stats_uri Nutcracker stats URI - tcp://localhost:22222
    # @option options [String] :max_memory use fixed max memory size ( ignore server configuration )
    # @option options [Array] :args ([]) array with additional command line arguments
    def initialize options
      @options = validate defaults.merge options
      @options[:stats_uri] = URI @options[:stats_uri]
    end

    # launching the Nutcracker service
    def start *args
      return self if attached? or running?
      @pid = ::Process.spawn Nutcracker.executable, *command
      Process.detach(@pid)
      sleep 2
      raise "Nutcracker failed to start" unless running?
      Kernel.at_exit { kill if running? }
      self
    end

    # Returns the current running status
    def running?
      attached? ? stats.any? : !!(pid and ::Process.getpgid pid rescue nil)
    end

    # Returns true if the current instance was initialize with the attached flag
    def attached?
      @options[:attached]
    end

    # Stops the Nutcracker service
    def stop
      sig :TERM
    end

    # Kills the Nutcracker service
    def kill
      sig :KILL
    end

    # Wait for the process to exit
    def join
      attached? ? sleep : (running! and ::Process.waitpid2 pid rescue nil)
    end

    # Returns Nutcracker's configuration hash
    def config
      @config ||= YAML.load_file @options[:config_file]
    end

    # Syntactic sugar for initialize plugins
    def use plugin, *args
      Nutcracker.const_get(plugin.to_s.capitalize).start(self,*args)
    end

    # Returns hash with server and node statistics
    # See example.json @ project root to get details about the structure
    def overview
      data = { :clusters => [], :config => config }

      stats.each do |cluster_name, cluster_data|
        # Setting global server attributes ( like hostname, version etc...)
        unless cluster_data.is_a? Hash
          data[cluster_name] = cluster_data
          next
        end

        #next unless redis? cluster_name # skip memcached clusters

        aliases = node_aliases cluster_name
        cluster = { nodes: [], name: cluster_name }
        cluster_data.each do |node, node_value|
          # Adding node
          if node_value.kind_of? Hash
            node_data = cluster_data[node]
            node = aliases[node] || node
            url = ( node =~ /redis\:\/\// ) ? node : "redis://#{node}"
            info = redis_info(url, config[cluster_name]["redis_auth"])
            cluster[:nodes] << {
              server_url: url, info: info, running: info.any?
            }.merge(node_data)
          else # Cluster attribute
            cluster[node] = node_value
          end
        end
        data[:clusters].push cluster
      end
      data
    end

    # Check if a given cluster name was configure as Redis
    def redis? cluster
      config[cluster]["redis"] rescue false
    end

    # https://github.com/twitter/twemproxy/blob/master/notes/recommendation.md#node-names-for-consistent-hashing
    def node_aliases cluster
      Hash[config[cluster]["servers"].map(&:split).each {|o| o[0]=o[0].split(":")[0..1].join(":")}.map(&:reverse)]
    end

    # Returns hash with information about a given Redis
    def redis_info url, password
      begin
        r = Redis.new url: url, password: password
        info = r.info.merge 'dbsize' => r.dbsize
      rescue Exception
        return {}
      end

      begin
        info['maxmemory'] = @options.fetch(:max_memory) { r.config(:get, 'maxmemory')['maxmemory'] }
      rescue Exception
        info['maxmemory'] = info['used_memory_rss']
      end

      r.quit

      {
        'connections'     => info['connected_clients'].to_i,
        'used_memory'     => info['used_memory'].to_f,
        'used_memory_rss' => info['used_memory_rss'].to_f,
        'fragmentation'   => info['mem_fragmentation_ratio'].to_f,
        'expired_keys'    => info['expired_keys'].to_i,
        'evicted_keys'    => info['evicted_keys'].to_i,
        'hits'            => info['keyspace_hits'].to_i,
        'misses'          => info['keyspace_misses'].to_i,
        'keys'            => info['dbsize'].to_i,
        'max_memory'      => info['maxmemory'].to_i,
        'hit_ratio'       => 0
      }.tap {|d| d['hit_ratio'] = d['hits'].to_f / (d['hits']+d['misses']).to_f if d['hits'] > 0 }
    end

    # Returns a hash with server statistics
    def stats
      JSON.parse TCPSocket.new(@options[:stats_uri].host,@options[:stats_uri].port).read rescue {}
    end

    private

    def command
      ['-c', @options[:config_file],'-s',@options[:stats_uri].port,*@options[:args]].map(&:to_s)
    end

    def defaults
      { :args => [],
        :config_file => 'conf/nutcracker.yaml',
        :stats_uri => URI("tcp://127.0.0.1:22222"),
        :attached => false}
    end

    def validate options
      options.tap { File.exists? options[:config_file] or raise "#{options[:config_file]} not found" }
    end

    def running!
      running? or raise RuntimeError, "Nutcracker isn't running..."
    end

    def sig term
      running! and ::Process.kill(term, pid)
    end

  end
end

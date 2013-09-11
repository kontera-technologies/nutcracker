require_relative '../minitest_helper'

module Nutcracker
  class WrapperTester < Nutcracker::Unit::TestCase

    attr_reader :nutcracker, :out

    def setup
      @out = Tempfile.new('nutcracker')
      p "fu1"
      @nutcracker = redirect_output(out) {
        Nutcracker.start config_file: fixture('config.yaml')
      }
      p "fu2"
      p @nutcracker
      p "fu3"
      assert @nutcracker.running?
    end
    
    def teardown
      nutcracker.kill rescue nil
      sleep 0.1
      refute nutcracker.running?
      out.close
    end

    def test_running?
      assert nutcracker.running?
      Process.kill(:KILL,nutcracker.pid)
      sleep 0.1
      refute nutcracker.running?
    end

    def test_kill
      nutcracker.kill
      sleep 0.1
      refute nutcracker.running?
    end
=begin
    def test_stop
      nutcracker.stop
      sleep 0.1
      refute nutcracker.running?
    end

    def test_join
      thread = Thread.new { nutcracker.join }
      sleep 0.5
      assert thread.status
      nutcracker.kill
      sleep 0.1
      refute thread.status
    end

    def test_stats
      sleep 0.5
      refute nutcracker.stats.empty?
      assert nutcracker.stats['dummy_cluster']
    end

    def test_config
      assert_equal load_fixture('config.yaml'), nutcracker.config
    end

    def test_sample_flow
      assert nutcracker.running?
      nutcracker.stop
      sleep 0.1
      refute nutcracker.running?
      redirect_output(out) { nutcracker.start }
      sleep 0.1
      assert nutcracker.running?
      nutcracker.kill
      sleep 0.1
      refute nutcracker.running?
    end
    
    def test_node_aliases
      nutcracker.expects(:config).returns({ "a" => {"servers" => ["redis1:1234","redis2:1234"] }})
      assert_equal(nutcracker.send(:node_aliases,"a"), {"redis1:1234"=>nil, "redis2:1234"=>nil})
      nutcracker.expects(:config).returns({ "a" => {"servers" => ["redis1:1234:1 shuki","redis2:1234:2"] }})
      assert_equal(nutcracker.send(:node_aliases,"a"), {"shuki"=>"redis1:1234", "redis2:1234"=>nil})
    end
=end
  end
end

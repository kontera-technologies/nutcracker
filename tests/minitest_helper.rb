$:.unshift File.expand_path '../../lib', __FILE__
gem 'minitest'

require 'minitest/autorun'
require 'mocha/setup'
require 'nutcracker'
require 'tempfile'
require 'fileutils'

module Nutcracker
  module Unit
    class TestCase < ::Minitest::Test
      def fixture name
        File.expand_path("../fixtures/#{name}", __FILE__)
      end

      def load_fixture name
        YAML.load_file fixture name
      end

      def redirect_output file, &block
        #file.sync = true
        #err, out =  STDERR.clone , STDOUT.clone
        #STDERR.reopen(file)
        #STDOUT.reopen(file)
        payload = block.call
        #STDERR.reopen(err)
        #STDOUT.reopen(out)
        payload
      end

    end
  end
end

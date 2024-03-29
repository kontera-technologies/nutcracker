$:.unshift File.expand_path '../lib', __FILE__
require 'nutcracker/version'
require 'rake'
require 'rubygems/package_task'

Gem::Specification.new do |s|
  s.name                  = "nutcracker"
  s.version               = Nutcracker::VERSION
  s.platform              = Gem::Platform::RUBY
  s.license               = "MIT"
  s.summary               = "Gem wrapper for Twitter's Nutcracker"
  s.description           = "Gem wrapper for Twitter's Nutcracker - aka Twemproxy"
  s.author                = "Eran Barak Levi"
  s.email                 = "eran@kontera.com"
  s.homepage              = 'http://www.kontera.com'
  s.required_ruby_version = '>= 1.8.5'
  s.rubyforge_project     = "ruby-nutcracker"
  s.files                 = %w(README.md Rakefile) + Dir.glob("{bin,lib,ext}/**/*")
  s.require_path          = "lib"
  s.extensions            = ['ext/nutcracker/extconf.rb']
  s.executables           = ['nutcracker']
  s.add_development_dependency 'minitest', '~> 5.0.0'
  s.add_development_dependency 'mocha', '~> 0.14.0'
  s.add_runtime_dependency 'redis'
end

$:.unshift File.expand_path '../lib', __FILE__
require 'nutcracker'
require 'rake'
require 'rubygems/package_task'

Gem::Specification.new do |s|
  s.name                  = "nutcracker"
  s.version               = Nutcracker.version
  s.platform              = Gem::Platform::RUBY
  s.summary               = "Twitter's Nutcraker Gem Wrapper"
  s.description           = "Gem/Bundler benefits for Twitter's Nutcraker C app"
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

Gem::Specification.new do |s|
  s.name                  = "nutcracker"
  s.version               = "0.2.1" 
  s.platform              = Gem::Platform::RUBY
  s.summary               = "Twitter's Nutcraker Gem Wrapper"
  s.description           = "Gem/Bundler benefits for Twitter's Nutcraker C app"
  s.author                = "Eran Barak Levi"
  s.email                 = "eran@kontera.com"
  s.homepage              = 'http://www.kontera.com'
  s.required_ruby_version = '>= 1.8.5'
  s.rubyforge_project     = "ruby-nutcracker"
  s.files                 = Dir.glob("**/*").reject {|o| o =~ /\.gem/}
  s.require_path          = "lib"
  s.extensions            = ['ext/nutcracker/extconf.rb']
  s.executables           = ['nutcracker']
  s.require_paths         = ['lib', 'ext']
end

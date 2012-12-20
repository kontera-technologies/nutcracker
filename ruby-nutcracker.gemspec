Gem::Specification.new do |s|
  s.name                  = "ruby-nutcracker"
  s.version               = "0.0.0.0" 
  s.platform              = Gem::Platform::RUBY
  s.summary               = "Twitter's Nutcraker Gem Wrapper"
  s.description           = "Gem/Bundler benefits for Twitter's Nutcraker C application"
  s.author                = "Eran Barak Levi"
  s.email                 = "eran@kontera.com"
  s.homepage              = 'http://www.kontera.com'
  s.required_ruby_version = '>= 1.8.5'
  s.rubyforge_project     = "ruby-nutcracker"
  s.files                 = Dir.glob("**/*").reject {|o| o =~ /\.gem/}
  s.require_path          = "lib"
  s.bindir                = "bin"
end

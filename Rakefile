$:.unshift File.expand_path '../lib', __FILE__
require 'nutcracker'
require 'rake'
require 'rubygems/package_task'

Nutcracker::GemSpec = Gem::Specification.new do |s|
  s.name                  = "nutcracker"
  s.version               = Nutcracker.version.dup
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
  s.require_paths         = ['lib', 'ext']
end

task :download do
  "nutcracker-#{Nutcracker.version}.tar.gz".tap do |tarball|
    sh "rm -rf ext/nutcracker"
    sh "wget https://github.com/downloads/twitter/twemproxy/#{tarball}"
    sh "tar -zxvf #{tarball}"
    sh "mv nutcracker-#{Nutcracker.version} ext/nutcracker"
    File.open("ext/nutcracker/extconf.rb",'w') do |file|
      file.puts %q{
        raise "no support for #{RUBY_PLATFORM}" if RUBY_PLATFORM =~ /darwin|mswin|mingw/
        system './configure'
        system 'make'
      }
    end
    sh "rm #{tarball}"
  end
end

task :build => :download do
  sh "rake gem"
end

task :gem => [:clobber_package]

Gem::PackageTask.new Nutcracker::GemSpec do |p|
  p.gem_spec = Nutcracker::GemSpec
end

task :install => [:gem] do
   sh "gem install pkg/nutcracker"
   Rake::Task['clobber_package'].execute
end

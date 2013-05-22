$:.unshift File.expand_path '../lib', __FILE__
require 'nutcracker'
require 'rake'
require 'rubygems/package_task'

Nutcracker::GemSpec = eval File.read 'nutcracker.gemspec'

sversion = Nutcracker.version.split(".")[0..2].join(".") 

task :download do
  "nutcracker-#{sversion}.tar.gz".tap do |tarball|
    sh "mkdir ext" unless File.directory? "ext"
    sh "rm -rf ext/nutcracker"
    sh "wget https://twemproxy.googlecode.com/files/#{tarball}"
    sh "tar -zxvf #{tarball}"
    sh "mv nutcracker-#{sversion} ext/nutcracker"
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

$:.unshift File.expand_path '../lib', __FILE__
require 'nutcracker'
require 'rake'
require 'rubygems/package_task'
require "rake/testtask"

Nutcracker::GemSpec = eval File.read 'nutcracker.gemspec'

sversion = Nutcracker.version.split(".")[0..2].join(".") 
abort "Only support 5+ versions" if Gem::Version.new(sversion) < Gem::Version.new('0.5.0')

desc "Download Nutcracker c app"
task :download do
  "nutcracker-#{sversion}.tar.gz".tap do |tarball|
    sh "mkdir ext" unless File.directory? "ext"
    sh "rm -rf ext/nutcracker"
    sh "wget 'https://github.com/twitter/twemproxy/releases/download/#{sversion}/twemproxy-#{sversion}.tar.gz' -O #{tarball}"
    sh "tar -zxvf #{tarball}"
    sh "mv twemproxy-#{sversion} ext/nutcracker"
    Dir.chdir("ext/nutcracker") do 
      sh "autoreconf -fvi"
      c = File.read("configure").gsub("-${am__api_version}","")
      File.open("configure","w") {|f| f.puts c}
    end
    File.open("ext/nutcracker/extconf.rb",'w') do |file|
      file.puts %q{
        system "./configure --prefix=#{File.expand_path('..',__FILE__)}"
        system 'make'
      }
    end
    sh "rm #{tarball}"
  end
end

desc "Download the Nutcracker C app and build new Gem"
task :gem => [:download] do
  sh "gem build nutcracker.gemspec"
end

task :install => [:gem] do
   sh "gem install pkg/nutcracker"
   Rake::Task['clobber_package'].execute
end

## Tests stuff
task :default => :test

task :test do
  sh "./compile_ext.bash" unless File.exists? "ext/nutcracker/src/nutcracker"
end

Rake::TestTask.new(:test) do |t|
  t.libs << "tests"
  t.pattern = "tests/**/*_test.rb"
end

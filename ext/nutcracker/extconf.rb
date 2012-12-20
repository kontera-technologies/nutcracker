raise "no support for Mac" if RUBY_PLATFORM =~ /darwin/
system './configure'
system 'make'
# Nutcracker
<a href="https://rubygems.org/gems/nutcracker"><img src=https://fury-badge.herokuapp.com/rb/nutcracker.png></a>

This library wraps Twitter's [Nutcracker](https://github.com/twitter/twemproxy) in a gem package and provides a simple ruby API to the `nutcracker` executable.

### DISCLAIMER
this is still a work in progress...

## Motivation
The main motivation here is to take the advantages of working with Bundler's dependencies management and to be able to embed Twitter's [Nutcracker](https://github.com/twitter/twemproxy) as a dependency to any Ruby project, this allow you to create small-configuration-only-apps tied to specific version of Nutcracker as I show in the example bellow.

## Plugins
- [nutcracker-graphite](https://github.com/kontera-technologies/nutcracker-graphite) - Send cluster stats to Graphite
- [nutcracker-ui](https://github.com/kontera-technologies/nutcracker-ui) - Web interface for admin operations and graphs

### Installation 
Add this line to your application's Gemfile:
```
gem 'nutcracker'
```

And then execute:
```
$ bundle install
```

after the gem was successfully installed, the `nutcracker` executable should be available
```
[root@somewhere ~]# nutcracker --help
This is nutcracker-0.2.3

Usage: nutcracker [-?hVdDt] [-v verbosity level] [-o output file]
                  [-c conf file] [-s stats port] [-a stats addr]
                  [-i stats interval] [-p pid file] [-m mbuf size]

Options:
  -h, --help             : this help
  -V, --version          : show version and exit
  -t, --test-conf        : test configuration for syntax errors and exit
  -d, --daemonize        : run as a daemon
  -D, --describe-stats   : print stats description and exit
  -v, --verbosity=N      : set logging level (default: 5, min: 0, max: 11)
  -o, --output=S         : set logging file (default: stderr)
  -c, --conf-file=S      : set configuration file (default: conf/nutcracker.yml)
  -s, --stats-port=N     : set stats monitoring port (default: 22222)
  -a, --stats-addr=S     : set stats monitoring ip (default: 0.0.0.0)
  -i, --stats-interval=N : set stats aggregation interval in msec (default: 30000 msec)
  -p, --pid-file=S       : set pid file (default: off)
  -m, --mbuf-size=N      : set size of mbuf chunk in bytes (default: 16384 bytes)

```

### Ruby Wrapper
a simple ruby wrapper is also included

```ruby
require 'nutcracker'

nutcracker = Nutcracker.start(config_file: 'cluster.yaml')
nutcracker.running? # => true

nutcracker.stats # => {"source"=>"local", "version"=>"0.2.4", "uptime"=>6...}

nutcracker.stop 
nutcracker.running? # => false

nutcracker.start
nutcracker.join # wait for server to exit
```

## Wanna build a new version?
* Set the version @ `lib/nutcracker/version.rb` ( [Available Versions](https://code.google.com/p/twemproxy/downloads/list) )
* run the `rake build` command
* look for `nutcracker-X.Y.Z` gem under the pkg folder

> for more details like licensing etc, please look @ [Nutcracker](https://github.com/twitter/twemproxy)

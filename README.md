# Nutcracker
<a href="https://rubygems.org/gems/nutcracker"><img src=https://fury-badge.herokuapp.com/rb/nutcracker.png></a>
<a href="https://travis-ci.org/kontera-technologies/nutcracker"><img src="https://api.travis-ci.org/kontera-technologies/nutcracker.png?branch=master"></a>

This library wraps Twitter's [Nutcracker](https://github.com/twitter/twemproxy) in a gem package and provides a simple ruby API to the `nutcracker` executable.

## Motivation
The main motivation here is to take the advantages of working with Bundler's dependencies management and to be able to embed Twitter's [Nutcracker](https://github.com/twitter/twemproxy) as a dependency to any Ruby project, this allow you to create small-configuration-only-apps tied to specific version of Nutcracker as I show in the example bellow.

## Plugins
- [nutcracker-graphite](https://github.com/kontera-technologies/nutcracker-graphite) - Send cluster stats to Graphite
- [nutcracker-web](https://github.com/kontera-technologies/nutcracker-web) - Web interface

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

you can also attach to a running instance of nutcracker

```ruby
Nutcracker.attach(config_file: 'cluster.yaml', stats_port: 22222)
```

### Building new gems
* Set the version @ `lib/nutcracker/version.rb` ( [Available Versions](https://code.google.com/p/twemproxy/downloads/list) )
* run the `rake build` command
* look for `nutcracker-X.Y.Z` gem under the pkg folder

### Warranty
This software is provided “as is” and without any express or implied warranties, including, without limitation, the implied warranties of merchantability and fitness for a particular purpose.

> for more details like licensing etc, please look @ [Nutcracker](https://github.com/twitter/twemproxy)


### Disclaimer
this project is still in its early stages so things could be a little bit buggy, if you find one feel free to [report](https://github.com/kontera-technologies/nutcracker/issues) it.

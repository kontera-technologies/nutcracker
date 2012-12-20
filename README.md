# Nutcracker
This "library" wraps Twitter's [Nutcracker](https://github.com/twitter/twemproxy) in a gem package and provides ( in the near future I hope ) simple ruby API to the `nutcracker` executable file.

# Motivation
The main motivation here is to take the advantages of working with Bundler's dependencies management and to be able to embed Twitter's [Nutcracker](https://github.com/twitter/twemproxy) as a dependency to any Ruby project, this allow you to create small-configuration-only-apps tied to specific version of Nutcracker as I show in the example bellow.

# Example of a small-configuration-only app

- Gemfile

```ruby
source :rubygems

gem "nutcracker", "0.2.1"
```

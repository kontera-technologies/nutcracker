#!/bin/bash

mkdir ext
bundle exec rake build
cd ext/nutcracker
make
cd -

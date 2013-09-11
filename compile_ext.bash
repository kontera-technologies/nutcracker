#!/bin/bash

mkdir ext
bundle exec rake build
cd ext/nutcracker
./configure
make
cd -

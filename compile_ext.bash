#!/bin/bash

mkdir ext
bundle exec rake build
cd ext/nutcracker
autoreconf -fvi
./configure
make
cd -

#!/bin/bash

mkdir ext
bundle exec rake gem
cd ext/nutcracker
autoreconf -fvi
./configure
make
cd -

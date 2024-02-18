#!/bin/bash

rm -rf bin build
cmake -B build -S . -G "Ninja" -DCMAKE_CXX_COMPILER=clang++ && cmake --build build && ./bin/test_main
rm -rf bin build

#!/bin/bash

function is_root {
  [ "${EUID:-$(id -u)}" -eq 0 ];
}

if ! is_root; then
  echo -e "\x1B[31m[ERROR] This script requires root privileges."
  exit 1
fi

rm -rf build
cmake -B build -S . -G "Ninja" -DCMAKE_CXX_COMPILER=clang++ && cmake --build build && cmake --install build
rm -rf build

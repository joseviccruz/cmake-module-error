# Installed module library can’t find imported headers \[Ubuntu 22.04 LTS, CMake 3.28.1, Ninja 1.11.1 and Clang 17.0.6\]

See at: [discourse.cmake](https://discourse.cmake.org/t/installed-module-library-cant-find-imported-headers-ubuntu-22-04-lts-cmake-3-28-1-ninja-1-11-1-and-clang-17-0-6/9819/1)

Run the scripts inside the devcontainer:

- `run_header_working.sh`
- `run_module_failing.sh`
- `run_module_working.sh`

Or use the GNUmakefile:

```bash
make -n
make working
make headeronly
make failing
```

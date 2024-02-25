# Standard stuff

.SUFFIXES:
$(VERBOSE).SILENT:

MAKEFLAGS+= --no-builtin-rules      	# Disable the built-in implicit rules.
MAKEFLAGS+= --warn-undefined-variables  # Warn when an undefined variable is referenced.
MAKEFLAGS+= --include-dir=$(BASEDIR)	# Search DIRECTORY for included makefiles (*.mk).

.PHONY: all clean distclean working headeronly failing format

all: working headeronly # XXX failing with cmake v3.28.3
working:
	cd module-lib && cmake --workflow --preset default --fresh && cmake --build --preset default --target install
	cd module-exe && cmake --workflow --preset default --fresh && cmake --build --preset default --target test

failing:
	TEST_FORCING_MODULE_ERROR=ON $(MAKE) working
	-run-clang-tidy -p build/module-exe

headeronly:
	cd header-lib && cmake --workflow --preset default --fresh && cmake --build --preset default --target install
	cd header-exe && cmake --workflow --preset default --fresh && cmake --build --preset default --target test
	-run-clang-tidy -p build/header-lib

clean:
	rm -rf build stagedir

distclean:
	git clean -xdf

format:
	find . -name CMakeLists.txt -o -name '*.cmake' | xargs cmake-format -i
	git clang-format main

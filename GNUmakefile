.PHONY: all clean working headeronly failing
all: working headeronly failing
working:
	pushd module-lib && cmake --workflow --preset default --fresh && cmake --build --preset default --target install && popd
	pushd module-exe && cmake --workflow --preset default --fresh && cmake --build --preset default --target test && popd

failing:
	TEST_FORCING_MODULE_ERROR=ON $(MAKE) working

headeronly:
	pushd header-lib && cmake --workflow --preset default --fresh && cmake --build --preset default --target install && popd
	pushd header-exe && cmake --workflow --preset default --fresh && cmake --build --preset default --target test && popd

clean:
	rm -rf build stagedir

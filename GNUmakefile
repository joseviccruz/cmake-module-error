.PHONY: all clean working headeronly failing
all: working headeronly failing
working:
	cd module-lib && cmake --workflow --preset default --fresh && cmake --build --preset default --target install
	cd module-exe && cmake --workflow --preset default --fresh && cmake --build --preset default --target test

failing:
	TEST_FORCING_MODULE_ERROR=ON $(MAKE) working

headeronly:
	cd header-lib && cmake --workflow --preset default --fresh && cmake --build --preset default --target install
	cd header-exe && cmake --workflow --preset default --fresh && cmake --build --preset default --target test

clean:
	rm -rf build stagedir

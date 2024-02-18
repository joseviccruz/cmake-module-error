#include "test-library/test_class.h"

#include <iostream>

#define STRINGIZE(...) #__VA_ARGS__

class LinkageIsWorking : public test::GoogleTest {};

int main() {
  std::cout << "The " STRINGIZE(LinkageIsWorking) "!\n";
  return 0;
}

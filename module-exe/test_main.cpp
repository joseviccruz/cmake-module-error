#include <iostream>

#define STRINGIZE(...) #__VA_ARGS__

import test;

class LinkageIsWorking : public test::GoogleTest {};

int main() {
  std::cout << "The " STRINGIZE(LinkageIsWorking) "!\n";
  return 0;
}

module;

#include <gtest/gtest.h>

export module test;

export namespace test {

class GoogleTest : public ::testing::Test {
 protected:
  void SetUp() override {}
  void TearDown() override {}
};

} // namespace test

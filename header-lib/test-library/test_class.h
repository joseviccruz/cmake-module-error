#ifndef TEST_LIBRARY_TEST_CLASS_H
#define TEST_LIBRARY_TEST_CLASS_H

#include <gtest/gtest.h>

namespace test {

class GoogleTest : public ::testing::Test {
 protected:
  void SetUp() override;
  void TearDown() override;
};

} // namespace test

#endif // TEST_LIBRARY_TEST_CLASS_H

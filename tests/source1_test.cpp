/******************************************************************************
* Copyright 2019-present, Joseph Garnier
* All rights reserved.
*
* This source code is licensed under the license found in the
* LICENSE file in the root directory of this source tree.
******************************************************************************/

#include "gtest/gtest.h"
#include "source1.h"

class Source1Test : public testing::Test
{
public:
	virtual void SetUp()
	{
		std::cout << "Source1Test: SetUp()" << std::endl;
	}

	virtual void TearDown()
	{
		std::cout << "Source1Test: TearDown()" << std::endl;
	}
};

TEST_F(Source1Test, Constructor)
{
	Source1 source1;
	int a = 1;
	int b = 1;
	EXPECT_EQ(a == b, true);
}

/******************************************************************************
* Copyright 2019-present, Joseph Garnier
* All rights reserved.
*
* This source code is licensed under the license found in the
* LICENSE file in the root directory of this source tree.
******************************************************************************/

#include "project-name/include1.h"
#include "project-name/include2.h"
#include "source1.h"
#include "sub1/sub1.h"
#include "sub2/sub2.h"
#include "project-name/project-name_pch.h"

int main() {
	std::cout << "Main: Hello, World!" << std::endl;
	Include1 include1;
	Include2 include2;
	Source1 source1;
	Sub1 sub1;
	Sub2 sub2;
	return 0;
}

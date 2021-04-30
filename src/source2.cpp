/******************************************************************************
* Copyright 2019-present, Joseph Garnier
* All rights reserved.
*
* This source code is licensed under the license found in the
* LICENSE file in the root directory of this source tree.
******************************************************************************/

#include "source2.h"
#include "project-name/project-name_pch.h"

Source2::Source2() noexcept
{
	Source3 source3;
	std::cout << "Source2: default constructor" << std::endl;
}

Source2::~Source2() noexcept
{
	std::cout << "Source2: destructor" << std::endl;
}
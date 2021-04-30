/******************************************************************************
* Copyright 2019-present, Joseph Garnier
* All rights reserved.
*
* This source code is licensed under the license found in the
* LICENSE file in the root directory of this source tree.
******************************************************************************/

#include "source3.h"
#include "project-name/project-name_pch.h"

Source3::Source3() noexcept
{
	Source4 source4;
	std::cout << "Source3: default constructor" << std::endl;
}

Source3::~Source3() noexcept
{
	std::cout << "Source3: destructor" << std::endl;
}
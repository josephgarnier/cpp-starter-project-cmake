/******************************************************************************
* Copyright 2019-present, Joseph Garnier
* All rights reserved.
*
* This source code is licensed under the license found in the
* LICENSE file in the root directory of this source tree.
******************************************************************************/

#include "source4.h"
#include "project-name/project-name_pch.h"

Source4::Source4() noexcept
{
	Source5 source5;
	std::cout << "Source4: default constructor" << std::endl;
}

Source4::~Source4() noexcept
{
	std::cout << "Source4: destructor" << std::endl;
}
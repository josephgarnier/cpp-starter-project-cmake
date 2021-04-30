/******************************************************************************
* Copyright 2019-present, Joseph Garnier
* All rights reserved.
*
* This source code is licensed under the license found in the
* LICENSE file in the root directory of this source tree.
******************************************************************************/

#include "source1.h"
#include "project-name/project-name_pch.h"

Source1::Source1() noexcept
{
	Source2 source2;
	std::cout << "Source1: default constructor" << std::endl;
}

Source1::~Source1() noexcept
{
	std::cout << "Source1: destructor" << std::endl;
}
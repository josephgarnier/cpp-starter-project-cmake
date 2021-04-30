/******************************************************************************
* Copyright 2019-present, Joseph Garnier
* All rights reserved.
*
* This source code is licensed under the license found in the
* LICENSE file in the root directory of this source tree.
******************************************************************************/

#include "sub1.h"
#include "project-name/project-name_pch.h"

Sub1::Sub1() noexcept
{
	std::cout << "Sub1: default constructor" << std::endl;
}

Sub1::~Sub1() noexcept
{
	std::cout << "Sub1: destructor" << std::endl;
}
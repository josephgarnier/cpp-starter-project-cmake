/******************************************************************************
* Copyright 2019-present, Joseph Garnier
* All rights reserved.
*
* This source code is licensed under the license found in the
* LICENSE file in the root directory of this source tree.
******************************************************************************/

#include <string>
#include <iostream>

class Include1
{
public:
	Include1() noexcept // Default constructor
	{
		std::cout << "Include1: default constructor" << std::endl;
	}
	
	virtual ~Include1() noexcept // Destructor
	{
		std::cout << "Include1: destructor" << std::endl;
	}
};

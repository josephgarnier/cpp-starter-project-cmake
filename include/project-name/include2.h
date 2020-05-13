/******************************************************************************
* Copyright 2019-present, Joseph Garnier
* All rights reserved.
*
* This source code is licensed under the license found in the
* LICENSE file in the root directory of this source tree.
******************************************************************************/

#include <string>
#include <iostream>

class Include2
{
public:
	Include2() noexcept // Default constructor
	{
		std::cout << "Include2: default constructor" << std::endl;
	}
	
	virtual ~Include2() noexcept // Destructor
	{
		std::cout << "Include2: destructor" << std::endl;
	}
};

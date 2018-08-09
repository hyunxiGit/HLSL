// playground1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <algorithm>

using namespace std;

int RGB_HSV(float r, float g, float b);

int main()
{
	cout << "this is a test" << endl;
	RGB_HSV(33 ,80, 127);
    return 0;
}

int RGB_HSV(float r, float g, float b)
{
	r = r / 255;
	g = g / 255;
	b = b / 255;

	float M = max(max(r, g), b);
	float m = min(min(r, g), b);
	float C = M - m;
	float H;

	if (C > 0)
	{
		if (r == M)
		{
			H = fmod((g - b) / C, 6) / 6;
		}
		else if (g == M)
		{
			H = ((b - r) / C + 2) / 6;
		}
		else
		{
			H = ((r - g) / C + 4) / 6;
		}
	}
	else
	{
		H = 0.0f;
	}

	float S = C / M;
	float V = M ;
	cout << "(" << H << "," << S << "," << V << ")";
	return 1;
}



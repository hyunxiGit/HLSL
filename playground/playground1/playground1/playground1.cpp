// playground1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct C_RGB // 255,255,255
{
	float r;
	float g;
	float b;
};

struct C_HSV
{
	float h;
	float s;
	float v;
};

C_HSV RGB_HSV(C_RGB in);
int getWeight(C_RGB base, vector<C_RGB>* detailVec, vector <float> & weight);

int main()
{
	vector<float> wVec;

	C_RGB myCol;
	myCol.r = 51;
	myCol.g = 24;
	myCol.b = 83;

	C_HSV r = RGB_HSV(myCol);
	cout << "(" << r.h << "," << r.s << "," << r.v << ")";

	vector<C_RGB> detailVec;

	C_RGB d1;
	d1.r = 0.1;
	d1.g = 0.1;
	d1.b = 0.1;

	C_RGB d2;
	d2.r = 0.2;
	d2.g = 0.3;
	d2.b = 0.3;

	detailVec.push_back(d1);
	detailVec.push_back(d2);

	getWeight(myCol, &detailVec, wVec);
	
    return 0;
}

C_HSV RGB_HSV(C_RGB in)
{
	C_HSV out;

	float r = in.r/ 255;
	float g = in.g / 255;
	float b = in.b / 255;

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
	out.h = H;
	out.s = C / M;
	out.v = M;

	return out;
}

int getWeight(C_RGB base, vector<C_RGB>* detailVec, vector <float> & weight)
{
	C_HSV _base = RGB_HSV(base);
	for (int i = 0; i < (*detailVec).size(); i++)
	{
		cout << "..........................." << endl;
		cout << (*detailVec)[i].r << endl;
		cout << (*detailVec)[i].g << endl;
		cout << (*detailVec)[i].b << endl;
	}
	return 1;
}

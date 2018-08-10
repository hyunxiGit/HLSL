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

struct float3
{
	float x;
	float y;
	float z;
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
	d1.r = 255;
	d1.g = 45;
	d1.b = 124;

	C_RGB d2;
	d2.r = 42;
	d2.g = 156;
	d2.b = 200;

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
	out.h = H; //有时会有负数结果
	out.s = C / M;
	out.v = M;

	return out;
}

int getWeight(C_RGB base, vector<C_RGB>* detailVec, vector <float> & weight)
{
	C_HSV _base = RGB_HSV(base);
	// RGB to HSV
	vector<C_HSV> _detailVec;
	for (int i = 0; i < (*detailVec).size(); i++)
	{
		C_HSV _detail = RGB_HSV((*detailVec)[i]);
		_detailVec.push_back(_detail);
	}

	//dstance 
	vector<float> _distance;
	float C = 0;
	vector <float> disVec;
	for (int i = 0; i < _detailVec.size(); i++)
	{
		cout << "..........................." << endl;
		cout << (_detailVec[i]).h << endl;
		cout << (_detailVec[i]).s << endl;
		cout << (_detailVec[i]).v << endl;

		float3 v;
		v.x= _base.h - _detailVec[i].h;
		v.y= _base.s - _detailVec[i].s;
		v.z= _base.v - _detailVec[i].v;

		v.x = min(v.x, 1.0f - v.x);
		float dis = 1.0f / pow((v.x*v.x + v.y*v.y + v.z*v.z), 1);
		_distance.push_back(dis);
		cout << "dis = " << dis;
		C += dis;
	}
	cout << endl;
	for (int i = 0; i < _detailVec.size(); i++)
	{
		float w = _distance[i] / C;
		cout << "w = " << w << endl;;
	}



	return 1;
}

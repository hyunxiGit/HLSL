#ifndef COLORBASEBLENDING_HLSLI
#define COLORBASEBLENDING_HLSLI
#include "Common.hlsli"
#include "pbrBase.hlsli"
#define LIS float4(1,0,0,0)

void getWeight(float4 baseColor, inout float weight[2], float4 d1HSV, float4 d2HSV, float blendPower)
{
    float4 col;
    float3 bHSV = RGBtoHSV(baseColor.rgb);

    //calculate distance 

    float3 detailVec[2] = { RGBtoHSV(d1HSV.xyz), RGBtoHSV(d2HSV.xyz) };
    float distance[2] = { 0, 0 };
    float C = 0;
    
    for (int i = 0; i < 2; i++)
    {
        float3 v;
        v.x = bHSV.x - detailVec[i].x;
        v.y = bHSV.y - detailVec[i].y;
        v.z = bHSV.z - detailVec[i].z;

        v.x = min(v.x, 1.0 - v.x);

        float dis = 1.0f / pow(dot(v, v), blendPower);
        distance[i] = dis;
        C += dis;
    }

    for (int j = 0; j < 2; j++)
    {
        weight[j] = saturate(distance[j] / C);
    }
}


#endif
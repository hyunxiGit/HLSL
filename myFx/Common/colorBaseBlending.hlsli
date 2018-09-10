#ifndef COLORBASEBLENDING_HLSLI
#define COLORBASEBLENDING_HLSLI
#include "Common.hlsli"
#include "pbrBase.hlsli"
#define LIS float4(1,0,0,0)

struct weightData
{
    float weight[2];
    float4 blendColor[3];
    float blendPower;
};

struct textureSet
{
    float4 ab;
    float3 no;
    float  ro;
    float  me;
};

void getWeight(inout weightData wd)
{
    int n = 2;
    float4 col;
    float3 bHSV = RGBtoHSV(wd.blendColor[0].rgb);

    float3 detailVec[2];
    float distance[2];

    float C = 0;
    for (int i = 0; i < n; i++)
    {
        distance[i] = 0;

        detailVec[i] = RGBtoHSV(wd.blendColor[i+1].xyz);

        float3 v;
        v.x = bHSV.x - detailVec[i].x;
        v.y = bHSV.y - detailVec[i].y;
        v.z = bHSV.z - detailVec[i].z;

        v.x = min(v.x, 1.0 - v.x);

        float dis = 1.0f / pow(dot(v, v), wd.blendPower);
        distance[i] = dis;
        C += dis;
    }

    for (int j = 0; j < n; j++)
    {
        wd.weight[j] = saturate(distance[j] / C);
    }
}

void DetailBlend(inout textureSet ts[3], float weight[2],float blendStrength)
{
    int n = 2;
    textureSet base = ts[0];
    textureSet d1 = ts[1];
    textureSet d2 = ts[2];

    //abedo
    float4 ab_d = float4(0,0,0,0);
    float3 ab_n = float3(0, 0, 0);

    for (int i = 0; i < n; i++)
    {
        ab_d += ts[i + 1].ab * weight[i];
        ab_n += ts[i + 1].no * weight[i];
    }
    base.ab = base.ab * (1 - blendStrength) + ab_d * blendStrength;

    ab_n = blendNormal(base.no, ab_n);
    base.no = base.no * (1 - blendStrength) + ab_n * blendStrength;

    ts[0] = base;
}
#endif
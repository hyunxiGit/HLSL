#ifndef COLORBASEBLENDING_HLSLI
#define COLORBASEBLENDING_HLSLI
#include "Common.hlsli"
#include "pbrBase.hlsli"

//detail map amount, da_ detail map + base map
#define da 4
#define da_ 5
struct weightData
{
    float weight[da];
    float4 blendColor[da_];
    float blendPower;
};

struct textureSet
{
    float4 ab;
    float3 no;
    float  ro;
    float  me;
};

void getWeight1(inout weightData wd)
{
    //calculate distance of the assigned color and base color
    float4 col;
    float3 bHSV = RGBtoHSV(wd.blendColor[0].rgb);

    float3 detailVec[da];
    float distance[da];

    float C = 0;
    for (int i = 0; i < da; i++)
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

    for (int j = 0; j < da; j++)
    {
        wd.weight[j] = saturate(distance[j] / C);
    }
}

void DetailBlend(inout textureSet ts[da_], float weight[da], float blendStrength)
{
    textureSet base = ts[0];

    //abedo
    float4 ab_d = float4(0,0,0,0);
    float3 no_d = float3(0, 0, 0);
    float  ro_d = 0;
    float  me_d = 0;

    for (int i = 0; i < da; i++)
    {
        ab_d += ts[i + 1].ab * weight[i];
        no_d += ts[i + 1].no * weight[i];
        ro_d += ts[i + 1].ro * weight[i];
        me_d += ts[i + 1].me * weight[i];
    }
    base.ab = base.ab * (1 - blendStrength) + ab_d * blendStrength;

    no_d = blendNormal(base.no, no_d);
    base.no = base.no * (1 - blendStrength) + no_d * blendStrength;
    base.ro = base.ro * (1 - blendStrength) + ro_d * blendStrength;
    base.me = base.me * (1 - blendStrength) + me_d * blendStrength;

    ts[0] = base;
}
#endif
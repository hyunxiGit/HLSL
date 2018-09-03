#include "Common/Common.hlsli"
#define BASE_A "D:/work/HLSL/texture/blendBase.png"
//d1
#define D1   "D:/work/HLSL/texture/dEarth.tga"
#define D1_A "D:/work/HLSL/texture/earth_a.jpg"
//d2
#define D2   "D:/work/HLSL/texture/dGrass.tga"
#define D2_A "D:/work/HLSL/texture/grass_a.jpg"


SCRIPT_FX("Technique=Main;")

//lights

float3 Lamp0Pos : POSITION <
    string Object = "PointLight0";
    string UIName =  "Light Position";
    string Space = "World";
	int refID = 0;
> = { -0.5f, 2.0f, 1.25f };
int myC = 0;


//base map
TEXTURE2D(blendBase, blendBaseSampler, BASE_A, "Base Map",0)


//blending parameters
DECLARE_FLOAT_UI(n, 0.0f, 15.0f, 8, "blend power", 1)
DECLARE_FLOAT_UI(m, 0.0f, 1.0f, 0.0f, "blend strength", 2)


bool detailColor <
	string UIName = "Use detail Map Color";
    int UIOrder = 3;
> = false;

//detail 1
DECLARE_COLOR_UI(d1HSV,float4(0.299f, 0.206f, 0.12f, 1.0f),"d1",4)
TEXTURE2D(d1Map, d1Map_Sampler, D1, "d1", 5)

TEXTURE2D(d1aMap, d1aMap_Sampler, D1_A, "d1 abedo", 6)



//detail 2
DECLARE_COLOR_UI(d2HSV, float4(0.23f, 0.46f, 0.12f, 1.0f), "d2", 7)
TEXTURE2D(d2Map, d2Map_Sampler, D2, "d2", 8)
TEXTURE2D(d2aMap, d2aMap_Sampler, D2_A, "d2 abedo", 9)


struct VS_IN
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
    float3 nor : NORMAL;
    float4 col : COLOR;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 p_w : TEXCOORD1;
    float3 viw : TEXCOORD2;
    float3 nor : TEXCOORD3;
    float4 col : TEXCOORD4;
};


PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    float3 pw = mul(IN.pos, world).xyz;
    OUT.pos = mul(IN.pos, wvp);
    OUT.p_w = mul(IN.pos, world);
    OUT.uv = IN.uv;
    OUT.viw.xyz = normalize((viewI[3].xyz - pw).xyz);
    OUT.nor = IN.nor;
    OUT.col = IN.col;
    return (OUT);
}


void getWeight(float4 baseColor, inout float weight [2])
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

        float dis = 1.0f / pow(dot(v, v), n);
        distance[i] = dis;
        C += dis;
    }

    for (int j = 0; j < 2; j++)
    {
        weight[j] = saturate(distance[j] / C);
    }
}

void getWeightImg(float4 baseColor, float4 vertexColor , int C, inout float weight[2])
{
    float a = saturate(vertexColor.r + vertexColor.g + vertexColor.b);
    
    if (C==0)
    {
        //use color
        float4 b_v = float4(baseColor.xyz * (1 - a) + a * vertexColor.zyx, baseColor.w);
        getWeight(b_v, weight);
    }
    else if (C==1)
    {
        //use channel
        float3 V1 = d1HSV * vertexColor.b;
        float3 V2 = d2HSV * vertexColor.g;
        float4 b_v = float4(baseColor.xyz * (1 - a) + V1 + V2, 1);
        getWeight(b_v, weight);
    }
    
}

float3 blend(float3 a, float3 b)
{
    float3 r;
    if (a.r+a.g+a.b <1.5)
    {
        r = 2 * a * b;
    }
    else
    {
        r = 1 - 2 * (1 - a) * (1 - b);
    }
    saturate(r);
    return r;
}

float4 PS_VERTEX(PS_IN IN , uniform int C) : SV_Target
{
    float4 col;

    //maps
    int UVscale = 5;
   
    float4 b_a  = blendBase.Sample(blendBaseSampler, IN.uv);
    float4 d1   = d1Map.Sample(d1Map_Sampler, IN.uv* UVscale);
    float4 d1_a = float4(d1.bbb, 1);
    float4 d1_n = float4(d1.r, d1.g, 1,1);
    float4 d1_r = float4(d1.a, d1.a, d1.a, 1);

    float4 d2   = d2Map.Sample(d2Map_Sampler, IN.uv * UVscale);
    float4 d2_a = float4(d2.bbb, 1);
    float4 d2_n = float4(d2.rg, 1, 1);
    float4 d2_r = float4(d2.a, d2.a, d2.a, 1);
   
    //get weight
    float weight[2] = { 0, 0 };
    getWeightImg(b_a, IN.col, C, weight);
   
    float blend0 = 1.0f - m;
    float blend1 = m;

    //abedo
    float3 diffuse;
    if (detailColor)
    {
        //color
        d1_a = d1aMap.Sample(d1aMap_Sampler, IN.uv * UVscale);
        d2_a = d2aMap.Sample(d2aMap_Sampler, IN.uv * UVscale);
        diffuse = b_a * blend0 + (d1_a * weight[0] + d2_a * weight[1]) * blend1;
    }
    else 
    {
        //grey
        diffuse = b_a.xyz * blend0 + blend(b_a.xyz, (d1_a * weight[0] + d2_a * weight[1]).xyz) * blend1;
    }

    //normal
    float3 b_n = IN.nor;
    d1_n.xyz = d1_n.xyz * 2.0f - 1.0f;
    d1_n.xyz = normalize(float3((d1_n.xy * weight[0] + b_n.xy), b_n.z));
    d2_n.xyz = d2_n.xyz * 2.0f - 1.0f;
    d2_n.xyz = normalize(float3((d2_n.xy * weight[1] + b_n.xy), b_n.z));
    float3 N = normalize(float3(b_n.xy * blend0 + (d1_n.xy + d2_n.xy) * blend1, b_n.z));
    N = mul(N, (float3x3) world);

    //roughness 2 specular
    float b_s = 0;
    float p1 = 5.5f;
    float p2 = 5;
    float s1 = saturate(pow(1 - d1_r.x, p1));
    float s2 = saturate(pow(1 - d2_r.x, p2));
    float specular = b_s * blend0 + (s1 * weight[0] + s2 * weight[1]) * blend1;

    //lighting
    float3 A = float3(0.36f, 0.37f, 0.38f) * 0.01;
    float3 L = normalize(Lamp0Pos - IN.p_w);
    float3 V = IN.viw;

    float3 Hn = normalize(L + V);

    float4 litV = lit(dot(L, N), dot(Hn, N), 5);
    float3 D = litV.y * diffuse;
    float3 S = litV.y * litV.z * specular * (diffuse * 0.5 + float3(1, 1, 1) * 0.5);

    col.xyz = D;
    col.w = 1;
    return col;
}


fxgroup dx11
{

    technique11 VertexByColor<
            string script = "Pass = p0;";
            >
    {
        pass p0 <
            string Script = "Draw=geometry;";
            >
        {
            SetVertexShader(CompileShader(vs_5_0, VS()));
            SetGeometryShader(NULL);
            SetPixelShader(CompileShader(ps_5_0, PS_VERTEX(0)));
        }
    }

    technique11 VertexByChannel<
                string script = "Pass = p0;";
                >
    {
        pass p0 <
                string Script = "Draw=geometry;";
                >
        {
            SetVertexShader(CompileShader(vs_5_0, VS()));
            SetGeometryShader(NULL);
            SetPixelShader(CompileShader(ps_5_0, PS_VERTEX(1)));
        }
    }

}
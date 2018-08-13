#include "Common/Common.hlsli"
#define BASE_A "D:/work/HLSL/texture/blendBase.tga"
//d1
#define D1_A "D:/work/HLSL/texture/earth_a.jpg"
#define D1_N "D:/work/HLSL/texture/earth_n.jpg"
#define D1_R "D:/work/HLSL/texture/earth_r.jpg"
//d2
#define D2_A "D:/work/HLSL/texture/grass_a.jpg"
#define D2_N "D:/work/HLSL/texture/grass_n.jpg"
#define D2_R "D:/work/HLSL/texture/grass_r.jpg"

string ParamID = "0x003";

float Script : STANDARDSGLOBAL <
    string UIWidget = "none";
    string ScriptClass = "object";
    string ScriptOrder = "standard";
    string ScriptOutput = "color";
    string Script = "Technique=Main;";
> = 0.8;

struct VS_IN
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
    float3 nor : NORMAL;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 viw : TEXCOORD2;
    float3 nor : TEXCOORD3;
};

//ui elements
//lights

float3 Lamp0Pos : POSITION <
    string Object = "PointLight0";
    string UIName =  "Light Position";
    string Space = "World";
	int refID = 0;
> = { -0.5f, 2.0f, 1.25f };

//base map

Texture2D<float4> blendBase < 
	string UIName = "Base Map";
    string name = BASE_A; 
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
    int UIOrder = 0;
>;

//blending parameters
int n <
    string UIName = "blend power";
	string UIWidget = "slider";
	float UIMin = 0.0f;
	float UIMax = 50.0f;	
    int UIOrder = 1;
> = 8;

float m <
    string UIName = "blend strength";
	string UIWidget = "slider";
	float UIMin = 0.0f;
	float UIMax = 1.0f;	
    int UIOrder = 2;
> = 0.0f;

//detail 1

float4 d1HSV <
	string UIName = "d1";
	string UIWidget = "Color";
    int UIOrder = 3;
> = float4(0.39f, 0.26f, 0.157f, 1.0f);

Texture2D<float4> d1aMap < 
	string UIName = "d1 abedo";
	string ResourceType = "2D";
    string name = D1_A; 
    int Texcoord = 0;
	int MapChannel = 1;
    int UIOrder = 4;
>;

Texture2D<float4> d1nMap < 
	string UIName = "d1 normal";
	string ResourceType = "2D";
    string name = D1_N; 
    int Texcoord = 0;
	int MapChannel = 1;
    int UIOrder = 5;
>;

Texture2D<float4> d1rMap < 
	string UIName = "d1 rough";
	string ResourceType = "2D";
    string name = D1_R; 
    int Texcoord = 0;
	int MapChannel = 1;
    int UIOrder = 6;
>;

//detail 2

float4 d2HSV <
	string UIName = "d2";
	string UIWidget = "Color";
    int UIOrder = 7;
> = float4(0.149f, 0.537f, 0.098f, 1.0f);

//float3 d1HSV = detailC1.xyz; //red

Texture2D<float4> d2aMap < 
	string UIName = "d2 abedo";
	string ResourceType = "2D";
    string name = D2_A; 
    int Texcoord = 0;
	int MapChannel = 1;
>;

Texture2D<float4> normalmap2 < 
	string UIName = "d2 normal";
	string ResourceType = "2D";
    string name = D2_N; 
    int Texcoord = 0;
	int MapChannel = 1;
>;

Texture2D<float4> roughmap2 < 
	string UIName = "d2 rough";
	string ResourceType = "2D";
    string name = D2_R; 
    int Texcoord = 0;
	int MapChannel = 1;
>;

SamplerState blendBaseSampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

SamplerState d1nMap_Sampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

SamplerState d1rMap_Sampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};


SamplerState d1aMap_Sampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};
SamplerState d2aMap_Sampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    float3 pw = mul(IN.pos, world).xyz;
    OUT.pos = mul(IN.pos, wvp);
    OUT.uv = IN.uv;
    OUT.viw.xyz = normalize((viewI[3].xyz - pw).xyz);
    OUT.nor = IN.nor;
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
        weight[j] = distance[j] / C;
    }
}

float4 PS(PS_IN IN) : SV_Target
{
    float4 col;
    int UVscale = 5;
    float4 bCol = blendBase.Sample(blendBaseSampler, IN.uv);
    float4 d1_a = d1aMap.Sample(d1aMap_Sampler, IN.uv * UVscale);
    float4 d2_a = d2aMap.Sample(d2aMap_Sampler, IN.uv * UVscale);
    float4 d1_n= d1nMap.Sample(d1nMap_Sampler, IN.uv * UVscale);
    float4 d1_r = d1rMap.Sample(d1rMap_Sampler, IN.uv * UVscale);
    float specular = saturate(pow(0.7 - d1_r.x, 4) * 40);
    specular = saturate(pow(1 - d1_r.x, 5));
    
    //get weight
    float weight[2] = { 0, 0 };
    getWeight(bCol, weight);

    //abedo
    float3 diffuse = bCol * (1 - m) + (d1_a * weight[0] + d2_a * weight[1]) * m;
    
    //normal
    float3 N = d1_n * 2.0f - 1.0f;
    N = normalize(float3((N.xy + IN.nor.xy), IN.nor.z));
    N = normalize(mul(N, (float3x3) world));
    
    float3 L = normalize(Lamp0Pos - mul(IN.pos , world).xyz);
    float3 V = IN.viw;

    float3 Hn = normalize(L + V);

    float4 litV = lit(dot(L, N), dot(Hn, N), 5);
    float3 D = litV.y * diffuse;
    float3 S = litV.y * litV.z * specular * (diffuse * 0.5 + float3(1, 1, 1)*0.5);

    col.xyz = D +S;
    
    col.w = 1;
    return col;
}

struct vertex2pixel
{
    float4 pos : SV_Position;
    float2 uv : TEXCOORD0;
    float3 lightTangent : TEXCOORD1;
};


fxgroup dx11
{

technique11 Main<
    string script = "Pass = p0;";
    >
{
    pass p0 <
    string Script = "Draw=geometry;";
    >
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, PS()));
    }

}

}
#include "Common/colorBaseBlending.hlsli"
#include "Common/pbrBase.hlsli"
SCRIPT_FX("Technique=Main_11;")

DECLARE_COLOR(abedo, float4(1,0.85,0.61,1), "abedo color")
//DECLARE_COLOR(abedo, LIS, "abedo color")
DECLARE_FLOAT(roughness, 0.05, 0.99, 0.5, "roughness")
DECLARE_FLOAT(metalness, 0, 1, 1, "metalness")
DECLARE_FLOAT(F0, 0, 1, 0.2, "fresnel")
DECLARE_LIGHT(myLight, "PointLight0", "Light Position", 0)
DECLARE_FLOAT(EnvI, 0, 1, 0.2f, "cube intensity")
DECLARE_FLOAT(bumpScale, 0, 1, 0.25, "normal intensity")

DECLARE_FLOAT_UI(n, 0.0f, 15.0f, 8, "blend power", 1)
DECLARE_FLOAT_UI(m, 0.0f, 1.0f, 0.0f, "blend strength", 2)


//office environment
#define BASE_A "D:/work/HLSL/texture/blendBase.png"
#define BASE_N "D:/work/HLSL/texture/base_160.png"
#define BASE_R "D:/work/HLSL/texture/defaultR.png"
#define BASE_M "D:/work/HLSL/texture/defaultM.png"
#define CUBE_M "D:/work/HLSL/texture/default_reflection_cubic.dds"

#define D1_A "D:/work/HLSL/texture/grass_a.jpg"
#define D1_N "D:/work/HLSL/texture/grass_n.jpg"
#define D1_R "D:/work/HLSL/texture/grass_r.jpg"

#define D2_A "D:/work/HLSL/texture/earth_a.jpg"
#define D2_N "D:/work/HLSL/texture/earth_n.jpg"
#define D2_R "D:/work/HLSL/texture/earth_r.jpg"


//home environment
//#define BASE_A "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_a.png"
//#define BASE_N "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_n.png"
//#define BASE_R "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_r.png"
//#define BASE_M "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_m.png"
//#define CUBE_M "C:\\MyGit\\HLSL\\texture\\pbrT\\default_reflection_cubic.dds"

DECLARE_CUBE(EnvMap, EnvMapSampler, CUBE_M, "cube")
TEXTURE2D(Amap, a_Sampler, BASE_A, "abedo")
TEXTURE2D(Nmap, n_Sampler, BASE_N, "normal")
TEXTURE2D(Rmap, r_Sampler, BASE_R, "roughness")
TEXTURE2D(Mmap, m_Sampler, BASE_M, "metalness")

DECLARE_COLOR(d1HSV, float4(0.299f, 0.206f, 0.12f, 1.0f), "d1")
TEXTURE2D(D1Amap, D1A_Sampler, D1_A, "d1 abedo")
TEXTURE2D(D1Nmap, D1N_Sampler, D1_N, "d1 normal")
TEXTURE2D(D1Rmap, D1R_Sampler, D1_R, "d1 roughness")

DECLARE_COLOR(d2HSV, float4(0.23f, 0.46f, 0.12f, 1.0f), "d2")
TEXTURE2D(D2Amap, D2A_Sampler, D2_A, "d2 abedo")
TEXTURE2D(D2Nmap, D2N_Sampler, D2_N, "d2 normal")
TEXTURE2D(D2Rmap, D2R_Sampler, D2_R, "d2 roughness")

struct VS_IN
{
    float4 P_O : POSITION;
    float3 N : NORMAL;
    float3 T : TANGENT;
    float3 B : BINORMAL;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 P_P : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 P_W : TEXCOORD1;
    float3 N_O : TEXCOORD2;
    float3 B_O : TEXCOORD3;
    float3 T_O : TEXCOORD4;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.P_P = mul(IN.P_O, wvp);
    OUT.P_W = mul(IN.P_O, world);
    OUT.N_O = IN.N;
    OUT.B_O = IN.B;
    OUT.T_O = IN.T;
    OUT.uv = IN.uv;
    return OUT;
}

void useMapBlend(inout float4 Ab, inout float Ro, inout float Me, inout float3 no, float useMap)
{
    Ab = lerp(abedo, Ab, useMap);
    Ro = lerp(roughness, Ro, useMap);
    Me = lerp(metalness, Me, useMap);
    no = lerp(float3(0, 0, 1), no, useMap);
}

float4 PS(PS_IN IN) : SV_Target
{

    float4 a = LIS;

    float3 N_W = mul(IN.N_O, world);
    float3 B_W = mul(IN.B_O, world);
    float3 T_W = mul(IN.T_O, world);
    //prepare map
    textureSet base;
    base.ab = Amap.Sample(a_Sampler, IN.uv);
    base.no = processNMap(Nmap, n_Sampler, IN.uv);
    base.ro = Rmap.Sample(r_Sampler, IN.uv);
    base.me = Amap.Sample(m_Sampler, IN.uv);

    int UVscale = 5;

    textureSet tsd1;
    tsd1.ab = D1Amap.Sample(D1A_Sampler, IN.uv * UVscale);
    tsd1.no = processNMap(D1Nmap, D1N_Sampler, IN.uv * UVscale);
    //tsd1.ro = Ro;
    //tsd1.me = Me;

    textureSet tsd2;
    tsd2.ab = D2Amap.Sample(D2A_Sampler, IN.uv * UVscale);
    tsd2.no = processNMap(D2Nmap, D2N_Sampler, IN.uv * UVscale);
    //tsd2.ro = Ro;
    //tsd2.me = Me;


    //prepare detail map

    float weight[2] = { 0, 0 };
    weightData wd;
    wd.weight = weight;
    wd.blendColor[0] = base.ab;
    wd.blendColor[1] = d1HSV;
    wd.blendColor[2] = d2HSV;
    wd.blendPower = n;
    getWeight(wd);

    //float3 BN = blendNormal(nMap, d1nMap);

    textureSet ts[3];
    ts[0] = base;
    ts[1] = tsd1;
    ts[2] = tsd2;

    DetailBlend(ts, wd.weight, m);
    float4 Ab = ts[0].ab;

    float Ro = base.ro;
    float Me = base.me;
    float3 nMap = base.no;

    float3 N = applyN(nMap, B_W, T_W, N_W, bumpScale);

    int useIBL = 1;
    float4 COL = { 0, 0, 1, 1 };
    float3 L = normalize(myLight - IN.P_W.xyz);
    float3 V = normalize((viewI[3] - IN.P_W).xyz);
    float3 H = normalize(V + L);

    float4 D = float4(0, 0, 0, 0);
    float4 S = float4(0, 0, 0, 0);

    float4 SC = lerp(DielectricSpec, Ab, Me);
    float4 DC = Ab * (DielectricSpec.a * (1 - Me));
    
    float NoV = saturate(dot(N, V));
    float NoL = dot(N, L);
    float NoH = saturate(dot(N, H));
    float VoH = saturate(dot(V, H));
    float LoH = saturate(dot(L, H));
    float R2 = Ro * Ro;

    if (NoL > 0)
    {
        D += NoL;
        // D = DisneyDiffuse(NoV, NoL, LoH, R2);
        S += Cook_Torrance(Ro, N, L, V, H, F0);
    }

    if (useIBL == 1)
    {
        S.xyz += EnvI * specularIBL(EnvMap, EnvMapSampler, float3(1, 1, 1), Ro, N, V);
        D.xyz += EnvI * diffuseIBL(EnvMap, EnvMapSampler, float3(1, 1, 1), Ro, N, V);
    }

    COL = D * DC + S * SC;
    COL.w = 1;

   // COL = dot(N, L);

    return COL;
}

fxgroup dx11
{

technique11 Main_11 <
	string Script = "Pass=p0;";
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
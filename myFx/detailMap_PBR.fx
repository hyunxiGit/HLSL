#include "Common/colorBaseBlending.hlsli"
#include "Common/pbrBase.hlsli"
SCRIPT_FX("Technique=Main_11;")

//office environment
#define CUBE_M "D:/work/HLSL/texture/default_reflection_cubic.dds"

#define BLENDMASK "C:/Users/hyunx/Desktop/detailMap/max/texture/reverbank_mask.png"

#define BASE_A "C:/Users/hyunx/Desktop/detailMap/max/texture/reverbank_d.tga"
#define BASE_MRN "C:/Users/hyunx/Desktop/detailMap/max/texture/reverbank_mrn.tga"
#define BASE_N "C:/Users/hyunx/Desktop/detailMap/max/texture/riverbank_n.tga"

#define D1_A "D:/work/HLSL/texture/d1_ab.png"
#define D1_MRN "D:/work/HLSL/texture/d1_mrn.tga"

#define D2_A "D:/work/HLSL/texture/d2_ab.png"
#define D2_MRN "D:/work/HLSL/texture/d2_mrn.tga"

#define D3_A "D:/work/HLSL/texture/d3_ab.png"
#define D3_MRN "D:/work/HLSL/texture/d3_mrn.tga"

#define D4_A "D:/work/HLSL/texture/d4_ab.png"
#define D4_MRN "D:/work/HLSL/texture/d4_mrn.tga"

//home environment
//#define BASE_A "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_a.png"
//#define BASE_N "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_n.png"
//#define BASE_R "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_r.png"
//#define BASE_M "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_m.png"
//#define CUBE_M "C:\\MyGit\\HLSL\\texture\\pbrT\\default_reflection_cubic.dds"

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

DECLARE_CUBE(EnvMap, EnvMapSampler, CUBE_M, "cube")
TEXTURE2D(Amap, a_Sampler, BASE_A, "abedo")
TEXTURE2D(MRNmap, mrn_Sampler, BASE_MRN, "MRN")
TEXTURE2D(Nmap, n_Sampler, BASE_N, "normal")

TEXTURE2D(BlendMap, Blend_Sampler, BLENDMASK, "blend map")

DECLARE_COLOR(d1HSV,float4(0.23f, 0.46f, 0.12f, 1.0f), "d1")
TEXTURE2D(D1Amap, D1A_Sampler, D1_A, "d1 abedo")
TEXTURE2D(D1MRNmap, D1MRN_Sampler, D1_MRN, "d1 MRN")

DECLARE_COLOR(d2HSV, float4(0.299f, 0.206f, 0.12f, 1.0f), "d2")
TEXTURE2D(D2Amap, D2A_Sampler, D2_A, "d2 abedo")
TEXTURE2D(D2MRNmap, D2MRN_Sampler, D2_MRN, "d2 MRN")

DECLARE_COLOR(d3HSV, float4(0, 0, 1.0f, 1.0f), "d3")
TEXTURE2D(D3Amap, D3A_Sampler, D3_A, "d3 abedo")
TEXTURE2D(D3MRNmap, D3MRN_Sampler, D3_MRN, "d3 MRN")

DECLARE_COLOR(d4HSV, float4(0.86f, 1.0f, 0.0f, 1.0f), "d4")
TEXTURE2D(D4Amap, D4A_Sampler, D4_A, "d4 abedo")
TEXTURE2D(D4MRNmap, D4MRN_Sampler, D4_MRN, "d4 MRN")

int b_mode <
	string UIName = "blend";
	string UIWidget = "slider";
	float UIMin = 0;
	float UIMax = 1;	
> = 1;

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

struct maps
{
    float3 normal;
    float1 metalness;
    float1 roughness;
};

void decodeMap(float4 mrnMap, inout textureSet maps)
{
    maps.no = processNMap(normalize(float3(mrnMap.b, mrnMap.a, 1)));
    maps.ro = mrnMap.g;
    maps.me = mrnMap.r;
}

float4 PS(PS_IN IN) : SV_Target
{
    float3 N_W = mul(IN.N_O, world);
    float3 B_W = mul(IN.B_O, world);
    float3 T_W = mul(IN.T_O, world);

    //prepare map
    textureSet base;
    base.ab = Amap.Sample(a_Sampler, IN.uv);
    float4 mrn = MRNmap.Sample(mrn_Sampler, IN.uv);
    decodeMap(mrn, base);
    float3 nMap = processNMap(Nmap.Sample(n_Sampler, IN.uv).xyz);
    base.no = nMap;

    int UVscale = 5;

    textureSet tsd1;
    tsd1.ab = D1Amap.Sample(D1A_Sampler, IN.uv * UVscale);
    mrn = D1MRNmap.Sample(D1MRN_Sampler, IN.uv);
    decodeMap(mrn, tsd1);

    textureSet tsd2;
    tsd2.ab = D2Amap.Sample(D2A_Sampler, IN.uv * UVscale);
    mrn = D2MRNmap.Sample(D2MRN_Sampler, IN.uv);
    decodeMap(mrn, tsd2);

    textureSet tsd3;
    tsd3.ab = D3Amap.Sample(D3A_Sampler, IN.uv * UVscale);
    mrn = D3MRNmap.Sample(D3MRN_Sampler, IN.uv);
    decodeMap(mrn, tsd3);

    textureSet tsd4;
    tsd4.ab = D4Amap.Sample(D4A_Sampler, IN.uv * UVscale);
    mrn = D4MRNmap.Sample(D4MRN_Sampler, IN.uv);
    decodeMap(mrn, tsd4);

    //prepare detail map
    float weight[da] = { 0, 0, 0 ,0};
    weightData wd;
    wd.weight = weight;
    wd.blendPower = n;
    if (b_mode == 0)
    {
        wd.blendColor[0] = base.ab;
        wd.blendColor[1] = d1HSV;
        wd.blendColor[2] = d2HSV;
        wd.blendColor[3] = d3HSV;
        wd.blendColor[4] = d4HSV;
    }
    if (b_mode == 1)
    {
        wd.blendColor[0] = BlendMap.Sample(Blend_Sampler, IN.uv);
        wd.blendColor[1] = float4(1,0,0,1);
        wd.blendColor[2] = float4(0, 1 , 0,1);
        wd.blendColor[3] = float4(0, 0, 1,1);
        wd.blendColor[4] = float4(1, 1, 0,1);
    }
    getWeight1(wd);



    textureSet ts[da_];
    ts[0] = base;
    ts[1] = tsd1;
    ts[2] = tsd2;
    ts[3] = tsd3;
    ts[4] = tsd4;

    DetailBlend(ts, wd.weight, m);

    float4 Ab = ts[0].ab;
    float Ro = ts[0].ro;
    float Me = ts[0].me;
    float3 No = ts[0].no;
    float3 N = applyN(No, B_W, T_W, N_W, bumpScale);

    //prepare PBR
    int useIBL = 1;
    float4 COL = { 0, 0, 0, 0 };
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
        S += Cook_Torrance(Ro, N, L, V, H, Ab.xyz, metalness);
    }

    if (useIBL == 1)
    {
        S.xyz += EnvI * specularIBL(EnvMap, EnvMapSampler, float3(1, 1, 1), Ro, N, V);
        D.xyz += EnvI * diffuseIBL(EnvMap, EnvMapSampler, float3(1, 1, 1), Ro, N, V);
    }

    COL = D * DC + S * SC;
    mrn = MRNmap.Sample(mrn_Sampler, IN.uv);
    float3 no = processNMap(float3(mrn.b, mrn.a, 1));
    N = applyN(no, B_W, T_W, N_W, bumpScale);

    
    //N = applyN(base.no, B_W, T_W, N_W, bumpScale);

    //COL = dot(N, L);
    //COL.xyz = nMap.rgb;
    COL.w = 1;
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
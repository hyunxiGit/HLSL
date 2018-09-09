#include "Common/pbrBase.hlsli"
SCRIPT_FX("Technique=Main_11;")

DECLARE_COLOR(abedo, float4(1,0.85,0.61,1), "abedo color")
DECLARE_FLOAT(roughness, 0.05, 0.99, 0.5, "roughness")
DECLARE_FLOAT(metalness, 0, 1, 1, "metalness")
DECLARE_FLOAT(F0, 0, 1, 0.2, "fresnel")
DECLARE_LIGHT(myLight, "PointLight0", "Light Position", 0)
DECLARE_FLOAT(EnvI, 0, 1, 0.2f, "cube intensity")
DECLARE_FLOAT(bumpScale, 0, 1, 0.25, "normal intensity")

//office environment
//#define BASE_A "D:/work/HLSL/texture/pbrT_a.png"
//#define BASE_N "D:/work/HLSL/texture/grass_n.jpg"
//#define BASE_R "D:/work/HLSL/texture/pbrT_r.png"
//#define BASE_M "D:/work/HLSL/texture/pbrT_m.png"
//#define CUBE_M "D:/work/HLSL/texture/default_reflection_cubic.dds"

//home environment
#define BASE_A "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_a.png"
#define BASE_N "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_n.png"
#define BASE_R "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_r.png"
#define BASE_M "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_m.png"
#define CUBE_M "C:\\MyGit\\HLSL\\texture\\pbrT\\default_reflection_cubic.dds"

DECLARE_FLOAT(useMap, 0, 1, 1, "use map")


DECLARE_CUBE(EnvMap, EnvMapSampler, CUBE_M, "cube")
TEXTURE2D(Amap, a_Sampler, BASE_A, "abedo")
TEXTURE2D(Nmap, n_Sampler, BASE_N, "normal")
TEXTURE2D(Rmap, r_Sampler, BASE_R, "roughness")
TEXTURE2D(Mmap, m_Sampler, BASE_M, "metalness")

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
    OUT.B_O = IN.T;
    OUT.T_O = IN.B;
    OUT.uv = IN.uv;
    return OUT;
}

float3 applyNormal(float3 N_O, float3 B_O, float3 T_O, float3 bump)
{
    float3 N_W = mul(N_O, world);
    float3 B_W = mul(B_O, world);
    float3 T_W = mul(T_O, world);

    float3x3 MTW;
    MTW[0] = B_O;
    MTW[1] = T_O;
    MTW[2] = N_O;


    //blend1
    float scale = 0.5f;
    float3 N = bumpScale * (bump.x * T_W - bump.y * B_W) + bump.z * N_W;
    N = normalize(N);
    return N;
}

float3 blendNormal(float3 N_O, float3 B_O, float3 T_O, float3 bump)
{
    float3 N_W = mul(N_O, world);
    float3 B_W = mul(B_O, world);
    float3 T_W = mul(T_O, world);

    float3x3 MTW;
    MTW[0] = B_O;
    MTW[1] = T_O;
    MTW[2] = N_O;


    //blend1
    float scale = 0.5f;
    float3 N = bumpScale * (bump.x * T_W - bump.y * B_W) + bump.z * N_W;
    N = normalize(N);
    
    //blend2
    //float3 N = float3(N_W.xy + mul(bump, MTW).xy, N_W.z);
    //N = normalize(N);

    //blend3
    //float3 n1 = mul(bump, MTW);
    //float3 n2 = N_W;
    //float3x3 nBasis = float3x3(
    //float3(n1.z, n1.y, -n1.x), // +90 degree rotation around y axis
    //float3(n1.x, n1.z, -n1.y), // -90 degree rotation around x axis
    //float3(n1.x, n1.y, n1.z));

    //float3 r = normalize(n2.x * nBasis[0] + n2.y * nBasis[1] + n2.z * nBasis[2]);
    //N = r * 0.5 + 0.5;

    return N;
}

float4 PS(PS_IN IN) : SV_Target
{
    float3x3 objToTangentSpace;
    objToTangentSpace[0] = IN.B_O;
    objToTangentSpace[1] = IN.T_O;
    objToTangentSpace[2] = IN.N_O;

    float4 Ab = lerp(abedo, Amap.Sample(a_Sampler, IN.uv), useMap);
    float Ro = lerp(roughness, Rmap.Sample(r_Sampler, IN.uv), useMap);
    float Me = lerp(metalness, Amap.Sample(m_Sampler, IN.uv), useMap);
  
    float3 nMap = texture_to_vector(Nmap.Sample(n_Sampler, IN.uv).xyz);
    float3 N = applyNormal(IN.N_O, IN.B_O, IN.T_O, nMap);


    int useIBL = 1;
    float4 COL = { 0, 0, 1, 1 };
    float3 L = normalize(myLight);
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
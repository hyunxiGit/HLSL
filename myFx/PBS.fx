#include "Common/pbrBase.hlsli"
SCRIPT_FX("Technique=Main_11;")

DECLARE_COLOR(abedo, float4(1,0.85,0.61,1), "abedo color")
DECLARE_FLOAT(roughness, 0.05, 0.99, 0.5, "roughness")
DECLARE_FLOAT(metalness, 0, 1, 1, "metalness")
DECLARE_LIGHT(myLight, "PointLight0", myLightColor, "Light Position", 0)
DECLARE_FLOAT(EnvI, 0, 1, 0.2f, "cube intensity")
DECLARE_FLOAT(bumpScale, 0, 1, 0.25, "normal intensity")

//office environment
#define BASE_A "D:/work/HLSL/texture/pbrT_a.png"
#define BASE_N "D:/work/HLSL/texture/pbrT_n.png"
#define BASE_R "D:/work/HLSL/texture/pbrT_r.png"
#define BASE_M "D:/work/HLSL/texture/pbrT_m.png"
#define CUBE_M "D:/work/HLSL/texture/default_reflection_cubic.dds"

#define D1_A "D:/work/HLSL/texture/defaultR.png"
#define D1_N "D:/work/HLSL/texture/default_n.png"
#define D1_R "D:/work/HLSL/texture/defaultR.png"
#define D1_M "D:/work/HLSL/texture/defaultM.png"


//home environment
//#define BASE_A "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_a.png"
//#define BASE_N "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_n.png"
//#define BASE_R "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_r.png"
//#define BASE_M "C:\\MyGit\\HLSL\\texture\\pbrT\\pbrT_m.png"
//#define CUBE_M "C:\\MyGit\\HLSL\\texture\\pbrT\\default_reflection_cubic.dds"

DECLARE_FLOAT(useMap, 0, 1, 1, "use map")


DECLARE_CUBE(EnvMap, EnvMapSampler, CUBE_M, "cube")
TEXTURE2D(Amap, a_Sampler, BASE_A, "abedo")
TEXTURE2D(Nmap, n_Sampler, BASE_N, "normal")
TEXTURE2D(Rmap, r_Sampler, BASE_R, "roughness")
TEXTURE2D(Mmap, m_Sampler, BASE_M, "metalness")

//TEXTURE2D(D1Amap, D1A_Sampler, D1_A, "d1 abedo")
//TEXTURE2D(D1Nmap, D1N_Sampler, D1_N, "d1 normal")
//TEXTURE2D(D1Rmap, D1R_Sampler, D1_R, "d1 roughness")
//TEXTURE2D(D1Mmap, D1M_Sampler, D1_M, "d1 metalness")

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

    float3 N_W = mul(IN.N_O, world);
    float3 B_W = mul(IN.B_O, world);
    float3 T_W = mul(IN.T_O, world);

    float4 Ab = Amap.Sample(a_Sampler, IN.uv);
    float Ro = Rmap.Sample(r_Sampler, IN.uv);
    float Me = Amap.Sample(m_Sampler, IN.uv);
       
    //sRGB to RGB
    Ab.xyz = pow(Ab.xyz, 2.2);

    float3 nMap = processNMap(Nmap.Sample(n_Sampler, IN.uv).xyz);
    //float3 d1nMap = processNMap(D1Nmap.Sample(D1N_Sampler, IN.uv).xyz);
       
    //float3 BN = blendNormal(nMap, d1nMap);    


    useMapBlend(Ab, Ro, Me, nMap, useMap);
    float3 N = applyN(nMap, B_W, T_W, N_W, bumpScale);


    int useIBL = 1;
    float3 color = { 0, 0, 1 };
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

    BRDFOUT Fac = BRDF(Ro, N, L, V, H, Ab.xyz, Me);
    //direct light
    float3 radiance = pointLight(myLightColor, N, myLight, IN.P_W.xyz);
    float3 Lo = (Fac.Kd * Ab.xyz / PI + Fac.specular) * radiance * NoL;

    //ambient light
    float3 ibl_radiance = sampleIBL(EnvMap, EnvMapSampler, Ro, N, V);
    float4 AO = float4(1, 1, 1, 1);
    float3 ibl_diffuse = ibl_radiance * Ab.xyz;
    float3 ambient = Fac.Kd * ibl_diffuse * AO.xyz;
//    color = Lo + ambient;



    color = ambient;

    //if (useIBL == 1)
    //{
    //    S.xyz += EnvI * specularIBL(EnvMap, EnvMapSampler, float3(1, 1, 1), Ro, N, V);
    //    D.xyz += EnvI * diffuseIBL(EnvMap, EnvMapSampler, float3(1, 1, 1), Ro, N, V);
    //}
    //COL = D * DC + S * SC;
    



    //tone map from HDR to LDR
    gammarCorrect(color);
    return float4(color,1);
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
#include "Common/Common.hlsli"

SCRIPT_FX("Technique=Main_11;")
#define BASE_N "C:\\MyGit\\HLSL\\texture\\normal1.png"
DECLARE_FLOAT(myFloat, 0, 1, 0.5, "my float")
DECLARE_LIGHT(myLight, "PointLight0", "Light Position", 0)
TEXTURE2D(Nmap, n_Sampler, BASE_N, "normal")

struct VS_IN
{
    float4 P : POSITION;
    float3 N : NORMAL;
    float3 B : BINORMAL;
    float3 T : TANGENT;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 N : TEXCOORD1;
    float3 B : TEXCOORD2;
    float3 T : TEXCOORD3;
    float3 P : TEXCOORD4;
    float3 V : TEXCOORD5;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.uv = IN.uv;
    OUT.pos = mul(IN.P, wvp);
    OUT.P = mul(IN.P, world);
    OUT.N = mul(IN.N, world);
    OUT.T = mul(IN.T, world);
    OUT.B = mul(IN.B, world);
    OUT.V = normalize(viewI[3].xyz - OUT.P);
    return OUT;
}

float4 PS(PS_IN IN) : SV_Target
{
    float4 COL = { 1, 0, 0, 1 };
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
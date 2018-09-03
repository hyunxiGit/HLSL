#include "Common/Common.hlsli"

SCRIPT_FX("Technique=Main_11;")

DECLARE_COLOR(abedo_c, float4(0.2,0.2,0.2,1) , "abedo color")
DECLARE_FLOAT(roughness, 0, 1, 0.3, "roughness")
DECLARE_FLOAT(metalic, 0, 1, 1, "metalic")

struct VS_IN
{
    float4 pos : POSITION;
    float3 nor : NORMAL;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
	float2 uv  : TEXCOORD0;
    float3 n_w : TEXCOORD1;
    float3 v_w : TEXCOORD1;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    return OUT;
}

float4 PS(PS_IN IN) : SV_Target
{
    float4 COL = { 1, 0, 1, 1 };
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
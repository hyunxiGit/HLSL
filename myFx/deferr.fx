#include "Common/Common.hlsli"

float script : STANDARDSGLOBAL <
    string UIWidget = "none";
    string ScriptClass = "object";
    string ScriptOrder = "standard";
    string ScriptOutput = "color";
    string Script = "Technique = Main;";
> = 0.8f;

#define DECLARE_SIZED_QUAD_TEX(TexName,SampName,PixFmt,Multiple) texture TexName : RENDERCOLORTARGET < \
    float2 ViewPortRatio = {Multiple,Multiple}; \
    int MipLevels = 1; \
    string Format = PixFmt ; \
    string UIWidget = (TARGETWIDGET); \
>; \
sampler2D SampName = sampler_state { \
    texture = <TexName>; \
    AddressU = Clamp; \
    AddressV = Clamp; \
    Filter=MIN_MAG_LINEAR_MIP_POINT; };


struct VS_IN
{
    float4 pos : POSITION;
    float3 nor : NORMAL;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
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

PS_IN VS1(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    return OUT;
}

float4 PS1(PS_IN IN) : SV_Target
{
    float4 COL = { 0, 1, 0, 0.3 };
    return COL;
}

fxgroup dx11
{

    technique11 Main_11 <
	    string Script =
                "Pass=p0;"
                "Pass=p1;";
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

        pass p1 <
	    string Script = "Draw=geometry;";
        >
        {
            SetVertexShader(CompileShader(vs_5_0, VS1()));
            SetGeometryShader(NULL);
            SetPixelShader(CompileShader(ps_5_0, PS1()));
        }

    }
}
#include "Common/Common.hlsli"

SCRIPT_FX("Technique=Main_11;")
float3 vector_to_texture(float3 v) { return ((v * 0.5) + float3(0.5, 0.5, 0.5));}
float3 texture_to_vector(float3 t) { return ((t - float3(0.5, 0.5, 0.5)) * 2.0);}

float QuadTexOffset <
    string UIName="Texel Alignment Offset";
    string UIWidget="None";
> = 0.5;

Texture2D<float4> texRTT : RENDERCOLORTARGET
<
    float2 ViewPortRatio = {1,1}; 
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;

SamplerState SampRTT
{
    AddressU = Wrap;
    AddressV = Wrap;
};
struct VS_IN
{
    float4 pos : POSITION;
    float3 nor : NORMAL;
    float2 uv : TEXCOORD0;
};

struct QuadVertexOutput
{
    float4 Position : POSITION;
    float2 UV : TEXCOORD0;
};

QuadVertexOutput ScreenQuadVS2(
    float3 Position : POSITION,
    float3 TexCoord : TEXCOORD0,
    uniform float2 TexelOffsets
)
{
    QuadVertexOutput OUT;
    OUT.Position = float4(Position, 1);
    OUT.UV = float2(TexCoord.xy + TexelOffsets);
    return OUT;
}

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 nor : TEXCOORD1;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.nor = normalize(mul(IN.nor, (float3x3) world));
    return OUT;
}

void PS1(PS_IN IN, out float4 NormalOutput : COLOR0)
{ 
    NormalOutput = float4(vector_to_texture(IN.nor), 1);
}

float4 PS2(QuadVertexOutput IN) : COLOR
{
    float4 COL ;
    COL = texRTT.Sample(SampRTT, IN.UV);
    //COL = float4(1, 0, 0, 1);
    COL.a = 1;
    return COL;
}

RasterizerState DisableCulling{CullMode = NONE;};
DepthStencilState DepthEnabling { DepthEnable = TRUE; };
BlendState DisableBlend { BlendEnable[0] = FALSE; };
DepthStencilState DepthDisabling
{
    DepthEnable = FALSE;
    DepthWriteMask = ZERO;
};

fxgroup dx11
{

technique11 Main_11 <
	string Script = "Pass=p0;"  
	                 "Pass=p1;";
>
{
    pass p0 <
	string Script = 
                "RenderColorTarget0 = texRTT;"
                "ClearSetColor = gClearColor;"
                "Clear=Color0;"
                "Draw = geometry;";
    >
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetGeometryShader(NULL);

        SetRasterizerState(DisableCulling);
        SetDepthStencilState(DepthEnabling, 0);
        SetBlendState(DisableBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);

        SetPixelShader(CompileShader(ps_5_0, PS1()));
    }

    pass p1 <
	string Script = 
                "RenderColorTarget0=;"
	            "ClearSetColor=gClearColor;"
	            "Clear=Color;"
                "Draw=Buffer;";
    >
    {
        SetVertexShader(CompileShader(vs_5_0, ScreenQuadVS2(float2(0,0))));
        SetGeometryShader(NULL);

        SetRasterizerState(DisableCulling);
        SetDepthStencilState(DepthDisabling, 0);
        SetBlendState(DisableBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);

        SetPixelShader(CompileShader(ps_5_0, PS2()));
    }
}
}
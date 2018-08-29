#include "Common/Common.hlsli"
#define BASE_A "D:/work/HLSL/texture/blendBase.png"

float Script : STANDARDSGLOBAL <
string UIWidget = "none";
string ScriptClass = "object";
string ScriptOrder = "standard";
string ScriptOutput = "color";
string Script = "Technique=Main_11;";
> = 0.8;

string ParamID = "0x003";

#define PATH_D "C:/MyGit/HLSL/texture/grass_a.jpg"
TEXTURE2D(abedo, abedo_Sampler, PATH_D, "Abedo", 0)

float4 gClearColor = float4(0, 0, 0, 0);
float gClearDepth <string UIWidget = "none";> = 1.0;

Texture2D<float4> ABE_TAR : RENDERCOLORTARGET
 <
    float2 ViewPortRatio = {1,1}; 
	string ResourceType = "2D";
    string Format = "A16B16G16R16" ; 
    int Texcoord = 0;
	int MapChannel = 1;
>;
SamplerState ABE_TAR_SAMP
{
    AddressU = Wrap;
    AddressV = Wrap;
};

Texture2D<float4> NOR_TAR : RENDERCOLORTARGET
 <
    float2 ViewPortRatio = {1,1}; 
	string ResourceType = "2D";
    string Format = "A16B16G16R16" ; 
    int Texcoord = 0;
	int MapChannel = 1;
>;
SamplerState NOR_TAR_SAMP
{
    AddressU = Wrap;
    AddressV = Wrap;
};

Texture2D<float4> DepthBuffer : RENDERDEPTHSTENCILTARGET < 
    float2 ViewPortRatio = {1,1}; 
    string Format = "D24S8"; 
    string UIWidget = ("None"); 
>;

struct VS_IN
{
    float4 pos : POSITION;
    float4 nor : NORMAL;
    float2 uv : TEXCOORD0;
};

struct GBUFF
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 nor_w : TEXCOORD1;
};

 GBUFF UNLID_VS(VS_IN IN)
{
    GBUFF OUT;
    OUT.pos = mul(IN.pos, wvp);
    OUT.uv = IN.uv;
    OUT.nor_w = mul(IN.nor, worldI);
    return OUT;
}


void prepreMRT(GBUFF IN, out float4 a : SV_Target0, out float4 n : SV_Target1)
{
    a = abedo.Sample(abedo_Sampler, IN.uv);
    n = float4(vector_to_texture(IN.nor_w.xyz), 1);
}

struct QuadVertexOutput
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
};


QuadVertexOutput ScreenQuadVS2(
    float3 pos : POSITION,
    float3 uv : TEXCOORD0
)
{
    QuadVertexOutput OUT;
    OUT.pos = float4(pos, 1);
    OUT.uv = float2(uv.xy);
    return OUT;
}

float4 useMRTPS(QuadVertexOutput IN): SV_Target
{
    float4 col;
    col = NOR_TAR.Sample(NOR_TAR_SAMP, IN.uv);
    return col;
}

RasterizerState DisableCulling { CullMode = NONE; };
DepthStencilState DepthEnabling { DepthEnable = TRUE; };
DepthStencilState DepthDisabling {
	DepthEnable = FALSE;
	DepthWriteMask = ZERO;
};
BlendState DisableBlend { BlendEnable[0] = FALSE; };

fxgroup dx11
{

technique11 Main_11 <
	string Script = "Pass=p0;";
>
{
    pass p0 <
	string Script = 
                "RenderColorTarget0 = ABE_TAR;"
                "RenderColorTarget1 = NOR_TAR;"
                "RenderDepthStencilTarget=DepthBuffer;"
	            "ClearSetColor=gClearColor;"
	            "ClearSetDepth=gClearDepth;"
                "Clear=SV_TARGET0;"
	            "Clear=SV_TARGET1;"
                "Clear=Depth;"
                "Draw=Geometry;";
    >
    {
        SetRasterizerState(DisableCulling);
        SetDepthStencilState(DepthEnabling, 0);
        SetBlendState(DisableBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
        SetVertexShader(CompileShader(vs_5_0, UNLID_VS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, prepreMRT()));
    }

    pass p1 <
	string Script = 
                "RenderColorTarget0=;"
                "RenderColorTarget1=;"
                "RenderDepthStencilTarget=;"
	            "ClearSetColor=gClearColor;"
	            "ClearSetDepth=gClearDepth;"
	            "Clear=Color;"
	            "Clear=Depth;"
	            "Draw=Buffer;";        
    >
    {
        SetVertexShader(CompileShader(vs_5_0, ScreenQuadVS2()));
        SetRasterizerState(DisableCulling);
        SetDepthStencilState(DepthDisabling, 0);
        SetBlendState(DisableBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, useMRTPS()));
    }

}
}
#include "Common/Common.hlsli"
#define BASE_A "D:/work/HLSL/texture/blendBase.png"

SCRIPT_FX("Technique=Main_11;")

TEXTURE2D(blendBase, blendBaseSampler, "D:/work/HLSL/texture/blendBase.png", "Base Map", 0)

float QuadTexOffset <
    string UIName="Texel Alignment Offset";
    string UIWidget="None";
> = 0.5;
float4 gClearColor <
    string UIWidget = "Color";
    string UIName = "Background";
> = { 0, 0, 0, 0 };

struct QuadVertexOutput
{
    float4 Position : SV_POSITION;
    float2 UV : TEXCOORD0;
};
//these are the way to create screen quad from Vertex ID... all red by now
//struct VertexOut
//{
//    float4 PosH     : SV_POSITION;
//    float2 Tex      : TEXCOORD;
//};

//VertexOut VS0(uint id : SV_VertexId)
//{
//    VertexOut vout;
//    vout.Tex = float2(id % 2, (id % 4) >> 1);
//    vout.PosH = float4((vout.Tex.x - 0.5f) * 2, -(vout.Tex.y - 0.5f) * 2, 0, 1);
//    return vout;
//}

QuadVertexOutput ScreenQuadVS2(
    float3 Position : SV_POSITION,
    float3 TexCoord : TEXCOORD0,
    uniform float2 TexelOffsets
)
{
    QuadVertexOutput OUT;
    OUT.Position = float4(Position, 1);
    OUT.UV = float2(TexCoord.xy + TexelOffsets);
    return OUT;
}


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
    float3 nor : TEXCOORD1;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.nor = normalize(mul(IN.nor, (float3x3) world));
    OUT.uv = IN.uv;
    return OUT;
}

RENDERTARGET(norRTT, norRTTSamp, 1, 1, "A16B16G16R16")
RENDERTARGET(abeRTT, abeSampRTT, 1, 1, "A16B16G16R16")

struct G_BUFF
{
    float4 abe_g : SV_Target0;
    float4 nor_g : SV_Target1;
};

G_BUFF prepreMRT(PS_IN IN)
{
    G_BUFF OUT;
    OUT.abe_g = blendBase.Sample(blendBaseSampler, IN.uv);
    OUT.nor_g = float4(vector_to_texture(IN.nor), 1);
    return OUT;
}

float4 useMRT(QuadVertexOutput IN) : SV_Target
{
    float4 COL ;
    float4 nor = norRTT.Sample(norRTTSamp, IN.UV);
    //COL = abeRTT.Sample(abeSampRTT, IN.UV);
    COL = nor;
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
                "RenderColorTarget0 = abeRTT;"
                "RenderColorTarget1 = norRTT;";
             
    >
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetGeometryShader(NULL);
        
        //these are not must have but used in deffer render ,need to check meaning
        SetRasterizerState(DisableCulling);
        SetDepthStencilState(DepthEnabling, 0);
        SetBlendState(DisableBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);

        SetPixelShader(CompileShader(ps_5_0, prepreMRT()));
    }

    pass p1 <
	string Script = 
                "RenderColorTarget0=;"
                "RenderColorTarget1=;"
	            "ClearSetColor=gClearColor;"
	            "Clear=Color;"
                "Draw=Buffer;";
    >
    {
        //SetVertexShader(CompileShader(vs_5_0, VS0()));
        SetVertexShader(CompileShader(vs_5_0, ScreenQuadVS2(float2(0,0))));
        SetGeometryShader(NULL);
        
        //these are not must have but used in deffer render ,need to check meaning
        SetRasterizerState(DisableCulling);
        SetDepthStencilState(DepthDisabling, 0);
        SetBlendState(DisableBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);

        SetPixelShader(CompileShader(ps_5_0, useMRT()));
    }
}
}
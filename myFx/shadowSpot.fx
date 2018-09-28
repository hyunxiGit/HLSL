//#include "Common/Common.hlsli"
//#include "Common/shadowMap.hlsli"
#define BASE_N "D:/work/HLSL/texture/pbrT_n.png"

float4x4 wvp : WorldViewProjection;
float4x4 viewI : ViewInverse;
float4x4 gWorldXf : WORLD;
float4x4 gWorldITXf : WorldInverseTranspose;

#define SHADOW_SIZE 1024
#define SHADOW_COLOR_FORMAT "X8B8G8R8"
#define SHADOW_FORMAT "D24X8_SHADOWMAP"

float4 gShadowMapClearColor <
	string UIWidget = "none";
#ifdef BLACK_SHADOW_PASS
> = {1,1,1,0.0};
#else /* !BLACK_SHADOW_PASS */
> = { 0.0, 0.0, 0.0, 0.0 };
#endif /* !BLACK_SHADOW_PASS */

float Script : STANDARDSGLOBAL <
string UIWidget = "none";
string ScriptClass = "object";
string ScriptOrder = "standard";
string ScriptOutput = "color";
string Script = "Technique=Main_11;";
> = 0.8;

string ParamID = "0x003";


float4 myColor = float4(1, 1, 1, 1);

float3 myLight : POSITION <
string Object = "PointLight0";
string UIName = "Light Position";
string Space = "World";
int refID = 0;
> = { -0.5f, 2.0f, 1.25f };

float3 myLightColor : LIGHTCOLOR
 <
int LightRef = 0;
string UIWidget = "None";
> = float3(1.0f, 1.0f, 1.0f);

struct VS_IN
{
    float4 pos : POSITION;
    float3 N : NORMAL;
    float3 T : TANGENT;
    float3 B : BINORMAL;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float3 pos_w : TEXCOORD0;
    float3 N : TEXCOORD1;
    float3 B : TEXCOORD3;
    float3 T : TEXCOORD4;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.pos_w = mul(IN.pos, gWorldXf);
    OUT.N = IN.N;
    OUT.B = IN.B;
    OUT.T = IN.T;
    return OUT;
}

#define DECLARE_SHADOW_MAPS(CTex,CSamp,DTex,DSamp) \
texture2D CTex : RENDERCOLORTARGET < \
    float2 Dimensions = {SHADOW_SIZE,SHADOW_SIZE}; \
    string Format = (SHADOW_COLOR_FORMAT) ; \
    string UIWidget = "None"; >; \
sampler2D CSamp = sampler_state { \
    texture = <CTex>; \
    AddressU = Clamp; \
    AddressV = Clamp; \
    Filter = MIN_MAG_LINEAR_MIP_POINT; }; \
texture2D DTex : RENDERDEPTHSTENCILTARGET < \
    float2 Dimensions = {SHADOW_SIZE,SHADOW_SIZE}; \
    string Format = (SHADOW_FORMAT); \
    string UIWidget = "None"; >; \
SamplerComparisonState DSamp { \
    AddressU = Clamp; \
    AddressV = Clamp; \
    ComparisonFunc = Less_Equal; \
    Filter = COMPARISON_MIN_MAG_LINEAR_MIP_POINT;};
DECLARE_SHADOW_MAPS(ColorShadMap, ColorShadSampler, ShadDepthTarget, ShadDepthSampler)



float4 PS(PS_IN IN) : SV_Target
{
    float4 COL = { 1, 1, 1, 1 };
    float3 L = myLight - IN.pos_w;

    float3x3 objToTangentSpace;
    objToTangentSpace[0] = IN.B;
    objToTangentSpace[1] = IN.T;
    objToTangentSpace[2] = IN.N;

    float3 N = normalize(mul(IN.N, gWorldXf));
    COL.xyz = dot(N, normalize(L));

    //COL.xyz = N;
    return COL;
}


#define DECLARE_SHADOW_XFORMS(LampName,LampView,LampProj,LampViewProj) \
    float4x4 LampView : View < string Object = (LampName); >; \
    float4x4 LampProj : Projection < string Object = (LampName); >; \
    float4x4 LampViewProj : ViewProjection < string Object = (LampName); >;
DECLARE_SHADOW_XFORMS("SpotLight0", LampViewXf, LampProjXf, gShadowViewProjXf)
struct ShadowAppData
{
    float3 Position : POSITION;
    float4 UV : TEXCOORD0; // provided for potential use
    float4 Normal : NORMAL; // ignored if BLACK_SHADOW_PASS
    float3 Tangent : TANGENT; //in object space
    float3 Binormal : BINORMAL; //in object space    
};

struct ShadowVertexOutput
{
    float4 HPosition : POSITION;
    float4 diff : COLOR0;
};

ShadowVertexOutput shadowGenVS(ShadowAppData IN,
		uniform float4x4 WorldXform,
		uniform float4x4 WorldITXform,
		uniform float4x4 ShadowVPXform)
{
    ShadowVertexOutput OUT = (ShadowVertexOutput) 0;
    float4 Po = float4(IN.Position.xyz, (float) 1.0);
    float4 Pw = mul(Po, WorldXform);
    float4 Pl = mul(Pw, ShadowVPXform); // "P" in light coords
    OUT.HPosition = Pl; // screen clipspace coords for shadow pass
#ifndef BLACK_SHADOW_PASS
#ifdef SHADOW_COLORS
    float4 N = mul(IN.Normal,WorldITXform); // world coords
    N = normalize(N);
    OUT.diff = 0.5 + 0.5 * N;
#else /* ! SHADOW_COLORS -- deliver depth info instead */
    OUT.diff = float4(Pl.zzz, 1);
#endif /* ! SHADOW_COLORS */
#else /* BLACK_SHADOW_PASS */
    OUT.diff = float4(0,0,0,1);
#endif /* BLACK_SHADOW_PASS */
    return OUT;
}

float4 shadowGenPS(ShadowVertexOutput IN) : COLOR
{
    float d = IN.diff.r;
    float d2 = d * d;
    return float4(d, d2, 0, 1);
}

//
// Standard DirectX10 Material State Blocks
//
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
	string Script = "Draw=geometry;";
    >
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, PS()));
    }
}

technique11 Shadow <
	string Script = "Pass=MakeShadow;"
		            /*"Pass=UseShadow;"*/;
>
{
    pass MakeShadow <
	string Script = 
            "RenderColorTarget0=ColorShadMap;"
			"RenderDepthStencilTarget=ShadDepthTarget;"
			"RenderPort=SpotLight0;"
			"ClearSetColor=gShadowMapClearColor;"
			"ClearSetDepth=gClearDepth;"
			"Clear=Color;"
			"Clear=Depth;"
            "Draw=geometry;";
    >
    {
        SetVertexShader(CompileShader(vs_4_0, shadowGenVS(gWorldXf,
					gWorldITXf, gShadowViewProjXf)));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_4_0, shadowGenPS()));
        SetRasterizerState(DisableCulling);
        SetDepthStencilState(DepthEnabling, 0);
        SetBlendState(DisableBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
    }
}

}
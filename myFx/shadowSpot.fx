//#include "Common/Common.hlsli"
#include "Common/shadowMap.hlsli"
#define BASE_N "D:/work/HLSL/texture/pbrT_n.png"

float4x4 wvp : WorldViewProjection;
float4x4 viewI : ViewInverse;
float4x4 world : WORLD;
float4x4 worldI : WorldInverseTranspose;


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
    OUT.pos_w = mul(IN.pos, world);
    OUT.N = IN.N;
    OUT.B = IN.B;
    OUT.T = IN.T;
    return OUT;
}

float4 PS(PS_IN IN) : SV_Target
{
    float4 COL = { 1, 1, 1, 1 };
    float3 L = myLight - IN.pos_w;

    float3x3 objToTangentSpace;
    objToTangentSpace[0] = IN.B;
    objToTangentSpace[1] = IN.T;
    objToTangentSpace[2] = IN.N;

    float3 N = normalize(mul(IN.N, world));
    COL.xyz = dot(N, normalize(L));

    //COL.xyz = N;
    return COL;
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
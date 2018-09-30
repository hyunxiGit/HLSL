//#include "Common/Common.hlsli"
//#include "Common/shadowMap.hlsli"
#define BASE_N "D:/work/HLSL/texture/pbrT_n.png"

float4x4 gWvpXf : WORLDVIEWPROJ;
float4x4 gViewIXf : VIEWI;
float4x4 gWorldXf : WORLD;
float4x4 gWorldITXf : WORLDI;

#define SHADOW_SIZE 1024
#define SHADOW_COLOR_FORMAT "X8B8G8R8"
#define SHADOW_FORMAT "D24X8_SHADOWMAP"
#define DEFAULT_BIAS 1.0
#define MAX_SHADOW_BIAS 1500.0
#define MIN_SHADOW_BIAS (-MAX_SHADOW_BIAS)
#define BIAS_INCREMENT 1.0

float4 gClearColor <
    string UIWidget = "Color";
    string UIName = "Background";
> = { 0, 0, 0, 0 };

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

float3 gSpotLamp0Pos : POSITION <
string Object = "PointLight0";
string UIName = "Light Position";
string Space = "World";
int refID = 0;
> = { -0.5f, 2.0f, 1.25f };

float3 gLamp0Color : LIGHTCOLOR
 <
int LightRef = 0;
string UIWidget = "None";
> = float3(1.0f, 1.0f, 1.0f);

float3 gSurfaceColor : DIFFUSE <
    string UIName =  "Surface";
    string UIWidget = "Color";
> = { 1, 1, 1 };

float gKd <
    string UIWidget = "slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
    float UIStep = 0.01;
    string UIName =  "Diffuse";
> = 0.9;

float gKs <
    string UIWidget = "slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
    float UIStep = 0.05;
    string UIName =  "Specular";
> = 0.4;

float gSpecExpon <
    string UIWidget = "slider";
    float UIMin = 1.0;
    float UIMax = 128.0;
    float UIStep = 1.0;
    string UIName =  "Specular Exponent";
> = 30.0;

float gLamp0Intensity <
    string UIWidget = "slider";
    float UIMin = 1.0;
    float UIMax = 10000.0f;
    float UIStep = 0.1;
    string UIName =  "Lamp 0 Quadratic Intensity";
> = 20.0f;

// Ambient Light
float3 gAmbiColor : AMBIENT <
    string UIName =  "Ambient Light";
    string UIWidget = "Color";
> = { 0.07f, 0.07f, 0.07f };

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
    OUT.pos = mul(IN.pos, gWvpXf);
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


texture gSpotTex <
    string TextureType = "2D";
    string UIName = "Spotlight Shape Texture";
    string ResourceName = "Sunlight.tga";
>;
// samplers
sampler2D gSpotSamp = sampler_state
{
#ifdef PROCEDUAL_TEXTURE
	Texture = <gProcSpotTex>;
#else /* ! PROCEDURAL_TEXTURE */
    Texture = <gSpotTex>;
#endif /* ! PROCEDURAL_TEXTURE */
    AddressU = Clamp;
    AddressV = Clamp;
    Filter = MIN_MAG_MIP_LINEAR;

};


float4 PS(PS_IN IN) : SV_Target
{
    float4 COL = { 1, 1, 1, 1 };
    float3 L = gSpotLamp0Pos - IN.pos_w;

    float3x3 objToTangentSpace;
    objToTangentSpace[0] = IN.B;
    objToTangentSpace[1] = IN.T;
    objToTangentSpace[2] = IN.N;

    float3 N = normalize(mul(IN.N, gWorldXf));
    COL.xyz = dot(N, normalize(L));

    //COL.xyz = N;
    return COL;
}

float4x4 make_bias_mat(float BiasVal)
{
    // float fZScale = pow(2.0,((float)SHAD_BIT_DEPTH))-1.0; // DirectX8
    float fZScale = 1.0; // DirectX9
    float fTexWidth = SHADOW_SIZE;
    float fTexHeight = SHADOW_SIZE;
    float offX = 0.5f + (0.5f / fTexWidth);
    float offY = 0.5f + (0.5f / fTexHeight);
    float4x4 result = float4x4(
	    0.5f, 0.0f, 0.0f, 0.0f,
	    0.0f, -0.5f, 0.0f, 0.0f,
	    0.0f, 0.0f, fZScale, 0.0f,
	    offX, offY, -BiasVal, 1.0f);
    return result;
}

#define DECLARE_SHADOW_BIAS float gShadBias < string UIWidget = "slider"; \
    float UIMin = MIN_SHADOW_BIAS; \
    float UIMax = MAX_SHADOW_BIAS; \
    float UIStep = BIAS_INCREMENT; \
    string UIName = "Shadow Bias"; \
> = DEFAULT_BIAS; \
static float4x4 gShadBiasXf = make_bias_mat(gShadBias);   // "static" ignored by DX10

#define DECLARE_SHADOW_XFORMS(LampName,LampView,LampProj,LampViewProj) \
    float4x4 LampView : View < string Object = (LampName); >; \
    float4x4 LampProj : Projection < string Object = (LampName); >; \
    float4x4 LampViewProj : ViewProjection < string Object = (LampName); >;
DECLARE_SHADOW_BIAS
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
    //return float4(d, d2, 0, 1);
    return float4(0, 0, 0, 0);

}
//
// Connector from vertex to pixel shader for typical usage. The
//		"LProj" member is the crucial one for shadow mapping.
//
struct ShadowingVertexOutput
{
    float4 HPosition : POSITION;
    float2 UV : TEXCOORD0;
    float3 LightVec : TEXCOORD1;
    float3 WNormal : TEXCOORD2;
    float3 WView : TEXCOORD3;
    float4 LProj : LPROJ_COORD; // current position in light-projection space
    float4 LightVector	: TEXCOORD5;
};

 
float4 mCamPos : WORLD_CAMERA_POSITION <string UIWidget="None";>;


//
// DX10 version that does not use static variables, but instead calculates
///    the shadow bias matrix on the fly.
//
ShadowingVertexOutput shadowUseVS10(ShadowAppData IN,
		uniform float4x4 WorldXform,
		uniform float4x4 WorldITXform,
		uniform float4x4 WVPXform,
		uniform float4x4 ShadowVPXform,
		uniform float4x4 ViewIXf,
		uniform float Bias,
		uniform float3 LightPosition)
{
    ShadowingVertexOutput OUT = (ShadowingVertexOutput) 0;
    OUT.WNormal = mul(IN.Normal, WorldITXform).xyz; // world coords
    float4 Po = float4(IN.Position.xyz, (float) 1.0); // "P" in object coords
    float4 Pw = mul(Po, WorldXform); // "P" in world coordinates
    float4 Pl = mul(Pw, ShadowVPXform); // "P" in light coords
    //OUT.LProj = Pl;			// ...for pixel-shader shadow calcs
    float4x4 BiasXform = make_bias_mat(Bias);
    OUT.LProj = mul(Pl, BiasXform); // bias to make texcoord
    //  
    float3 EyePos = mCamPos.xyz;

    OUT.WView = normalize(EyePos - Pw.xyz); // world coords

    float3x3 objToTangentSpace;
    objToTangentSpace[0] = IN.Binormal;
    objToTangentSpace[1] = IN.Tangent;
    objToTangentSpace[2] = IN.Normal;
    // transform normal from object space to tangent space and pass it as a color
    //OUT.Normal.xyz = 0.5 * mul(IN.Normal,objToTangentSpace) + 0.5.xxx;
    float3 dir = LightPosition - Pw.xyz;
    float4 objectLightDir = mul(dir, WorldITXform);
    float4 vertnormLightVec = normalize(objectLightDir);
    // transform light vector from object space to tangent space and pass it as a color 
    OUT.LightVector.xyz = 0.5 * mul(objToTangentSpace,vertnormLightVec.xyz ) + 0.5.xxx;

    OUT.HPosition = mul(Po, WVPXform); // screen clipspace coords
#ifdef FLIP_TEXTURE_Y
    OUT.UV = float2(IN.UV.x,(1.0-IN.UV.y));
#else /* !FLIP_TEXTURE_Y */
    OUT.UV = IN.UV.xy;
#endif /* !FLIP_TEXTURE_Y */
    OUT.LightVec = LightPosition - Pw.xyz; // world coords
    return OUT;
}

//
// core of the surface shading, shared by both shadowed and unshadowed versions
//
void lightingCalc(ShadowingVertexOutput IN,
		    float3 SurfaceColor,
		    float Kd,
		    float Ks,
		    float SpecExpon,
		    uniform float3 LampColor,
		    uniform float LampIntensity,
		    uniform float3 AmbiColor,
		    out float3 litContrib,
		    out float3 ambiContrib,
			uniform sampler2D SpotSamp)
{
    float3 Nn = normalize(IN.WNormal);
    float3 Vn = normalize(IN.WView);
    Nn = faceforward(Nn, -Vn, Nn);
    float falloff = 1.0 / dot(IN.LightVec, IN.LightVec);
    float3 Ln = normalize(IN.LightVec);
    float3 Hn = normalize(Vn + Ln);
    float hdn = dot(Hn, Nn);
    float ldn = dot(Ln, Nn);
    float4 litVec = lit(ldn, hdn, SpecExpon);
    ldn = litVec.y * LampIntensity;
    ambiContrib = SurfaceColor * AmbiColor;
    float3 diffContrib = SurfaceColor * (Kd * ldn * LampColor);
    float3 specContrib = ((ldn * litVec.z * Ks) * LampColor);
    float3 result = diffContrib + specContrib;
    float cone = tex2Dproj(SpotSamp, IN.LProj).x;
    litContrib = ((cone * falloff) * result);
}

float4 useShadowPS(ShadowingVertexOutput IN,
		    uniform float3 SurfaceColor,
		    uniform float Kd,
		    uniform float Ks,
		    uniform float SpecExpon,
		    uniform float3 LampColor,
		    uniform float LampIntensity,
		    uniform float3 AmbiColor,
			uniform sampler2D SpotSamp
) : COLOR
{
    float3 litPart, ambiPart;
    lightingCalc(IN, SurfaceColor, Kd, Ks, SpecExpon,LampColor, LampIntensity,AmbiColor,litPart, ambiPart,SpotSamp);
    float2 Luv = IN.LProj.xy / IN.LProj.w;
    float Lz = IN.LProj.z / IN.LProj.w;
    float shadowed = ShadDepthTarget.SampleCmp(ShadDepthSampler, Luv, Lz);
    if (shadowed > 0.2f)
    {
        shadowed = float4(0, 0, 1, 1);

    }
    else
    {
        shadowed = float4(1, 1, 0, 1);

    }
        
    shadowed = float4(1, 0, 0, 1);
    return shadowed; //debug
    // return float4((shadowed.x * litPart) + ambiPart, 1);
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

technique11 Shadow <
	string Script = "Pass=MakeShadow;"
		            "Pass=UseShadow;";
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
        //SetPixelShader(CompileShader(ps_4_0, shadowGenPS()));
        SetPixelShader(NULL);
        SetRasterizerState(DisableCulling);
        SetDepthStencilState(DepthEnabling, 0);
        SetBlendState(DisableBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
    }

    pass UseShadow <
	    string Script = "RenderColorTarget0=;"
			    "RenderDepthStencilTarget=;"
			    "RenderPort=;"
			    "ClearSetColor=gClearColor;"
			    "ClearSetDepth=gClearDepth;"
			    "Clear=Color;"
			    "Clear=Depth;"
			    "Draw=geometry;";
    >
    {
        SetVertexShader(CompileShader(vs_4_0, shadowUseVS10(gWorldXf,
					gWorldITXf, gWvpXf, gShadowViewProjXf,
					gViewIXf, gShadBias, gSpotLamp0Pos)));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_4_0, useShadowPS(gSurfaceColor,
						gKd, gKs, gSpecExpon,
						gLamp0Color, gLamp0Intensity,
						gAmbiColor,
						gSpotSamp)));
        SetRasterizerState(DisableCulling);
        SetDepthStencilState(DepthEnabling, 0);
        SetBlendState(DisableBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
    }


}

//technique11 Main_11 <
//	string Script = "Pass=p0;";
//>
//{
//    pass p0 <
//	string Script = "Draw=geometry;";
//    >
//    {
//        SetVertexShader(CompileShader(vs_5_0, VS()));
//        SetGeometryShader(NULL);
//        SetPixelShader(CompileShader(ps_5_0, PS()));
//    }
//}



}
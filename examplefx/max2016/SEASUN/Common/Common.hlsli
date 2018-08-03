#define COMMON

string ParamID = "0x003";

#define PI 3.141592654f
#define FLT_MAX 3.402823466e+38F
#define FLT_MIN 0.0f

#define PerceivedLuminance float3(0.3, 0.59, 0.11)

#define DECLARE_SAMPLER_2D(displayName, samplerName, textureName, default) \
texture textureName : DiffuseMap< \
	string UIName = displayName; \
	string ResourceName=default; \
	string ResourceType = "2D"; \
>; \
 \
sampler2D samplerName = sampler_state \
{ \
	Texture = <textureName>; \
	Filter = MIN_MAG_MIP_LINEAR; \
	AddressU = Wrap; \
	AddressV = Wrap; \
};

#define DECLARE_MATERIAL_VARIABLE(displayName, variableName, type, defaultValue) \
type variableName < string UIName = displayName; > = defaultValue;

#define DECLARE_MATERIAL_VARIABLE_EX(displayName, variableName, type, defaultValue, minimum, maximum) \
type variableName < string UIName = displayName; float UIMin = minimum; float UIMax = maximum; > = defaultValue;

#define DEF_MAT_X float4(1.0f,0.0f,0.0f,0.0f)
#define DEF_MAT_Y float4(0.0f,1.0f,0.0f,0.0f)
#define DEF_MAT_Z float4(0.0f,0.0f,1.0f,0.0f)
#define DEF_MAT_W float4(0.0f,0.0f,0.0f,1.0f)

float4x4 DefaultTexCoordMat : DefaultTexCoordMat = 
{
	{1,0,0,0},
	{0,1,0,0},
	{0,0,1,0},
	{0,0,0,1},
};

float4x4 mWorldInverseTranspose : WorldInverseTranspose < string UIWidget="None"; >;
float4x4 mWorldViewProj : WorldViewProjection < string UIWidget="None"; >;
float4x4 mView : View < string UIWidget="None"; >;
float4x4 mProjection : Projection < string UIWidget="None"; >;
float4x4 mWorld : World < string UIWidget="None"; >;
float4x4 mViewInverse : ViewInverse < string UIWidget="None"; >;
float Time : Time < string UIWidget="None"; >;

int texcoord0 : Texcoord
<
	int Texcoord = 0;
	int MapChannel = 1;
	string UIWidget = "None";
>;

int texcoord1 : Texcoord
<
	int Texcoord = 1;
	int MapChannel = 0;
	string UIWidget = "None";
>;

int texcoord2 : Texcoord
<
	int Texcoord = 2;
	int MapChannel = -2;
	string UIWidget = "None";
>;

int texcoord3 : Texcoord
<
	int Texcoord = 3;
	int MapChannel = -1;
	string UIWidget = "None";
>;

int texcoord4 : Texcoord
<
	int Texcoord = 4;
	int MapChannel = 2;
	string UIWidget = "None";
>;

int texcoord7 : Texcoord
<
	int Texcoord = 7;
	int MapChannel = 8;
	string UIWidget = "None";
>;

struct VS_IN {
	float4 Position		: POSITION;
	float4 Normal		: NORMAL;
	float4 Tangent		: TANGENT;
	float4 Binormal		: BINORMAL;
	float2 Texcoord		: TEXCOORD0;
	float3 Color		: TEXCOORD1;
	float3 Alpha		: TEXCOORD2;
	float3 Illum		: TEXCOORD3;
	float2 Texcoord2	: TEXCOORD4;
	float3 SurfaceDirection : TEXCOORD7;
};

float4 vLightDirection : Direction <  
	string UIName = "Light Direction"; 
	string Object = "TargetLight";
	int RefID = 0;
	> = {-0.577, -0.577, 0.577,1.0};

float3 vLightColor : LIGHTCOLOR
<
	int LightRef = 0;
	string UIWidget = "None";
> = float3(1.0f, 1.0f, 1.0f);

float RGBCVtoHUE(in float3 RGB, in float C, in float V)
{
	float3 Delta = (V - RGB) / C;
	Delta.rgb -= Delta.brg;
	Delta.rgb += float3(2,4,6);
	Delta.brg = step(V, RGB) * Delta.brg;
	float H;
	H = max(Delta.r, max(Delta.g, Delta.b));
	return frac(H / 6);
}

float3 RGBtoHSL(in float3 RGB)
{
	float3 HSL = 0;
	float U, V;
	U = -min(RGB.r, min(RGB.g, RGB.b));
	V = max(RGB.r, max(RGB.g, RGB.b));
	HSL.z = (V - U) * 0.5;
	float C = V + U;
	if (C != 0)
	{
		HSL.x = RGBCVtoHUE(RGB, C, V);
		HSL.y = C / (1 - abs(2 * HSL.z - 1));
	}
	return HSL;
}

float3 HUEtoRGB(in float H)
{
	float R = abs(H * 6 - 3) - 1;
	float G = 2 - abs(H * 6 - 2);
	float B = 2 - abs(H * 6 - 4);
	return saturate(float3(R,G,B));
}

float3 HSLtoRGB(in float3 HSL)
{
	float3 RGB = HUEtoRGB(HSL.x);
	float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
	return (RGB - 0.5) * C + HSL.z;
}

float InvertValue(float value, bool invert)
{
	return lerp(value, 1.0f - value, invert); 
}
float2 InvertValue(float2 value, bool invert)
{
	return lerp(value, 1.0f - value, invert); 
}
float3 InvertValue(float3 value, bool invert)
{
	return lerp(value, 1.0f - value, invert); 
}
float4 InvertValue(float4 value, bool invert)
{
	return lerp(value, 1.0f - value, invert); 
}

// Tex Coords Matrix
float2 CalcTextureCoord(float2 coord, float2 tile, float2 offset)
{
	return (coord * tile + offset);
}

// Cacluate texture coordinates
#define SCROLL_SPEED 1.0f/4800.0f
float2 CalcTexCoord(float2 coord, float2 map_mat_x, float2 map_mat_y, float2 map_mat_z, float2 map_mat_w)
{
	//return (map_mat_x * coord.x + map_mat_y * coord.y + map_mat_z + map_mat_w *((Time * 6.25f) / 30.0f) + map_mat_y);
	return (map_mat_x * coord.x + map_mat_y * coord.y + map_mat_z + map_mat_w * (Time / 4800.0f) + map_mat_y);
}

bool ShouldAnimateVertex()
{
	return (Time.x / 4800.0f) > (1.5f / 30.0f);
}

void VertexWibble(in float3 fFrequency, 
				  in float3 fPhase, 
				  in float3 fAmplitude,
				  in bool bFlipVertexPhase,
				  in float3 vVertexColor,
				  in float fVertexAlpha,
				  inout float3 vWorldPosition,
				  out float4 vDebugColor)
{
	fFrequency = fFrequency * 2.0f * PI;
	fPhase = fPhase * 2.0f * PI;
	fPhase += fVertexAlpha * (bFlipVertexPhase ? -2.0f * PI : 2.0f * PI);
	float seconds = Time.x / 4800.0f;

	if (seconds > (1.5f / 30.0f))
	{
		// Max uses a unit of time called a 'tick'. There are 4800 ticks per second.
		// Max USED to supply Time in thousands of ticks. Now it supplies Ticks directly.
		// Thus, to get seconds we need to divide by 4800.
		vWorldPosition += sin(seconds * fFrequency + fPhase) * vVertexColor * fAmplitude;
		vDebugColor = float4(1,1,1,1);
	}
	else if (seconds > 0.5f / 30.0f)
	{
		// Shade with vertex alpha at t=1 (frame) to help with authoring
		vDebugColor = fVertexAlpha.xxxx;
	}
	else
	{
		// Shade with vertex colors at t=0 to help with authoring
		vDebugColor = float4(vVertexColor.rgb, fVertexAlpha);
	}
}

void ApplyBumpMapping(float2 vBump, float3 vTangent, float3 vBinormal, inout float3 vNormal)
{
	if (length(vTangent) > 0.01f)
	{
		float3 vReconstructedBump = float3(vBump.xy, sqrt(saturate(1.0f - dot(vBump.xy, vBump.xy))));
		vNormal = vNormal * vReconstructedBump.z + vReconstructedBump.x * vTangent - vReconstructedBump.y * vBinormal;
	}
	vNormal = normalize(vNormal);
}

void ApplyBumpMapping(float2 vBump1, float2 vBump2, float fBlend, float3 vTangent, float3 vBinormal, inout float3 vNormal)
{
	if (length(vTangent) > 0.01f)
	{
		float3 vReconstructedBump1 = float3(vBump1.xy, sqrt(saturate(1.0f - dot(vBump1.xy, vBump1.xy))));
		float3 vReconstructedBump2 = float3(vBump2.xy, sqrt(saturate(1.0f - dot(vBump2.xy, vBump2.xy))));

		float3 vNormal1 = normalize(vNormal * vReconstructedBump1.z + vReconstructedBump1.x * vTangent - vReconstructedBump1.y * vBinormal);
		float3 vNormal2 = normalize(vNormal * vReconstructedBump2.z + vReconstructedBump2.x * vTangent - vReconstructedBump2.y * vBinormal);
		vNormal = lerp(vNormal1, vNormal2, fBlend);
	}
	vNormal = normalize(vNormal);
}

 void ApplyDirectionalBlend(
			float2 vBlendAngles,
			float2 vBlendRange,
			bool bInvertDirectionalBlend,
			float3 vNormal,
			inout float4 vColor
 )
 {
		vBlendAngles = radians(vBlendAngles);
		float3 vBlendDirection = normalize(float3(
			sin(vBlendAngles.x) * sin(vBlendAngles.y),
			-sin(vBlendAngles.x) * cos(vBlendAngles.y),
			cos(vBlendAngles.x)));

		vBlendRange = cos(radians(vBlendRange));
		float2 vBlendParams;
		vBlendParams.x = 1.0f / (vBlendRange.x - vBlendRange.y + 0.00001f);
		vBlendParams.y = -vBlendRange.y * vBlendParams.x;

		if (bInvertDirectionalBlend)
		{
			vBlendParams.x = -vBlendParams.x;
			vBlendParams.y = 1.0f - vBlendParams.y;
		}

		vColor.a *= saturate(dot(vNormal, vBlendDirection) * vBlendParams.x + vBlendParams.y);
 }

 void ApplyThresholdBlend(float fThresholdBlend, 
									  float fThresholdBias, 
									  float fVertexAlpha,
									  float fTopAlpha,
									  bool bUseTopAlpha,
									  bool bInvertTopAlpha,
									  float fBottomAlpha,
									  bool bUseBottomAlpha,
									  bool bInvertBottomAlpha,
									  out float fBlend)
{
		float fThreshold = saturate(1.0f - (fVertexAlpha + fThresholdBias));
		float fAlphaForBlend = 1.0f;

		if (bUseTopAlpha)
		{
			fAlphaForBlend *= bInvertTopAlpha ? (1.0f - fTopAlpha) : fTopAlpha;
		}

		if (bUseBottomAlpha)
		{
			fAlphaForBlend *= bInvertBottomAlpha ? (1.0f - fBottomAlpha) : fBottomAlpha;
		}

		fBlend = saturate((fAlphaForBlend - fThreshold) * (1.0f / (fThresholdBlend + 0.00001f)));
}

void ApplyThresholdBlend(float fThesholdBlend, float fThresholdBias, float fVertexAlpha, float fTextureAlpha, out float fAlpha)
{
		float fThreshold = saturate(1.0f - (fVertexAlpha + fThresholdBias));
		
		// As vertex alpha increases, allow more texture to show through.
		// Using >= is important here. Can't rewrite this as clip(a - threshold).
		if (fThreshold >= fTextureAlpha)
		{
			clip(-1.0f);
		}
	
		// Re-scale alpha based on material setting:
		// Move some of this to vertex shader or CPU...
		fAlpha = saturate((fTextureAlpha - fThreshold) * (1.0f / (fThesholdBlend + 0.00001f)));
}
 
void DirectionalLight(float3 vNormal,
					  float3 vViewDirection,
					  float3 vLightDirection,
					  float3 vLightColor,
					  float3 vSpecularColor,
					  float fGloss,
					  inout float3 vDiffuseLighting,
					  inout float3 vSpecularLighting)
{
	float fRoughness = 1.0f - sqrt(fGloss + 0.0001f) * 0.793f;
	float fA = fRoughness * fRoughness;
	float fA2 = fA * fA;

	float fRemappedRoughness = fRoughness * 0.5f + 0.5f;
	float fAv = fRemappedRoughness * fRemappedRoughness;
	float fK = fAv * 0.5f;

	float3 vHalfDir = normalize(vViewDirection + vLightDirection);

	float fNdotL = saturate( dot(vNormal, vLightDirection) );
	float fNdotH = saturate( dot(vNormal, vHalfDir) );
	float fNdotV = saturate( dot(vNormal, vViewDirection) );

	float fDenominator = (fNdotH * (fA2 * fNdotH - fNdotH) + 1.0f);
	fDenominator *= fDenominator;

	float fVL =(fNdotL - fNdotL * fK) + fK;
	float fVV =(fNdotV - fNdotV * fK) + fK;
	fDenominator *= fVL * fVV * 4.0f;
	
	float3 vDiffuse = fNdotL * vLightColor * vLightColor;
	float3 vSpecular = vDiffuse * vSpecularColor * fA2 / fDenominator;

	vDiffuseLighting += vDiffuse;
	vSpecularLighting += vSpecular;
}

texture _environment_map <
	string UIName = "Cubemap";
	string ResourceName="d:\\Data\\loosetextures\\cubemaps\\max_cubemap.dds";
	string ResourceType = "CUBE";
>;

samplerCUBE _environmentSampler = sampler_state
{
	Texture = <_environment_map>;
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
	AddressW = Clamp;
};

#define NUM_MIPS 6

float3 SampleCubeBlur(float3 vDirection, float fGloss)
{
	float fLod = (1.0f  - fGloss) * NUM_MIPS;
	float4 vColor = texCUBElod(_environmentSampler, float4(vDirection, fLod));
	return vColor.rgb * vColor.rgb;
}


float3 FresnelAmbient(float3 x, float fNdotV, float fGloss)
{
	float4 t = float4( 1.0f/0.96f, 0.475f, (0.0275f - 0.25f * 0.04f)/0.96f, 0.25f ); 
	t *= fGloss.xxxx; 
	t += float4( 0.0f, 0.0f, (0.015f - 0.75f * 0.04f)/0.96f, 0.75f ); 
	float a0 = t.x * min( t.y, exp2( -9.28f * fNdotV ) ) + t.z; 
	float a1 = t.w; 
	return saturate( a0 + x * ( a1 - a0 ) + 0.01f );
}

void EnvironmentLight(float3 vNormal,
						float3 vView,
						float fNdotV,
						float3 vSpecularColor,
						float fGloss,
						inout float3 vDiffuseLighting,
						inout float3 vSpecularLighting)
{
	// Environment Lighting
	float3 vAmbientFresnel = FresnelAmbient(vSpecularColor, fNdotV, fGloss);
	float3 vReflect = normalize(reflect(-vView, -vNormal));
	vSpecularLighting += vAmbientFresnel * SampleCubeBlur(vReflect, fGloss) * 0.5f;
	vDiffuseLighting += SampleCubeBlur(vNormal, 0.0f) * 0.5f;
}

float4 tonemap( float4 value )
{
	float3 retColor = 1.0275f * value.rgb / (value.rgb + 0.22f);
	return float4(retColor, value.a);
}


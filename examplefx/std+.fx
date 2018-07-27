////////////////////////////////
// Uber shader.
// -Johan Kohler 2006
// -Denis Trofimov 2006-2010
////////////////////////////////


//#define DISABLE_LIGHTING
//#define DISABLE_FOG
//#define ENABLE_POINT_EDGE
//#define USE_VARIANCE_SHADOWS


#include "../Common/std+_tweaks.fxh"
#include "../Common/std+_textures.fxh"


#ifdef UBER

	#if defined(DISABLE_LIGHTING) && defined(DISABLE_TRANSFALLOFF)
		#define DISABLE_NORMAL
	#endif

	#ifndef ENABLE_TEXCOORD0
		#define DISABLE_TEXCOORD0
	#endif

	#ifndef ENABLE_TEXCOORD1
		#define DISABLE_TEXCOORD1
	#endif
	
	#if defined(DISABLE_LIGHTING) && defined(DISABLE_FOG)
		#define DISABLE_WORLDPOS
	#endif

#endif

////////////////////////////////
// Scene matrices.
////////////////////////////////
float4x4 worldViewProj	: WorldViewProjection;
float4x4 worldView		: WorldView;
float4x4 world			: World;
float4x4 view			: View;
float4x4 viewInv		: ViewInverse;
float4x4 viewProj		: ViewProjection;

// Skinning
#ifdef ENABLE_SKINNING
#ifdef PS3
float3x4 BoneArrayWorld[64] : BoneArrayWorld;
#else
float4x3 BoneArrayWorld[64] : BoneArrayWorld;
#endif
#endif

// LuxFog.
float3	LuxFog_range = {100,1,1};
float4	LuxFog_color = {0,0,0,0};
float4	LuxFog_diffuseColor = {1,1,1,1};

#define MAX_LOCAL_LIGHTS 2
float3 LuxLightSet_Irradiance[9];
float3 LuxLightSet_Ambient = {1,1,1};
float3 LuxLightSet_Dir_Direction = {-20,-10,30};
float3 LuxLightSet_Dir_Color = {1,1,1};
float4 LuxLightSet_Pos_Position[MAX_LOCAL_LIGHTS];
float3 LuxLightSet_Pos_Color[MAX_LOCAL_LIGHTS];
float4 LuxLightSet_params; // numLights, shadowFadeStart, shadowEnd, invFadeDelta

float4x4 luxShadowMapMat : LuxShadowMapMat = {
	{1,0,0,0},
	{0,1,0,0},
	{0,0,1,0},
	{0,0,0,1},
};

static const float2 ShadowScatter[4][4] = {
	{	
		{-2.403328f,  0.4608f,},
		{ 0.791552f, -2.091008f,},
		{-1.482752f,  2.14528f,},
		{ 0.549888f,  2.423808f,}
	}, {
		{-0.708608f, -0.888832f,},
		{-1.630208f, -0.93696f,},
		{-1.236992f, -1.226752f,},
		{-0.4352f,   -0.93696f,},
	}, {
		{-0.0512f,    0.10752f,},
		{-0.771072f,  1.760256f,},
		{-1.89952f,  -0.004096f,},
		{ 1.16736f,  -1.241088f,},
	}, {
		{ 0.700416f,  0.279552f,},
		{ 0.181248f,  0.662528f,},
		{ 0.830464f,  0.431104f,},
		{ 0.555008f,  1.526784f,},
	},
};

float4x4 luxProjTexCoordMat : LuxProjTexCoordMat = {
	{1,0,0,0},
	{0,1,0,0},
	{0,0,1,0},
	{0,0,0,1},
};

float luxProjTexBlend : LuxProjTexBlend = 0;

float Time:Time <
	string UIName = "Time";
> = 0;


////////////////////////////////
// Vertex input declarition
////////////////////////////////
struct VertexInput {
	float3	pos			: POSITION;
#ifndef DISABLE_NORMAL
	float3	normal		: NORMAL;
#endif

#ifndef DISABLE_NORMAL_MAP
	float3	binormal	: BINORMAL0;
	float3	tangent		: TANGENT0;
#endif

#ifndef DISABLE_TEXCOORD0
	float2	texCoord0	: TEXCOORD0;
#endif

#ifndef DISABLE_TEXCOORD1
	float2	texCoord1	: TEXCOORD1;
#endif

#ifndef DISABLE_MIX_CHANNEL_0
	float3	mixa		: TEXCOORD6;
#endif
#ifndef DISABLE_MIX_CHANNEL_1
	float3	mixr		: TEXCOORD3;
#endif
#ifndef DISABLE_MIX_CHANNEL_2
	float3	mixg		: TEXCOORD4;
#endif
#ifndef DISABLE_MIX_CHANNEL_3
	float3	mixb		: TEXCOORD5;
#endif

#ifdef ENABLE_SKINNING
	float4 blendWeights : BLENDWEIGHT0;
	float4 blendIndices : BLENDINDICES0;
#endif
#ifdef _3DSMAX_
	float4 Color0 : TEXCOORD2;
	float3 ColorA : TEXCOORD6;
#else
#ifndef DISABLE_VERTEX_COLOR
	float4 Color0 : COLOR0;
#endif
#endif
};

////////////////////////////////
// Pixel input declarition
////////////////////////////////
struct PixelInput {
	float4	hPos		: POSITION;
	
	
#if !defined(DISABLE_DIFFUSE_TEXTURE1) || !defined(DISABLE_DIFFUSE_TEXTURE2)
	float4  texCoord12   : TEXCOORD0;
#endif

#if !defined(DISABLE_DIFFUSE_TEXTURE3) || !defined(DISABLE_DIFFUSE_TEXTURE4)
	float4  texCoord34   : TEXCOORD1;
#endif

#ifndef DISABLE_NORMAL
	float3	normal		: TEXCOORD2;
#endif

#if !defined(DISABLE_NORMAL_MAP) || !defined(DISABLE_SPECULAR_MAP)
	float4	texCoordNS	: TEXCOORD3;
#endif
	
#ifndef DISABLE_NORMAL_MAP
	float3	binormal	: TEXCOORD4;
	float3	tangent		: TEXCOORD5;
#endif

#if !defined(DISABLE_MIX_CHANNEL_0) || !defined(DISABLE_MIX_CHANNEL_1) || !defined(DISABLE_MIX_CHANNEL_2) || !defined(DISABLE_MIX_CHANNEL_3)
	float4	mix			: TEXCOORD6;
#endif

#ifndef DISABLE_WORLDPOS
	float3	worldPos	: TEXCOORD7;
#endif

#ifndef DISABLE_VERTEX_COLOR
	float4	vertexColor	: COLOR0;
#endif
	
	float4	ambient		: COLOR1;


};
/*
// Shadow calculation
float Shadow(float3 worldPos)
{
	if(!ReceiveShadow) {
		return 1.0f;
	}
	
	float3 shadowPos = mul(float4(worldPos,1.0),luxShadowMapMat).xyz;

	#ifdef USE_VARIANCE_SHADOWS
    float avgZ = tex2D(LuxShadowBlurMap_Sampler, shadowPos.xy).x;
    float avgZ2 = tex2D(LuxShadowSqrBlurMap_Sampler, shadowPos.xy).x; 
	float lit = float(shadowPos.z <= avgZ); 
	float variance = abs(avgZ2 - avgZ*avgZ);
	float d = shadowPos.z - avgZ;
	float p = variance / (variance + d*d);
	float ret = max(lit, pow(p, 9.0));
	#else
	float ret = 1;
	float invsize = luxShadowMapMat[0].w;
	float4 depths;
	float4 results;
	depths.x = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[0][0]).x;
	depths.y = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[0][1]).x;
	depths.z = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[0][2]).x;
	depths.w = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[0][3]).x;
	results.x = dot(shadowPos.z <= depths, float(1.0/4.0).xxxx);
	depths.x = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[1][0]).x;
	depths.y = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[1][1]).x;
	depths.z = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[1][2]).x;
	depths.w = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[1][3]).x;
	results.y = dot(shadowPos.z <= depths, float(1.0/4.0).xxxx);
	depths.x = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[2][0]).x;
	depths.y = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[2][1]).x;
	depths.z = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[2][2]).x;
	depths.w = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[2][3]).x;
	results.z = dot(shadowPos.z <= depths, float(1.0/4.0).xxxx);
	depths.x = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[3][0]).x;
	depths.y = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[3][1]).x;
	depths.z = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[3][2]).x;
	depths.w = tex2D(LuxShadowMap_Sampler,shadowPos.xy+invsize.xx*ShadowScatter[3][3]).x;
	results.w = dot(shadowPos.z <= depths, float(1.0/4.0).xxxx);
	if(ShadowComplexity == 1) {
		ret = results.x;
	} else if(ShadowComplexity == 2) {
		ret = (results.x+results.y)/2;
	} else if(ShadowComplexity == 3) {
		ret = (results.x+results.y+results.z)/3;
	} else if(ShadowComplexity == 4) {
		ret = dot(results, float(1.0/4.0).xxxx);
	}
	#endif
	
	float2 uvDist = 2*shadowPos.xy - 1;
	float amount = pow(dot(uvDist, uvDist), 16.0);
	return saturate(ret + amount);
}
*/
// Does the diffuse irradiance.
float3 IrradianceLighting(float3 normal)
{

	// Diffuse Irradiance
	float3 N = normal;
	float3 Nxx = N*N;
	float3 Nxy = N*N.yzx;
	return  LuxLightSet_Irradiance[0]*Nxx.x +
			LuxLightSet_Irradiance[1]*Nxx.y +
			LuxLightSet_Irradiance[2]*Nxx.z +
			LuxLightSet_Irradiance[3]*Nxy.x +
			LuxLightSet_Irradiance[4]*Nxy.y +
			LuxLightSet_Irradiance[5]*Nxy.z +
			LuxLightSet_Irradiance[6]*N.x +
			LuxLightSet_Irradiance[7]*N.y +
			LuxLightSet_Irradiance[8]*N.z;
}

void PointLight(inout float3 diffSum,
				inout float3 specSum,
				inout float3 edgeSum,
				float3 worldPos,
				float3 camDir,
				float3 normal,
				int idxPos)
{
		float3 L = LuxLightSet_Pos_Position[idxPos].xyz-worldPos;

		float atten = saturate( 1.0 - (dot(L,L)*LuxLightSet_Pos_Position[idxPos].w));
		float3 LightColor = LuxLightSet_Pos_Color[idxPos] * atten;
		float3 LightDirection = normalize(L);
		diffSum += max(0,dot(normal,LightDirection))*LightColor;

		float3 halfDir = normalize(camDir+LightDirection);
		specSum += pow(max(0,dot(normal,halfDir)), Specular_Power) * LightColor;

#ifdef ENABLE_POINT_EDGE
		// Edge lighting from point lights disabled for now
		//float edge = 1.0 - abs(dot(camDir,normal)); 
		//edgeSum += pow(edge,Edge_Power) * LightColor;
#endif
}

//

float GaussianSpec (float3 halfDir, float3 norm, float roughness, float brightness)
{
	float i = 0;
	if (roughness) {
		float HdotN = dot(halfDir,norm);
		float k = (1.0 - HdotN)/roughness;
		i = exp(-(k*k));
		i = lerp(i*(1-HdotN), i, brightness);
	}
	return i;
}

float PhongSpecular (float3 halfDir, float3 normal, float power, float wrap)
{
	float HdotN = saturate(dot(halfDir,normal));

	float i = (HdotN < 0) ? 0 : pow(abs((HdotN + wrap)/(1 + wrap)), power); 
	return i;
}

float BacklightSpecular (float3 halfDir, float3 normal, float power, float factor)
{
	float HdotN = dot(halfDir,normal);
	float a = pow(max(1.0 - HdotN,0), power)*factor;
	return a;
}

float BackviewSpecular (float3 view, float3 normal, float power, float factor)
{
	float VdotN = dot(view,normal);
	float a = pow(max(1.0 - abs(VdotN),0), power)*factor;
	return a;
}

float LocalIllumGlossy (float3 halfDir, float3 normal, float roughness, float sharpness, float brightness)
{
    float w = (1-brightness)*(1-sharpness);
	return lerp(max(0, brightness-w), min(brightness+w, 1), pow(max(0,dot(normal,halfDir)), 1/roughness));
}

float CookTorranceSpec(float3 halfDir, float3 view, float3 norm, float hard)
{
	float VdotN = max(0,dot(view,norm));
	VdotN = sqrt(1.0 - VdotN*VdotN);
//	float Nn3 = faceforward(normalize(norm), -view);
	float HdotN = max(0,dot(halfDir,norm));
	HdotN = sqrt(1.0 - HdotN*HdotN);
	float i = pow(HdotN, hard);
	
	return (i/(0.1+VdotN));
}

float CookTorranceSpecular (float3 light, float3 view, float3 norm, float roughness, float smoothness, float minFresnel, float maxFresnel, bool orientation) 
{
	float i = 0;
	if (roughness) {
		float3 LN = normalize(light);
		float3 VN = normalize(view);
//		float3 NN = faceforward(norm, -view, norm);
	
		float VdotN = dot(VN,norm);
		float LdotN = dot(LN,norm);
	
		float3 halfDir = normalize(VN + LN);
		float HdotN = dot(halfDir,norm);
		float HdotV = (!orientation) ? dot(halfDir,VN) : 1.0;
	
		float m2 = roughness*roughness;
		float t = HdotN;
		float t2 = t*t;
		float v = VdotN;
		float vp = LdotN;
		float u = HdotV;
	
		float D = 0.5/(m2*t2*t2)*exp((t2-1)/(m2*t2));
		float G = (!orientation) ? min(1, 2*min(t*v/u, t*vp/u)) : min(1, 2*t*vp/u);
//		float G = min(1, 2*min(t*v/u, t*vp/u));
		
		float F = 1.0 - abs((!orientation) ? v : vp);
		F = lerp(minFresnel,maxFresnel,F);
		
//		float F = pow(1+v, refraction);
		i = (D*F*G)/v;
		i = lerp(i*(1-t2), i, smoothness);		
//		if (reverse) { i = -i; }
	}
	return i;
}

float LambertDiffuse(float3 light, float3 normal, float wrap = 0) 
{
	float NdotL = saturate(dot(normal,normalize(light))); 
	return (NdotL+wrap)/(1+wrap);
}
float OrenNayarDiffuse(float3 light, float3 view, float3 norm, float roughness = 0) 
{
 	float3 LN = normalize(light);
	float VdotN = max(0,dot(view,norm));
	float LdotN = max(0,dot(LN,norm));

	float cos_theta_i = LdotN;
	float theta_r = acos(VdotN);
	float theta_i = acos(cos_theta_i);
	float alpha = max(theta_i, theta_r);	
	float beta = min(theta_i, theta_r)*0.95;
	float sigma2 = roughness*roughness;

	float A = 1.0 - 0.5*sigma2/(sigma2+0.33);	
	float B = 0;

	float3 VperpN = normalize (view-norm*VdotN);
	float3 LperpN = normalize (LN-norm*LdotN);
	
	float cos_phi_diff = dot(VperpN, LperpN);
	if (cos_phi_diff >= 0) {
		B = 0.45*sigma2/(sigma2+0.09);
		B *= sin(alpha)*tan(beta)*max(0,cos_phi_diff);
	}
	return cos_theta_i*(A + B);
}

float MinnaertDiffuse(float3 light, float3 view, float3 norm, float darkness = 1, float brightness = 1, float sharpness = 1) 
{
 	float i = 0;
	float3 LN = normalize(light);
	float VdotN = max(0,dot(view,norm));
	float LdotN = max(0,dot(LN,norm));

	LdotN = lerp(LdotN, 1, 1 - sharpness);
	
	float cos_theta_i = LdotN;
	
	if (darkness <= 1.0)
		i = cos_theta_i * pow(max(VdotN*LdotN, 0.1), darkness-1.0); /*The Real model*/
	else
		i = cos_theta_i * pow(max(1.001-VdotN, 0.001), darkness-1.0); /*Nvidia model*/
	
	return max(0,i*brightness);
}

float BlinnSpec(float3 light, float3 view, float3 norm, float eccentricity, float rolloff) 
{
	float3 V = view;
	float3 N = norm;
	float  dotNV = dot(N, V);

	float  ecc = eccentricity*eccentricity - 1.0;

	float3 L = light;
	float3 H = normalize(view + light);

	float  dotNL = dot(N, L);
	float  dotNH = dot(N, H);
	float  dotVH = dot(V, H);

	float D = ( ecc + 1 ) / ( 1 + ecc * dotNH * dotNH );
	D *= D;
	dotNH *= 2;

	float G;
	G = (dotNV < dotNL)
		? (dotNV * dotNH < dotVH) ? dotNH / dotVH : 1 / dotNV
		: (dotNL * dotNH < dotVH) ? dotNL * dotNH / (dotVH * dotNV) : 1 / dotNV;

	dotVH = pow(1 - dotVH, 3);
	float F = dotVH + (1 - dotVH)*rolloff;
	float i = (dotNL > 0) ? D*G*F : 0;
	
	return i;	
}

float3 RotatePointAroundVector (float3 pos, float3 vect, float angle) 
{
	float x = pos.x;	
	float y = pos.y;	
	float z = pos.z;
	
	float u = vect.x;	
	float v = vect.y;	
	float w = vect.z;

	float ux = u*x;
	float uy = u*y;
	float uz = u*z;

	float vx = v*x;
	float vy = v*y;
	float vz = v*z;

	float wx = w*x;
	float wy = w*y;
	float wz = w*z;

	float vv = v*v;
	float uu = u*u;
	float ww = w*w;	
	
	float sang, cang;
	sincos(angle,sang, cang);
	
	float new_x = u*(ux+vy+wz) + (x*(vv+ww) - u*(vy+wz))*cang  + (-wy+vz)*sang; 
	float new_y = v*(ux+vy+wz) + (y*(uu+ww) - v*(ux+wz))*cang  + (wx-uz)*sang; 
	float new_z = w*(ux+vy+wz) + (z*(uu+vv) - w*(ux+vy))*cang  + (-vx+uy)*sang; 
	
	return (float3 (new_x,new_y,new_z));
}

float3 PairVectorTransit (float3 pos, float3 vect1, float3 vect2) 
{
	float3 v1 = normalize(vect1);
	float3 v2 = normalize(vect2);
 
	float3 vect = normalize (cross (v1, v2));
	float angle = acos (dot (v1, v2));
	
	return RotatePointAroundVector(pos,vect,angle);
}

float WardAnisotropic (float3 halfDir, float3 light, float3 view, float3 normal, float intensity, float xroughness, float yroughness, float angle, float3 tangent, float3 binormal) 
{
	float i = 0;
	
	float3 LN = normalize(light);
	float cos_theta_i = dot(LN,normal);
	
	if (cos_theta_i > 0.0) {
		float xr = max(0.00001,xroughness);
		float yr = max(0.00001,yroughness);

		float cos_theta_r = max(0.0001, dot(normal,view));

		float3 T = RotatePointAroundVector (tangent, normal, angle);
		float3 B = normalize(cross(normal,T));
		float3 X = T/xr;
		float3 Y = B/yr;
			
		float XdotH = dot(X,halfDir);
		float YdotH = dot(Y,halfDir);
		float HdotN = dot(halfDir,normal);
		float rho = exp (-(XdotH*XdotH + YdotH*YdotH)/(1 + HdotN))/sqrt(cos_theta_i*cos_theta_r);
		i = (cos_theta_i*rho);
	}
	return (i*intensity);
}

float3 myRefraction (float3 view, float3 normal, float thickness)
{	
	float pi = 3.14159;
	float VdotN = dot(view,normal);	
	float3 lamRGB = float3(6,5,4);
	float3 offsetRGB = float3(0,0,0);
	float3 vd = 60;
//	float k = exp(-(1+VdotN));
	float k = 1/VdotN;

	float3 ang = (2*pi*vd/lamRGB)*thickness*k + 0.5*pi + offsetRGB;

	return 0.5*(sin(ang)+1);
}
//
float3 LightIt(float3 normal, float3 diffuseCol,float3 worldPos,float Specular_Power,float3 Specular_Color, float3 ambient, 
	float3 reflection, float3 tangent, float3 binormal, float phongpower, float emission = 0)
{
	float3 diffSum = 1;
	float3 specSum = 0;
	float3 edgeSum = 0;
	float3 camPos = viewInv[3].xyz;
	float3 camDir = normalize(camPos-worldPos);

	//
#if !defined(_3DSMAX_)
	
	
	float nDotL = dot(normal,LuxLightSet_Dir_Direction);
	float shadow = 1;
	diffSum = ambient;
	
#if defined(X360)
	if (nDotL > 0)
	{
		shadow = Shadow(worldPos);
		
		diffSum += max(0, nDotL) * LuxLightSet_Dir_Color * shadow;
		
		float3 halfDir = normalize(camDir+LuxLightSet_Dir_Direction);
		specSum += pow(max(0,dot(normal,halfDir)), Specular_Power)*LuxLightSet_Dir_Color * shadow;
	}
#else
	
	diffSum += max(0, nDotL) * LuxLightSet_Dir_Color * shadow;
		
	float3 halfDir = normalize(camDir+LuxLightSet_Dir_Direction);
	specSum += pow(max(0,dot(normal,halfDir)), Specular_Power)*LuxLightSet_Dir_Color*shadow;
	
#endif

	float edge = 1.0 - abs(dot(camDir,normal)); 
	edgeSum += pow(edge,Edge_Power) * LuxLightSet_Dir_Color;

	if(LuxLightSet_params[0] > 0) {
		PointLight(diffSum,specSum,edgeSum,worldPos,camDir,normal,0);
		if(LuxLightSet_params[0] > 1) {
			PointLight(diffSum,specSum,edgeSum,worldPos,camDir,normal,1);
		}
	}
#else
	// Simple lighting for max.
	diffSum = Ambient;
	specSum = 0;
	float c = 0;
	float k = 0;
	float b = 0;
	float w = 0;

	float3 halfDir = normalize(camDir+Dir1_Direction);
	float HdotN = dot(halfDir,normal);
	float VdotN = dot(camDir,normal);
		
	k += float(Use_Lambert)		  * LambertDiffuse (Dir1_Direction, normal, Lambert_Wrap);
	k += float(Use_OrenNayar)	  * OrenNayarDiffuse (Dir1_Direction, camDir, normal, OrenNayar_Roughness);
	k += float(Use_Minnaert)	  * MinnaertDiffuse (Dir1_Direction, camDir, normal, Minnaert_Darkness, Minnaert_Brightness, Minnaert_Sharpness);
	
	c += float(Use_Phong)		  * PhongSpecular (halfDir, normal, phongpower, Phong_Wrap);
	c += float(Use_Gaussian)	  * GaussianSpec (halfDir, normal, Gaussian_Roughness, Gaussian_Brightness);
	b  = float(Use_BackSpec)	  * (
										(BackSpec_Light) 
										? BacklightSpecular (halfDir, normal, BackSpec_Power, BackSpec_Factor)
										: BackviewSpecular (camDir, normal, BackSpec_Power, BackSpec_Factor)
									);
	c += b;
	c += float(Use_Blinn)		  * BlinnSpec (Dir1_Direction, camDir, normal, Blinn_Eccentricity, Blinn_Rolloff);
	c += float(Use_Glossy)		  * LocalIllumGlossy (halfDir, normal, Glossy_Roughness, Glossy_Sharpness, Glossy_Brightness);
	c += float(Use_CookTorrance)  * CookTorranceSpecular (Dir1_Direction, camDir, normal, CookTorrance_Roughness, CookTorrance_Smoothness, CookTorrance_Fresnel_Min, CookTorrance_Fresnel_Max, CookTorrance_Orientation);		
	w  = float(Use_Ward)		  * WardAnisotropic (halfDir, Dir1_Direction, camDir, normal, Ward_Intensity, Ward_RoughnessX, Ward_RoughnessY, Ward_Orientation, tangent, binormal);		
	c += w;
//	c += float(Use_OrenNayarSpec) * OrenNayarDiffuse (halfDir, camDir, normal, OrenNayar_Roughness);

	diffSum += k*Dir1_Color;
	specSum += c*Dir1_Color;

#endif

	float3 col = diffuseCol*lerp(1, diffSum, emission);

	if(Use_Specular) {
		if(Use_Refraction) {
			float rf = 1;
			float3 refractCol = myRefraction (camDir, normal, Refraction_Angle);
			refractCol = lerp(specSum, refractCol, Refraction_Sheen*saturate(HdotN));
			if (Use_Normal_Refraction) {
//				float edge = (Invert_Normal_Refraction) ? (1.0 - saturate(HdotN)) : saturate(HdotN);
				float edge = (Invert_Normal_Refraction) ? (1.0 - HdotN) : HdotN;
				rf *= pow(abs(edge),Normal_Refraction_Power);		
			}
			col += lerp(Specular_Color*specSum,refractCol*Refraction_Tint, rf);
		}
		else col += specSum*Specular_Color*emission;
		col += b*BackSpec_Tint*emission;
	}
	
	if (Use_Edge) 
	{
		float edge = (Edge_Light_Based) ? HdotN : abs(VdotN);
		edge = (edge + Edge_Wrap*Edge_Wrap)/(1 + Edge_Wrap*Edge_Wrap);

		float fresnel = 1;
		if (Use_Fresnel) {
			fresnel = 1.0 - abs(dot(camDir,normal)); 
			edge = (edge < Fresnel_Min) ? 0 : edge;
			edge = (edge > Fresnel_Max) ? 1 : edge;
//			fresnel = lerp(Fresnel_Min, Fresnel_Max, fresnel);
//			fresnel = clamp(edge, Fresnel_Min, Fresnel_Max);
		}
				
	//	float edge = (Edge_Light_Based) ? 1.0 - HdotN : 1.0 - abs(VdotN); 

		//float e = pow(abs(edge),2.0);	
		
		if (!Edge_Multiply) 
		{
			edge = 1.0 - edge; 
			edgeSum += edge*reflection*Dir1_Color;
			col += edgeSum*Edge_Color;
		}
		else 
		{
			col += edgeSum;
			col = lerp(Edge_Color*reflection*Dir1_Color,col,edge);
//			col *= Edge_Color*reflection*Dir1_Color*pow(edge,Edge_Power);
		}
	}

	return  col;
}

// Transform a point tru the skinning matrices.
float3 Skin(float4 v,float4 indices,float4 weights)
{
#ifdef ENABLE_SKINNING

#ifdef PS3
	return	mul(BoneArrayWorld[indices.x],	v) * weights.x +
			mul(BoneArrayWorld[indices.y],	v) * weights.y +
			mul(BoneArrayWorld[indices.z],	v) * weights.z +
			mul(BoneArrayWorld[indices.w],	v) * weights.w;
#else
	return	mul(v,	BoneArrayWorld[indices.x]) * weights.x +
			mul(v,	BoneArrayWorld[indices.y]) * weights.y +
			mul(v,	BoneArrayWorld[indices.z]) * weights.z +
			mul(v,	BoneArrayWorld[indices.w]) * weights.w;
#endif

#else
	return v.xyz;
#endif
}

// Read a texture
float4 ReadTexture(sampler2D s,float2 coord1,float2 coord2,bool coordSel,
			float2 Texture_MatX,float2 Texture_MatY,float2 Texture_MatZ,float2 Texture_MatT)
{
	float2 coord = coordSel?coord2:coord1;

	coord =		Texture_MatX*coord.x+
				Texture_MatY*coord.y+
				Texture_MatZ+
				
#ifdef _3DSMAX_
//				Texture_MatT*(float2((Time*6.25)/30,(sin(Time)*6.25)/30))
				Texture_MatT*((Time*6.25)/30)
				+Texture_MatY
#else
				Texture_MatT*Time
#endif
				;

	return tex2D(s,coord);
}

// Cacluate texture coordinates
float2 CalcTexCoord(float2 coord1, float2 coord2, bool coordSel, 
		float2 Texture_MatX, float2 Texture_MatY, float2 Texture_MatZ, float2 Texture_MatT)
{
	float2 coord = coordSel?coord2:coord1;

	coord =		Texture_MatX*coord.x+
				Texture_MatY*coord.y+
				Texture_MatZ+
				
#ifdef _3DSMAX_
//				Texture_MatT*(float2( sin(Time*0.3)*6.25/30, Time*6.25/30 ))
				Texture_MatT*((Time*6.25)/30)
				+Texture_MatY
#else
				Texture_MatT*Time
#endif
				;

	return coord;
}		


////////////////////////////////
// Vertex shader
////////////////////////////////
PixelInput VShader(VertexInput IN)
{
	PixelInput OUT;

	float3 normal = 0;
#ifndef DISABLE_NORMAL
	normal = IN.normal;
#endif

	float3 binormal = 0;
	float3 tangent = 0;
#ifndef DISABLE_NORMAL_MAP
	binormal = IN.binormal;
	tangent = IN.tangent;
#endif
	
	float3 worldPos = 0;


#ifdef ENABLE_SKINNING
	{
		// Skinned
		float4	weights = IN.blendWeights;
		float4	indices = IN.blendIndices;
		
		float3  pos = Skin(float4(IN.pos,1),indices,weights);
		
		normal = 	Skin(float4(normal,0),indices,weights);
		tangent =	Skin(float4(tangent,0),indices,weights);
		binormal = 	Skin(float4(binormal,0),indices,weights);

		worldPos = pos;
		OUT.hPos = mul(float4(pos,1),viewProj);
		
	}
#else //Use_Skinning
	{
		// Unskinned
		float3 pos = IN.pos;

		normal = mul(float4(normal,0),world).xyz;
		tangent =	mul(float4(tangent,0),world).xyz;
		binormal =	mul(float4(binormal,0),world).xyz;

		worldPos = mul(float4(pos,1),world).xyz;

		OUT.hPos = mul(float4(pos,1),worldViewProj);
	}
#endif


	float2	texCoord0 = 0;
	float2	texCoord1 = 0;
	
#ifndef DISABLE_TEXCOORD0
	texCoord0 = IN.texCoord0;
#endif

#ifndef DISABLE_TEXCOORD1
	texCoord1 = IN.texCoord1;
#endif

#if !defined(DISABLE_DIFFUSE_TEXTURE1) || !defined(DISABLE_DIFFUSE_TEXTURE2)
	OUT.texCoord12 = float4(0,0,0,0);
#endif

#if !defined(DISABLE_DIFFUSE_TEXTURE3) || !defined(DISABLE_DIFFUSE_TEXTURE4)
	OUT.texCoord34 = float4(0,0,0,0);
#endif

#if !defined(DISABLE_NORMAL_MAP) || !defined(DISABLE_SPECULAR_MAP)
	OUT.texCoordNS = float4(0,0,0,0);
#endif



#ifndef DISABLE_DIFFUSE_TEXTURE1
	if(Use_Diffuse_Texture1) {
		OUT.texCoord12.xy = CalcTexCoord(texCoord0,texCoord1,Diffuse_Texture1_use_Chan_2,
										Texture1_Use_MatX?Texture1_MatX:float2(1,0),
										Texture1_Use_MatY?Texture1_MatY:float2(0,1),
										Texture1_Use_MatZ?Texture1_MatZ:0,
										Texture1_Use_MatT?Texture1_MatT:0);
	}
#endif


#ifndef DISABLE_DIFFUSE_TEXTURE2
	if(Use_Diffuse_Texture2) {
		OUT.texCoord12.zw = CalcTexCoord(texCoord0,texCoord1,Diffuse_Texture2_use_Chan_2,
										Texture2_Use_MatX?Texture2_MatX:float2(1,0),
										Texture2_Use_MatY?Texture2_MatY:float2(0,1),
										Texture2_Use_MatZ?Texture2_MatZ:0,
										Texture2_Use_MatT?Texture2_MatT:0);
	}
#endif


#ifndef DISABLE_DIFFUSE_TEXTURE3	
	if(Use_Diffuse_Texture3) {
		OUT.texCoord34.xy = CalcTexCoord(texCoord0,texCoord1,Diffuse_Texture3_use_Chan_2,
										Texture3_Use_MatX?Texture3_MatX:float2(1,0),
										Texture3_Use_MatY?Texture3_MatY:float2(0,1),
										Texture3_Use_MatZ?Texture3_MatZ:0,
										Texture3_Use_MatT?Texture3_MatT:0);
	}
#endif
	
	
#ifndef DISABLE_DIFFUSE_TEXTURE4
	if(Use_Diffuse_Texture4) {
		OUT.texCoord34.zw = CalcTexCoord(texCoord0,texCoord1,Diffuse_Texture4_use_Chan_2,
										Texture4_Use_MatX?Texture4_MatX:float2(1,0),
										Texture4_Use_MatY?Texture4_MatY:float2(0,1),
										Texture4_Use_MatZ?Texture4_MatZ:0,
										Texture4_Use_MatT?Texture4_MatT:0);
	}
#endif
	
	
#ifndef DISABLE_NORMAL_MAP
	if(Use_Normal_Map) {
	
		// Normal maps is always channel 1
		OUT.texCoordNS.xy = CalcTexCoord(texCoord0,texCoord0,false,
				NormalMap_Use_MatX?NormalMap_MatX:float2(1,0),
				NormalMap_Use_MatY?NormalMap_MatY:float2(0,1),
				NormalMap_Use_MatZ?NormalMap_MatZ:0,
				NormalMap_Use_MatT?NormalMap_MatT:0);
	}
#endif


#ifndef DISABLE_SPECULAR_MAP
	if (Use_Specular_Map) {
		OUT.texCoordNS.zw = CalcTexCoord(texCoord0,texCoord1,Specular_Map_use_Chan_2,
				SpecularMap_Use_MatX?SpecularMap_MatX:float2(1,0),
				SpecularMap_Use_MatY?SpecularMap_MatY:float2(0,1),
				SpecularMap_Use_MatZ?SpecularMap_MatZ:0,
				SpecularMap_Use_MatT?SpecularMap_MatT:0);

	}
#endif
	
	
#ifndef DISABLE_NORMAL
	normal = normalize(normal);
	OUT.ambient = float4((IrradianceLighting(normal) + LuxLightSet_Ambient), 1);
#else
	OUT.ambient = float4(LuxLightSet_Ambient, 1);
#endif

//#ifndef DISABLE_VERTEX_COLOR
	OUT.vertexColor = IN.Color0*LuxFog_diffuseColor;
	OUT.vertexColor.w = Use_Ambient_Occlusion ? IN.ColorA.x : 1.0;
//#endif

#ifndef DISABLE_NORMAL
	OUT.normal = normal;
#endif

#ifndef DISABLE_NORMAL_MAP
	OUT.tangent = tangent;
	OUT.binormal = binormal;
#endif

	float4 mix = 1;
#ifndef DISABLE_MIX_CHANNEL_0
	if(Use_Mix_Chan_1)
		mix.a = IN.mixa.x;
#endif

#ifndef DISABLE_MIX_CHANNEL_1
	if(Use_Mix_Chan_1)
		mix.r = IN.mixr.x;
#endif

#ifndef DISABLE_MIX_CHANNEL_2
	if(Use_Mix_Chan_2)
		mix.g = IN.mixg.x;
#endif

#ifndef DISABLE_MIX_CHANNEL_3
	if(Use_Mix_Chan_3)
		mix.b = IN.mixb.x;
#endif

#if !defined(DISABLE_MIX_CHANNEL_0) || !defined(DISABLE_MIX_CHANNEL_1) || !defined(DISABLE_MIX_CHANNEL_2) || !defined(DISABLE_MIX_CHANNEL_3)
	OUT.mix = mix;
#endif

#ifndef DISABLE_WORLDPOS
	OUT.worldPos = worldPos;
#endif
	return OUT;
}

////////////////////////////////
// Pixel shader
////////////////////////////////
float4 PShader(PixelInput IN) : COLOR
{
	float3	normal = 0;
	float4	mix = 1;
	float3	worldPos = 0;
	float3 	camPos = viewInv[3].xyz;
	float phongpower = Phong_Power;

#ifndef DISABLE_WORLDPOS
	worldPos = IN.worldPos;
#endif

	float3 	camDir = normalize(camPos-worldPos);
	float	eyeDist = length(worldPos-viewInv[3].xyz);

#ifndef DISABLE_NORMAL
	normal = IN.normal;
#endif


#if !defined(DISABLE_MIX_CHANNEL_0) || !defined(DISABLE_MIX_CHANNEL_1) || !defined(DISABLE_MIX_CHANNEL_2) || !defined(DISABLE_MIX_CHANNEL_3)
	mix = IN.mix;
#endif

	float4 diffuse = LuxFog_diffuseColor;
#ifndef DISABLE_VERTEX_COLOR
	if(Use_Vertex_Color) {
		// The diffuse color is in the color interp.
		diffuse = IN.vertexColor;
	}
#endif

	bool bLerp = false;
//	float a = Use_Ambient_Occlusion ? IN.vertexColor.w : 1.0;	
	float4 texCol = float4(Diffuse_Color.xyz,1);
	float normalMapLerp = 1;

#ifndef DISABLE_DIFFUSE_TEXTURE1
	float2 texCoord1 = IN.texCoord12.xy;
#endif

#ifndef DISABLE_DIFFUSE_TEXTURE2
	float2 texCoord2 = IN.texCoord12.zw;
#endif

#ifndef DISABLE_DIFFUSE_TEXTURE3
	float2 texCoord3 = IN.texCoord34.xy;
#endif

#ifndef DISABLE_DIFFUSE_TEXTURE4
	float2 texCoord4 = IN.texCoord34.zw;
#endif

#ifndef DISABLE_SPECULAR_MAP
	float2 spTexCoord = IN.texCoordNS.zw;
#endif

#ifndef DISABLE_NORMAL_MAP
	float2 nmTexCoord = IN.texCoordNS.xy;
	float4 normalTex = tex2D(Normal_Map_Sampler, nmTexCoord);
	
	if(Use_Parallax_Map) {
//		float  height   = tex2D(Normal_Map_Sampler, nmTexCoord).w * 0.06 - 0.03;		
		float  height   = (normalTex.w - Normal_Map_HeightBias)*0.06;		
		float2 uvOffset = height * Normal_Map_HeightFactor * (mul(float3x3(IN.binormal,IN.tangent,normal),camDir)).xy;
	
	#ifndef DISABLE_DIFFUSE_TEXTURE1
		texCoord1 += uvOffset;
	#endif

	#ifndef DISABLE_DIFFUSE_TEXTURE2
		texCoord2 += uvOffset;
	#endif

	#ifndef DISABLE_DIFFUSE_TEXTURE3
		texCoord3 += uvOffset;
	#endif

	#ifndef DISABLE_DIFFUSE_TEXTURE4
		texCoord4  += uvOffset;
//		texCoord4  += float(!Use_Texture4_As_Normal)*uvOffset;
	#endif
	
	#ifndef DISABLE_SPECULAR_MAP
		spTexCoord += uvOffset;
	#endif

		nmTexCoord += uvOffset;
		normalTex = tex2D(Normal_Map_Sampler, nmTexCoord);
	}
#endif

	float emission = 1;

#ifndef DISABLE_DIFFUSE_TEXTURE1
	if(Use_Diffuse_Texture1) {
	
		float4 tex = tex2D(Diffuse_Texture1_Sampler, texCoord1);
		if (Invert_Diffuse_Texture1) {
			if (Mask_Diffuse_Texture1) tex.a = 1 - tex.a; else tex.xyz = 1 - tex.xyz;
		}
		emission = tex.a;
		
		if (!Alpha_Diffuse_Texture1) tex.a = 1.0; 
		
		tex.a *= Texture_Opacity.r;
		if ( Use_Mix_Chan_0 ) tex.a *= mix.a;
		
		if ( Additive_Diffuse_Texture1 ) tex.a *= tex.r*tex.r;

		if (Mask_Diffuse_Texture1) tex.xyz = texCol.xyz;
		texCol.xyz = lerp(texCol.xyz, tex.xyz, tex.a);
//		if (bLerp) texCol = lerp(texCol, tex, tex.a); else texCol = tex;
		texCol.a = tex.a; 
		bLerp = true;

		if(AssociateNormalMapWith == 1) normalMapLerp = tex.a; else normalMapLerp *= 1-tex.a;
		if (Emissive_Diffuse_Texture1) {
			emission *= tex.a;
			if (Emissive_Effect < 0) emission = 1 - emission;
			emission = lerp(1,emission,abs(Emissive_Effect));
		}
		else emission = 1;
	}
#endif


#ifndef DISABLE_DIFFUSE_TEXTURE2
	if(Use_Diffuse_Texture2) {
		float4 tex = tex2D(Diffuse_Texture2_Sampler, texCoord2);
		if (Invert_Diffuse_Texture2) {
			if (Mask_Diffuse_Texture2) tex = 1 - tex; else tex.xyz = 1 - tex.xyz;
		}
		tex.xyz *= float3(Diffuse_Texture2_Tint.xyz);

		tex.a *= Texture_Opacity.g;
		tex.a *= mix.r;
		
		if(Use_Normal_Opacity) {
			float edge = abs(dot(camDir,normal)); 
			if(Invert_Normal_Opacity) {
				edge = 1.0 - edge;
			}
			tex.a *= pow(abs(edge),Normal_Opacity_Power);		
		}

		float alpha = Alpha_Diffuse_Texture2 ? tex.a : tex.r;
		if (Mask_Diffuse_Texture2) tex.xyz = texCol.xyz;

		if(bLerp)	texCol = lerp(texCol, tex, tex.a);
		else		texCol = tex;

//		texCol = lerp(texCol, tex, tex.a); 
		bLerp = true;
		if(AssociateNormalMapWith == 2) normalMapLerp = alpha; else normalMapLerp *= 1-alpha;
	}
#endif


#ifndef DISABLE_DIFFUSE_TEXTURE3
	if(Use_Diffuse_Texture3) {
		float4 tex = tex2D(Diffuse_Texture3_Sampler, texCoord3);
		if (Use_As_Gloss_Texture3)
		{
			phongpower = lerp(0.0, Phong_Power, tex.r);
		}
		else
		if (Use_Multiply_Texture3) {
			tex.xyz = lerp(float3(1,1,1), tex.xyz, Texture_Opacity.b*mix.g);
			texCol *= float4(tex.xyz,1);
		}
		else {
			tex.a *= Texture_Opacity.b;
			tex.a *= mix.g;
			
			if(bLerp)	texCol = lerp(texCol, tex, tex.a);
			else		texCol = tex;
			bLerp = true;
			if(AssociateNormalMapWith == 3) normalMapLerp = (tex.w*mix.g); else normalMapLerp *= 1-(tex.w*mix.g);
		}
	}
#endif

	float3 normalSec = 0;

#ifndef DISABLE_DIFFUSE_TEXTURE4
	if(Use_Diffuse_Texture4) {
		float4 tex = tex2D(Diffuse_Texture4_Sampler,texCoord4);

		#ifdef _3DSMAX_
			tex.a *= Texture_Opacity_3DSA.r;
		#else
			tex.a *= Texture_Opacity.a;
		#endif
			tex.a *= (Sync_Mix_Chan_3) ? mix.r : mix.b;

		if(Use_Texture4_As_Normal) {
			normalSec = tex.xyz*2-1;
			normalSec.xy *= Texture4_Normal_HeightScale*tex.a;			
		}
		else {
			if(bLerp)	texCol = lerp(texCol, tex, tex.a);
			else		texCol = tex;
			bLerp = true;
			if (AssociateNormalMapWith == 4) normalMapLerp = (tex.w*mix.b); else normalMapLerp *= 1-(tex.w*mix.b);
		}
	}
	
#endif
	
	normalMapLerp = lerp(1, normalMapLerp, max(AssociateNormalMapWith,1)*AssociateFactor);

	diffuse *= texCol;

#ifndef DISABLE_NORMAL_MAP
	if(Use_Normal_Map) {
		float3 binormal = IN.binormal;
		if (Normal_Map_FlipX) binormal *= -1; 
		float3 tangent = IN.tangent;
		if (Normal_Map_FlipY) tangent *= -1; 
		float3 newNormal = normal;
//		float3 normalMap = tex2D(Normal_Map_Sampler, nmTexCoord).xyz;
		float3 normalMap = normalTex.xyz;
		
		normalMap = normalMap*2-1;

		float normal_z = (Calculate_Normal_Z) ? sqrt(1-normalMap.x*normalMap.x-normalMap.y*normalMap.y) : normalMap.z;

		normalMap.xy *= Normal_Map_HeightScale;
				
		if (Use_Normal_Map_Contrast) {
		
			float3 halfDir = normalize(camDir+Dir1_Direction);
			float si = float(Normal_Invert_Contrast);
			
			if(Use_Texture4_As_Normal && Use_Diffuse_Texture4) {
			
				newNormal = (normal*normal_z) + (tangent*normalMap.y) + (binormal*normalMap.x);
			
				float edge = pow(abs(dot(halfDir,newNormal)),Normal_Map_Contrast); 
				float contrast = si - (si*2 - 1)*edge;
				normalSec.xy *= contrast;
				normalMap.xy += normalSec.xy;
			}
			else {
			
				float edge = pow(abs(dot(halfDir,normal)),Normal_Map_Contrast); 
				float contrast = si - (si*2 - 1)*edge;
				normalMap.xy *= contrast;
			}
		}
		else normalMap.xy += normalSec.xy;
		
		newNormal = (normal*normal_z) + (tangent*normalMap.y) + (binormal*normalMap.x);

		
		if (Ass_Normal) {
			float si = float(!Ass_Normal_Invert);
			newNormal = lerp(newNormal, normal,(si - (si*2 - 1)*normalMapLerp)*AssNormalFactor);
		}
		normal = newNormal;
	}
#endif
	normal = normalize(normal);

	float4 specTex = 1;
	
#ifndef DISABLE_SPECULAR_MAP
	if(Use_Specular_Map) {
		specTex = tex2D(Specular_Map_Sampler, spTexCoord);
	}
#endif
	

	float3 refCol = 1;

	if(Use_Reflection) {
		float3 camPos = viewInv[3].xyz;
//		float3 r = reflect(worldPos-camPos,normal);
		float f = (Reflection_Planarity > 0.0) ? saturate(dot(camDir,normal)) : 1 - saturate(dot(camDir,normal));
		float3 r = lerp(reflect(-camDir,normal), normal, abs(Reflection_Planarity)*f);
		refCol = texCUBE(Reflection_Map_Sampler,r.xzy);
		if (Ass_Reflection) {
			float si = float(!Ass_Reflection_Invert);
			refCol = lerp(refCol,0,(si - (si*2 - 1)*normalMapLerp)*AssReflectionFactor);
		}
	}

	specTex.xyz = lerp(1,specTex.xyz,Specular_Power);
	float3 specCol = Specular_Color.xyz*specTex.xyz;
//	float3 specCol = Specular_Color.xyz*specTex.xyz*Specular_Power;
	if (Ass_Specular) {
		float si = float(!Ass_Specular_Invert);
		specCol =  lerp(specCol,0,(si - (si*2 - 1)*normalMapLerp)*AssSpecularFactor);
	}

	diffuse.xyz = float(!Disable_lighting)*LightIt(normal,diffuse.xyz,worldPos,Specular_Power*specTex.a,specCol,IN.ambient, refCol, IN.tangent, IN.binormal, phongpower, emission);

	if(Use_Projected_Texture) {
		float4 projTexCoords = mul(float4(worldPos,1),luxProjTexCoordMat);
		diffuse.xyz *= lerp(float3(1,1,1), tex2D(Projected_Texture_Sampler,projTexCoords).xyz, luxProjTexBlend);
	}
	
	diffuse.xyz +=  float(Use_Reflection)*(refCol*specTex*Reflection_Power*specCol).xyz;


#if !defined(_3DSMAX_)
	if(Use_Fog) {
		float fogSat = clamp((eyeDist-LuxFog_range.x)*LuxFog_range.y,0,1) * LuxFog_color.w;
		diffuse.xyz = lerp(diffuse.xyz,LuxFog_color.xyz,fogSat);
	}
#endif

	if(Use_TransFalloff) {
		float3 viewNorm = mul(float4(normal,0),view).xyz;
		diffuse.w *= saturate(lerp(TransFalloff.x,TransFalloff.y,length(viewNorm.xy)));
	}

	return float4(diffuse.xyz,diffuse.w*LuxFog_range.z);
	//return float4(0.0,0.0,0.0,1.0);
}

#ifndef DISABLE_GLOW
//-----------------------------------------------------------------------------
// Glow shaders
//-----------------------------------------------------------------------------
float4 GlowPShader(PixelInput IN) : COLOR
{
	float2	texCoord0 = 0;
	float2	texCoord1 = 0;
		
	float4 tex = float4(1, 1, 1, 1);

	if ((AssociateNormalMapWith == 4) && (Use_Diffuse_Texture4))
	{
		#ifndef DISABLE_DIFFUSE_TEXTURE4
		tex = tex2D(Glow_Sampler, IN.texCoord34.zw);
		#endif
	}
	else if((AssociateNormalMapWith == 3) && (Use_Diffuse_Texture3)) 
	{
		#ifndef DISABLE_DIFFUSE_TEXTURE3
		tex = tex2D(Glow_Sampler, IN.texCoord34.xy);
		#endif
	}
	else if((AssociateNormalMapWith == 2) && (Use_Diffuse_Texture2)) 
	{
		#ifndef DISABLE_DIFFUSE_TEXTURE2
		tex = tex2D(Glow_Sampler, IN.texCoord12.zw);
		#endif
	}
	else 
	{
		#ifndef DISABLE_DIFFUSE_TEXTURE1
		tex = tex2D(Glow_Sampler, IN.texCoord12.xy);
		#endif
	}

	// Output the glow into the [0, 0.5] range of the alpha channel
	float glow = tex.r * 0.5f;
	return float4(glow, 0, 0, glow);
}
#endif

//-----------------------------------------------------------------------------
// Alpha mask rendering shaders
//-----------------------------------------------------------------------------
float4 AlphaMaskPShader(PixelInput IN) : COLOR
{
	// Output the alpha mask as an additive bit which moves the 
	// existing [0.0 to 0.5] range to the (0.5, 1.0] range.
	return float4((130.0f / 255.0f), 0, 0, (130.0f / 255.0f));
}

//-----------------------------------------------------------------------------
// Depth rendering shaders
//-----------------------------------------------------------------------------
struct DepthVertexInput {
	float3	pos			: POSITION;

#ifndef DISABLE_TEXCOORD0
	float2	texCoord0	: TEXCOORD0;
#endif

#ifndef DISABLE_TEXCOORD1
	float2	texCoord1	: TEXCOORD1;
#endif

#ifdef ENABLE_SKINNING
	float4 blendWeights : BLENDWEIGHT0;
	float4 blendIndices : BLENDINDICES0;
#endif
};

struct DepthVertexOutput {
	float4	hPos	: POSITION;
#ifndef DISABLE_TEXCOORD0
	float2	texCoord0	: TEXCOORD0;
#endif
#ifndef DISABLE_TEXCOORD1
	float2	texCoord1	: TEXCOORD1;
#endif
};

DepthVertexOutput DepthVS(DepthVertexInput IN)
{
	DepthVertexOutput OUT;

#ifdef ENABLE_SKINNING
	{
		float4 weights = IN.blendWeights;
		float4 indices = IN.blendIndices;

		float3 pos = Skin(float4(IN.pos,1),indices,weights);
		OUT.hPos = mul(float4(pos,1),viewProj);
	}
#else 
	{
		OUT.hPos = mul(float4(IN.pos,1),worldViewProj);
	}
#endif

#ifndef DISABLE_TEXCOORD0
	OUT.texCoord0 = IN.texCoord0;
#endif
#ifndef DISABLE_TEXCOORD1
	OUT.texCoord1 = IN.texCoord1;
#endif
	return OUT;
}

float4 DepthPS(DepthVertexOutput IN): COLOR
{
	float2	texCoord0 = 0;
	float2	texCoord1 = 0;
	
	float4 result = float4(0, 0, 0, 1);
	
#ifndef DISABLE_TEXCOORD0
	texCoord0 = IN.texCoord0;
#endif

#ifndef DISABLE_TEXCOORD1
	texCoord1 = IN.texCoord1;
#endif
	
	if(Use_Diffuse_Texture1) {
		float4 texCol = ReadTexture(Diffuse_Texture1_Sampler,texCoord0,texCoord1,Diffuse_Texture1_use_Chan_2,
			Texture1_Use_MatX?Texture1_MatX:float2(1,0),
			Texture1_Use_MatY?Texture1_MatY:float2(0,1),
			Texture1_Use_MatZ?Texture1_MatZ:0,
			Texture1_Use_MatT?Texture1_MatT:0);
		
		result.a *= texCol.a;
	}
	
	return result;
}


//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------

technique standard
<
	string Script = "" 
	"Pass=p0;";
>
{
	pass p0
	<
		string Script="Draw=Geometry;"; 
		string TempPassContents = "CullMode = CCW; AlphaBlendEnable = false; BlendOp = Add; SrcBlend = One; DestBlend = One; VertexShader = compile vs_3_0 VShader(); PixelShader = compile ps_3_0 PShader(); ";
	>
	{
		CullMode = CW;

		AlphaBlendEnable = false;
		BlendOp = Add;
		SrcBlend = One;
		DestBlend = One;

		VertexShader = compile vs_3_0 VShader();

		PixelShader = compile ps_3_0 PShader();
	}
}

technique knock_out
<
	string Script = "" 
	"Pass=p0;";
>
{
	pass p0
	<
		string Script="Draw=Geometry;"; 
		string TempPassContents = "AlphaTestEnable=true; AlphaFunc=GREATEREQUAL; AlphaRef=192; CullMode = CCW; AlphaBlendEnable = false; BlendOp = Add; SrcBlend = One; DestBlend = One; VertexShader = compile vs_3_0 VShader(); PixelShader = compile ps_3_0 PShader(); ";
	>
	{
		CullMode = CW;

		AlphaBlendEnable = false;
		BlendOp = Add;
		SrcBlend = One;
		DestBlend = One;

		AlphaTestEnable=true;
		AlphaFunc=GREATEREQUAL;
		AlphaRef=<AlphaRef>;

		VertexShader = compile vs_3_0 VShader();

		PixelShader = compile ps_3_0 PShader();
	}
}


technique trans_add
<
	string Script = "" 
	"Pass=p0;";
>
{
	pass p0
	<
		string Script="Draw=Geometry;"; 
		string TempPassContents = "ZWriteEnable=false; CullMode = CCW; AlphaBlendEnable = true; BlendOp = Add; SrcBlend = One; DestBlend = One; AlphaTestEnable = true; AlphaRef = 1; AlphaFunc = GREATEREQUAL; VertexShader = compile vs_3_0 VShader(); PixelShader = compile ps_3_0 PShader(); ";
	>
	{
		ZWriteEnable=false; 
		CullMode = CW;

		AlphaBlendEnable = true;
		BlendOp = Add;
		SrcBlend = One;
		DestBlend = One;

		AlphaTestEnable = true;
		AlphaRef = <AlphaRef>;
		AlphaFunc = GREATEREQUAL;
		
		
		VertexShader = compile vs_3_0 VShader();

		PixelShader = compile ps_3_0 PShader();
	}
}

technique trans_subtract
<
	string Script = "" 
	"Pass=p0;";
>
{
	pass p0
	<
		string Script="Draw=Geometry;"; 
		string TempPassContents = "ZWriteEnable=false; CullMode = CCW; AlphaBlendEnable = true; BlendOp = RevSubtract; SrcBlend = One; DestBlend = One; AlphaTestEnable = true; AlphaRef = 1; AlphaFunc = GREATEREQUAL; VertexShader = compile vs_3_0 VShader(); PixelShader = compile ps_3_0 PShader(); ";
	>
	{
		CullMode = CW;

		AlphaBlendEnable = true;
		BlendOp = RevSubtract;
		SrcBlend = One;
		DestBlend = One;

		AlphaTestEnable = true;
		AlphaRef = <AlphaRef>;
		AlphaFunc = GREATEREQUAL;
		
		VertexShader = compile vs_3_0 VShader();

		PixelShader = compile ps_3_0 PShader();

	}
}

technique trans_blend
<
	string Script = "" 
	"Pass=p0;";
>
{
	pass p0
	<
		string Script="Draw=Geometry;"; 
		string TempPassContents = "ZWriteEnable=false; CullMode = CCW; AlphaBlendEnable = true; BlendOp = Add; SrcBlend = SrcAlpha; DestBlend = InvSrcAlpha; AlphaTestEnable = true; AlphaRef = 1; AlphaFunc = GREATEREQUAL; VertexShader = compile vs_3_0 VShader(); PixelShader = compile ps_3_0 PShader(); ";
	>
	{
		ZWriteEnable=false;
		CullMode = CW;

		AlphaBlendEnable = true;
		BlendOp = Add;
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;

		AlphaTestEnable = true;
		AlphaRef = <AlphaRef>;
		AlphaFunc = GREATEREQUAL;
		
		VertexShader = compile vs_3_0 VShader();

		PixelShader = compile ps_3_0 PShader();

	}
}

#ifndef DISABLE_GLOW
technique glow
<
	string Script = "" 
	"Pass=p0;";
>
{
	
	pass p0
	<
		string Script="Draw=Geometry;"; 
		string TempPassContents = "CullMode = CCW; ColorWriteEnable = 8; AlphaBlendEnable = false; BlendOp = Add; SrcBlend = One; DestBlend = One; VertexShader = compile vs_3_0 VShader(); PixelShader = compile ps_3_0 GlowPShader(); ";
	>
	{
		CullMode = CW;

		ColorWriteEnable = 8;
		AlphaBlendEnable = false;
		BlendOp = Add;
		SrcBlend = One;
		DestBlend = One;

		VertexShader = compile vs_3_0 VShader();

		PixelShader = compile ps_3_0 GlowPShader();
	}
}
#endif

technique depth
<
	string Script = "" 
	"Pass=p0;";
>
{
	 pass p0
     <
        string Script="Draw=Geometry;";
        string TempPassContents =
		"ColorWriteEnable = 0;"
        "CullMode = CCW;"
        "ZEnable = True;"
        "ZWriteEnable = True;"
		"AlphaBlendEnable = false;"
		"SrcBlend = One;"
		"DestBlend = Zero;"
		"AlphaTestEnable = true;" 
		"AlphaFunc = GREATEREQUAL;" 
		"AlphaRef = 192;"
        "VertexShader = compile vs_3_0 DepthVS();"
        "PixelShader  = compile ps_3_0 DepthPS();";
     >
     {
		ColorWriteEnable = 0;
        CullMode = CCW;
        ZEnable = True;
        ZWriteEnable = True;
		AlphaBlendEnable = false;
		SrcBlend = One;
		DestBlend = Zero;
		AlphaTestEnable=true;
		AlphaFunc=GREATEREQUAL;
		AlphaRef=192;
		VertexShader = compile vs_3_0 DepthVS();
		PixelShader  = compile ps_3_0 DepthPS();
     }
}

technique alphaMask
<
	string Script = "" 
	"Pass=p0;";
>
{
	pass p0
	<
		string Script="Draw=Geometry;"; 
		string TempPassContents = 
		"ZWriteEnable = false;"
		"CullMode = CCW;"
		"ColorWriteEnable = 8;"
		"AlphaBlendEnable = true;"
		"SrcBlend = One;"
		"DestBlend = One;"
		"VertexShader = compile vs_3_0 VShader();"
		"PixelShader = compile ps_3_0 AlphaMaskPShader();";
	>
	{
		CullMode = CW;
		ZWriteEnable = false;
		ColorWriteEnable = 8;
		AlphaBlendEnable = true;
		SrcBlend = One;
		DestBlend = One;
		VertexShader = compile vs_3_0 VShader();
		PixelShader = compile ps_3_0 AlphaMaskPShader();
	}
}

technique global_trans
<
	string Script = "" 
	"Pass=p0;";
>
{
	pass p0
	<
		string Script="Draw=Geometry;"; 
		string TempPassContents = 
		"CullMode = CCW;"
		"ZWriteEnable = false;"
		"DepthBias = -0.0001;"
		
		"AlphaBlendEnable = true;"
		"BlendOp = Add;"
		"SrcBlend = SrcAlpha;"
		"DestBlend = InvSrcAlpha;"
		
		"AlphaTestEnable = true;"
		"AlphaFunc = GREATEREQUAL;"
		"AlphaRef = 1;"
		
		"VertexShader = compile vs_3_0 VShader();"
		"PixelShader = compile ps_3_0 PShader();";
	>
	{
		CullMode = CW;
		ZWriteEnable = false;
		
		AlphaBlendEnable = true;
		BlendOp = Add;
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;

		AlphaTestEnable=true;
		AlphaFunc=GREATEREQUAL;
		AlphaRef=128;

		VertexShader = compile vs_3_0 VShader();
		PixelShader = compile ps_3_0 PShader();
	}
}

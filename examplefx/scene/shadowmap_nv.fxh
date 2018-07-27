/*********************************************************************NVMH3****
File:  $Id: //sw/devrel/SDK/MEDIA/HLSL/shadowMap.fxh#3 $

Copyright NVIDIA Corporation 2004
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THIS SOFTWARE IS PROVIDED
*AS IS* AND NVIDIA AND ITS SUPPLIERS DISCLAIM ALL WARRANTIES, EITHER EXPRESS
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL NVIDIA OR ITS SUPPLIERS
BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS,
BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS)
ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF NVIDIA HAS
BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

A few utility macros and functions for shadow mapping.
	See typical usage in effect files like shadRPortHW.fx and see notes below.

$Date: 2004/11/23 $
$Author: kbjorke $

******************************************************************************/

#ifndef _SHADOWMAP_FXH
#define _SHADOWMAP_FXH

#include "Quad.fxh"

//////////////////////////////////////////////
// CONSTANTS /////////////////////////////////
//////////////////////////////////////////////

// Some user-assignable macros -- define their values before including
//		"shadowMap.fxh" to override these defaults

#ifndef SHADOW_SIZE
#define SHADOW_SIZE 1024
#endif /* !SHADOW_SIZE */

// other formats include "D24X8_SHADOWMAP" and "D16_SHADOWMAP"
#ifndef SHADOW_FORMAT
#define SHADOW_FORMAT "D24S8_SHADOWMAP"
#endif /* SHADOW_FORMAT */

#ifndef MAX_SHADOW_BIAS
#ifdef _MAX_
	#define MAX_SHADOW_BIAS 1500.0
	#define MAX_SHADOW_INC 0.01
	#define MAX_SHADOW_DEF 1
#else
	#define MAX_SHADOW_BIAS 0.00015
	#define MAX_SHADOW_INC 0.00001
	#define MAX_SHADOW_DEF 0.0001
#endif
#endif /* !MAX_SHADOW_BIAS */

// Define BLACK_SHADOW_PASS before including "shadowMap.fxh" for a SLIGHTLY faster generation
//		of the "throwaway" RGB buffer created when generating depth maps
// #define BLACK_SHADOW_PASS

//////////////////////////////////////////////////////
//// VM FUNCTIONS ////////////////////////////////////
//////////////////////////////////////////////////////

// #define SHAD_BIT_DEPTH 16	/* only significant for DirectX8 */

float4x4 make_bias_mat(float BiasVal)
{
#ifdef _MAX_
	BiasVal = BiasVal/10000.0f;
#endif	
	float fTexWidth = SHADOW_SIZE;
	float fTexHeight = SHADOW_SIZE;
	float fZScale = 1.0; //dx9
	float fOffsetX = 0.5f + (0.5f / fTexWidth);
	float fOffsetY = 0.5f + (0.5f / fTexHeight);
	float4x4 result = float4x4(0.5f,     0.0f,     0.0f,      0.0f,
					0.0f,    -0.5f,     0.0f,      0.0f,
					0.0f,     0.0f,     fZScale,   0.0f,
					fOffsetX, fOffsetY, BiasVal,     1.0f );
	return result;
}

//////////////////////////////////////////////////////
// DECLARATION MACROS ////////////////////////////////
//////////////////////////////////////////////////////

//
// Create standard biasing tweakable slider, and create a
//		static global bias transofrm at the same time
// Typical usage: SHADOW_XFORMS("light0",L0ViewXf,L0ProjXf,L0VPXf)
//
#define DECLARE_SHADOW_BIAS float ShadBias < string UIWidget = "slider"; \
    float UIMin = -MAX_SHADOW_BIAS; float UIMax = MAX_SHADOW_BIAS; float UIStep = MAX_SHADOW_INC; \
    string UIName = "Shadow Bias"; > = MAX_SHADOW_DEF; \
static float4x4 ShadBiasXf = make_bias_mat(ShadBias);

//
// Declare standard setup for lamp transofrms using "frustrum."
// Typical usage: SHADOW_XFORMS("light0",L0ViewXf,L0ProjXf,L0VPXf)
//
#define DECLARE_SHADOW_XFORMS(LampName,LampView,LampProj,LampViewProj) \
	float4x4 LampView : View < string frustum = (LampName); >; \
	float4x4 LampProj : Projection < string frustum = (LampName); >; \
	static float4x4 LampViewProj = mul(LampView,LampProj);

//
// Declare standard square_sized shadow map targets.
// Typical use: DECLARE_SHADOW_MAPS(ColorShadMap,ColorShadSampler,ShadDepthTarget,ShadDepthSampler)
//
#define DECLARE_SHADOW_MAPS(CTex,CSamp,DTex,DSamp) \
texture CTex : RENDERCOLORTARGET < float2 Dimensions = {SHADOW_SIZE,SHADOW_SIZE}; \
    string Format = "X8R8G8B8" ; string UIWidget = "None"; >; \
sampler CSamp = sampler_state { texture = <CTex>; \
    AddressU  = CLAMP; AddressV = CLAMP; \
    MipFilter = NONE; MinFilter = LINEAR; MagFilter = LINEAR; }; \
texture DTex : RENDERDEPTHSTENCILTARGET < float2 Dimensions = {SHADOW_SIZE,SHADOW_SIZE}; \
    string format = (SHADOW_FORMAT); string UIWidget = "None"; >; \
sampler DSamp = sampler_state { texture = <DTex>; \
    AddressU  = CLAMP; AddressV = CLAMP; \
    MipFilter = NONE; MinFilter = LINEAR; MagFilter = LINEAR; };
    

#ifdef _MAX_    
	float4 mCamPos : WORLD_CAMERA_POSITION <string UIWidget="None";>;
#endif

/////////////////////////////////////////////////////////
// Structures ///////////////////////////////////////////
/////////////////////////////////////////////////////////

/* data from application vertex buffer */
struct ShadowAppData {
    float3 Position	: POSITION;
    float4 UV		: TEXCOORD0;	// provided for potential use
    float4 Normal	: NORMAL;		// ignored if BLACK_SHADOW_PASS

	float3 T : TANGENT; //in object space
	float3 B : BINORMAL; //in object space    
};

// Connector from vertex (no pixel shader needed) for simple shadow 
struct ShadowVertexOutput {
    float4 HPosition	: POSITION;
	float4 diff : COLOR0;
};

//
// Connector from vertex to pixel shader for typical usage. The
//		"LProj" member is the crucial one for shadow mapping.
//
struct ShadowingVertexOutput {
    float4 HPosition	: POSITION;
    float2 UV		: TEXCOORD0;
    float3 LightVec	: TEXCOORD1;
    float3 WNormal	: TEXCOORD2;
    float3 WView	: TEXCOORD3;
    float4 LProj	: TEXCOORD4;	// current position in light-projection space
    float4 LightVector : TEXCOORD5;
};

/////////////////////////////////////////////////////////
// Vertex Shaders ///////////////////////////////////////
/////////////////////////////////////////////////////////

//
// Use this vertex shader for GENERATING shadows. It needs to know some transforms
//		from your scene, pass them as uniform aguments in the technique like so:
//			VertexShader = compile vs_2_0 shadowGenVS(WorldXf,WorldITXf,ShadowViewProjXf);
// Note that a color is returned because DirectX requires you to render an RGB value in
//		addition to the depth map. If BLACK_SHADOW_PASS is defined this will just be black,
//		otherwise it will encode the object-space normal as a color, which can be useful
//		for debugging. Either way, no pixel shader is required for the shadow-generation pass.
//
ShadowVertexOutput shadowGenVS(ShadowAppData IN,
		uniform float4x4 WorldXform,
		uniform float4x4 WorldITXform,
		uniform float4x4 ShadowVPXform) {
    ShadowVertexOutput OUT = (ShadowVertexOutput)0;
    float4 Po = float4(IN.Position.xyz,(float)1.0);	// object coordinates
    float4 Pw = mul(Po,WorldXform);			// "P" in world coordinates
    float4 Pl = mul(Pw,ShadowVPXform);  // "P" in light coords
    OUT.HPosition = Pl; // screen clipspace coords
#ifndef BLACK_SHADOW_PASS
    // shading this just for amusement in the texture pane
    float4 N = mul(IN.Normal,WorldITXform); // world coords
    N = normalize(N);
    OUT.diff = 0.5 + 0.5 * N;
#else /* !BLACK_SHADOW_PASS */
    OUT.diff = float4(1,0,0,1);
#endif /* !BLACK_SHADOW_PASS */
    return OUT;
}

//
// A typical vertex shader for USING shadows. It needs to know some transforms
//		from your scene, pass them as uniform aguments in the technique like so:
//			VertexShader = compile vs_2_0
//						shadowUseVS(WorldXf,WorldITXf,WorldViewProjXf,
//								ShadowViewProjXf,ViewIXf,ShadBiasXf, LightPosition);
// Note that a color is returned because DirectX requires you to render an RGB value in
//		addition to the depth map. If BLACK_SHADOW_PASS is defined this will just be black,
//		otherwise it will encode the object-space normal as a color, which can be useful
//		for debugging. Either way, no pixel shader is required for the shadow-generation pass.
//
ShadowingVertexOutput shadowUseVS(ShadowAppData IN,
		uniform float4x4 WorldXform,
		uniform float4x4 WorldITXform,
		uniform float4x4 WVPXform,
		uniform float4x4 ShadowVPXform,
		uniform float4x4 ViewIXform,
		uniform float4x4 BiasXform,
		uniform float3 LightPosition) {
    ShadowingVertexOutput OUT = (ShadowingVertexOutput)0;
    OUT.WNormal = mul(IN.Normal,WorldITXform).xyz; // world coords
    float4 Po = float4(IN.Position.xyz,(float)1.0);	// "P" in object coordinates
    float4 Pw = mul(Po,WorldXform);			// "P" in world coordinates
    float4 Pl = mul(Pw,ShadowVPXform);  // "P" in light coords
//    OUT.LProj = Pl;							// ...for pixel-shader shadow calcs
	OUT.LProj = mul(Pl,BiasXform);				// bias to make texcoord
    //
#ifdef _MAX_
	OUT.WView = normalize(mCamPos.xyz - Pw.xyz);	// world coords
#else	    
	OUT.WView = normalize(ViewIXform[3].xyz - Pw.xyz);	
#endif

	float3x3 objToTangentSpace;
	objToTangentSpace[0] = IN.B;
	objToTangentSpace[1] = IN.T;
	objToTangentSpace[2] = IN.Normal;

	// transform normal from object space to tangent space and pass it as a color
	//OUT.Normal.xyz = 0.5 * mul(IN.Normal,objToTangentSpace) + 0.5.xxx;
	float3 dir = LightPosition - Pw.xyz;
	
   	float4 objectLightDir = mul(dir,WorldITXform);
   
	float4 vertnormLightVec = normalize(objectLightDir);
	// transform light vector from object space to tangent space and pass it as a color 
	OUT.LightVector.xyz = 0.5 * mul(objToTangentSpace,vertnormLightVec.xyz ) + 0.5.xxx;

    OUT.HPosition = mul(Po,WVPXform);	// screen clipspace coords
    OUT.UV = IN.UV.xy;							// pass-thru
    OUT.LightVec =  LightPosition - Pw.xyz;		// world coords
    return OUT;
}



#if 0

//
// TYPICAL USAGE: This code matches shadRPortHW.fx
//

/*********************************************************/
/*********** pixel shader ********************************/
/*********************************************************/

//
// Typical pixel shader that uses ShadowVertexOutput data -- all you need for the shadow
//		is one tex2Dproj() call!
//
// In this shader, when DEBUG_VIEW is defined, show the RGB portion of the
//		shadow pass, to verify that projection is correct

float4 useShadowPS(ShadowingVertexOutput IN) : COLOR
{
#ifdef DEBUG_VIEW
    return tex2Dproj(ColorShadSampler,IN.LProj);	// show the RGB render instead
#else /*!DEBUG_VIEW */
    //
    // shading...
    //
   float3 Nn = normalize(IN.WNormal);
    float3 Vn = normalize(IN.WView);
    float falloff = 1.0 / dot(IN.LightVec,IN.LightVec);
    float3 Ln = normalize(IN.LightVec);
    float3 Hn = normalize(Vn + Ln);
    float hdn = dot(Hn,Nn);
    float ldn = dot(Ln,Nn);
    float4 litVec = lit(ldn,hdn,SpecExpon);
    ldn = litVec.y * SpotLightIntensity;
    float cone = normalize(IN.LProj.xyz).z;
    cone = max((float)0,((cone-CosSpotAng)/(((float)1.0)-CosSpotAng)));
    float3 ambiContrib = SurfColor * AmbiLightColor;
    float3 diffContrib = SurfColor*(Kd*ldn * SpotLightColor);
    float3 specContrib = ((ldn * litVec.z * Ks) * SpotLightColor);
    float3 result = diffContrib + specContrib;
    //
    // shadowing.....
    //
    float4 shadowed = tex2Dproj(ShadDepthSampler,IN.LProj);
    return float4((cone*falloff*result * 0.5)+ambiContrib,1);
    
#endif /*!DEBUG_VIEW */
}

////////////////////////////////////////////////////////////////////
/// TECHNIQUES /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

technique Main <
	string Script = "Pass=MakeShadow;"
					"Pass=UseShadow;";
> {
	pass MakeShadow <
		string Script = "RenderColorTarget0=ColorShadMap;"
						"RenderDepthStencilTarget=ShadDepthTarget;"
						"RenderPort=light0;"
						"ClearSetColor=ShadowClearColor;"
						"ClearSetDepth=ClearDepth;"
						"Clear=Color;"
						"Clear=Depth;"
						"Draw=geometry;";
	> {
		VertexShader = compile vs_2_0 shadCamVS();
		ZEnable = true;
		ZWriteEnable = true;
		ZFunc = LessEqual;
		CullMode = None;
		// no pixel shader
	}
	pass UseShadow <
		string Script = "RenderColorTarget0=;"
						"RenderDepthStencilTarget=;"
						"RenderPort=;"
						"ClearSetColor=ClearColor;"
						"ClearSetDepth=ClearDepth;"
						"Clear=Color;"
						"Clear=Depth;"
						"ScriptSignature=Env;"
						"ScriptExternal=ShadDepthTarget;"						
						"Draw=geometry;";
	> {
		VertexShader = compile vs_2_0 mainCamVS();
		ZEnable = true;
		ZWriteEnable = true;
		ZFunc = LessEqual;
		CullMode = None;
		PixelShader = compile ps_2_a useShadowPS();
	}
}

#endif /* ZERO */

#endif /* _SHADOWMAP_FXH */

/***************************** eof ***/

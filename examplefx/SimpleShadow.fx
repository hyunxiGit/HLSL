/*********************************************************************NVMH3****
File:  $Id: //sw/devtools/FXComposer/1.6/SDK/MEDIA/HLSL/shadRPortHW.fx#2 $

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

Simple shadow map example using FP16 textures and render ports.
Plastic-style shading with quadratic light falloff.

$Date: 2004/12/06 $
$Author: kbjorke $

******************************************************************************/

#include "scene\shadowMap_nv.fxh"
// when DEBUG_VIEW is defined, texture using the RGB portion of the
//		shadow pass, to verify that projection is correct
//#define DEBUG_VIEW


string ParamID = "0x003";

// added these to help with the simple scene parser example
bool CubeMap = false;
bool ShadowMap = true;


/************* "UN-TWEAKABLES," TRACKED BY CPU APPLICATION **************/

float4x4 WorldITXf : WorldTranspose <string UIWidget="None";>;
float4x4 WorldViewProjXf : WorldViewProjection <string UIWidget="None";>;
float4x4 WorldXf : World <string UIWidget="None";>;
float4x4 ViewIXf : ViewInverse <string UIWidget="None";>;
float4x4 ViewITXf : ViewInverseTranspose <string UIWidget="None";>;



DECLARE_SHADOW_XFORMS("SpotLightPos",LampViewXf,LampProjXf,ShadowViewProjXf)
DECLARE_SHADOW_BIAS
DECLARE_SHADOW_MAPS(ColorShadMap,ColorShadSampler,SceneMap,ShadDepthSampler)

///////////////////////////////////////////////////////////////
/// TWEAKABLES ////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

////////////////////////////////////////////// spot light

float3 SpotLightPos : POSITION <
	string UIName = "Light Position";
	string Object = "PointLight";
	string Space = "World";
> = {-1.0f, 1.0f, 0.0f};

float3 SpotLightColor : Diffuse <
	string UIName = "Lamp";
	string UIWidget = "Color";
> = {1.0f, 1.0f, 1.0f};

float SpotLightIntensity <
	string UIName = "Light Intensity";
	string UIWidget = "slider";
	float UIMin = 0.0;
	float UIMax = 12;
	float UIStep = 0.1;
> = 1;

float SpotLightCone <
    string UIWidget = "slider";
    float UIMin = 0.0;
    float UIMax = 90.5;
    float UIStep = 0.1;
    string UIName = "Cone Angle";
> = 45.0f;
static float CosSpotAng = cos(radians(SpotLightCone));

////////////////////////////////////////////// ambient light

float3 AmbiLightColor : Ambient
<
    string UIName = "Ambient";
> = {0.07f, 0.07f, 0.07f};

////////////////////////////////////////////// surface attributes

float3 SurfColor : Diffuse
<
    string UIName = "Surface";
    string UIWidget = "Color";
> = {1.0f, 0.7f, 0.3f};

float Kd
<
    float UIMin = 0.0;
    float UIMax = 1.5;
    float UIStep = 0.01;
    string UIName = "Diffuse";
> = 1.0;

float Ks
<
    float UIMin = 0.0;
    float UIMax = 1.5;
    float UIStep = 0.01;
    string UIName = "Specular";
> = 1.0;


float SpecExpon : SpecularPower
<
    float UIMin = 1.0;
    float UIMax = 128.0;
    float UIStep = 1.0;
    string UIName = "Specular power";
> = 12.0;

texture diffuseTexture : Diffuse< 
	string name = "seafloor.dds"; 
	string UIName = "Diffuse Texture";
	int Texcoord = 0;
	int MapChannel = 1;		
	
	>;
	
texture normalMap : Normal< 
	string name = "NMP_Ripples2_512.dds"; 
	string UIName = "Normal Texture";

	>;
	
	
sampler2D DiffuseMap = sampler_state
{
	Texture = <diffuseTexture>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};


sampler2D NormalMap = sampler_state
{
	Texture = <normalMap>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};	

////////////////////////////////////////////////////////////////////////////
/// SHADER CODE BEGINS /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

/*********************************************************/
/*********** pixel shader ********************************/
/*********************************************************/


float4 useShadowPS(ShadowingVertexOutput IN) : COLOR
{
#ifdef DEBUG_VIEW
    return tex2Dproj(ColorShadSampler,IN.LProj);	// show the RGB render instead
#else /*!DEBUG_VIEW */
    //
    // shading...
    //
   	float4 color = tex2D(DiffuseMap,IN.UV );
   	float4 bumpNormal = (2 * (tex2D(NormalMap,IN.UV)-0.5)) * 1.5;
   	
// 	SurfColor = SurfColor;
    float3 Nn = normalize(IN.WNormal);
    float3 Vn = normalize(IN.WView);
    
//    Nn = normalize(bumpNormal.xyz);
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
    
	//simple normal maps

	//expand iterated light vector to [-1,1]
	float3 lightVector = 2 * (IN.LightVector - 0.5 );
	lightVector = normalize(lightVector);

	//compute final color (diffuse + ambient)
	float4 bump = dot(bumpNormal.xyz,lightVector.xyz);
	float4 dif = (color *bump) + 0.1 ;    
	
    //
    // shadowing.....
    //
    float4 shadowed = tex2Dproj(ShadDepthSampler,IN.LProj);
	  return float4((1.0f * cone *  shadowed *result)+ambiContrib,1);
	//return float4((cone * shadowed *dif)+ambiContrib,1);


#endif /*!DEBUG_VIEW */

}

////////////////////////////////////////////////////////////////////
/// TECHNIQUES /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

technique Main <
				string Script = 
				"ScriptSignature=Env;"
				"ScriptExternal=SceneMap;"						
				"Pass=UseShadow;";
> {
	pass UseShadow <
		string Script = 				
						"Draw=geometry;";
	> {
		VertexShader = compile vs_2_0 shadowUseVS(WorldXf,WorldITXf, WorldViewProjXf,
								mul(LampViewXf,LampProjXf),ViewIXf,ShadBiasXf, SpotLightPos);
		ZEnable = true;
		ZWriteEnable = true;
		ZFunc = LessEqual;
		CullMode = None;
		PixelShader = compile ps_2_a useShadowPS();
	}
}

technique ShadowPass 
{
	pass MakeShadow 
	{
		VertexShader = compile vs_2_0 shadowGenVS(WorldXf,WorldITXf,mul(LampViewXf,LampProjXf));
		ZEnable = true;
		ZWriteEnable = true;
		ZFunc = LessEqual;
		CullMode = None;
		// no pixel shader
	}
}

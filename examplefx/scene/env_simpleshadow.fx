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
#include "shadowMap_nv.fxh"
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



////////////////////////////////////////////////////////////////////
/// TECHNIQUES /////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

technique Main <
		string Script =
				"RenderColorTarget0=ColorShadMap;"
				"RenderDepthStencilTarget=SceneMap;"
				"RenderPort=SpotLightPos;"
		        "Pass=MakeShadow;";

> {
	pass MakeShadow <
		string Script = "Draw=geometry;";
	> 
	{
		VertexShader = compile vs_2_0 shadowGenVS(WorldXf,WorldITXf,mul(LampViewXf,LampProjXf));
		ZEnable = true;
		ZWriteEnable = true;
		ZFunc = LessEqual;
		CullMode = None;
		// no pixel shader
	}
}




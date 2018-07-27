/*********************************************************************NVMH3****
File:  $Id: //sw/devtools/FXComposer/1.6/SDK/MEDIA/HLSL/pre_cubeBg.fx#2 $

Copyright NVIDIA Corporation 2002
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THIS SOFTWARE IS PROVIDED
*AS IS* AND NVIDIA AND ITS SUPPLIERS DISCLAIM ALL WARRANTIES, EITHER EXPRESS
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL NVIDIA OR ITS SUPPLIERS
BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS,
BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS)
ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF NVIDIA HAS
BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.


Comments:
    Put a 3D texture *behind* the current scene

******************************************************************************/
#ifdef _MAX_
string ParamID = "0x003";
#endif

float Script : STANDARDSGLOBAL <
	string UIWidget = "none";
	string ScriptClass = "scene";
	string ScriptOrder = "preprocess";
	string ScriptOutput = "color";
	string Script = "Technique=CubeMap;";
> = 0.8; // version #

///////// Textures ///////////////

///////// Textures ///////////////

texture BgTexture
<
    string UIName = "CubeMap";	
    string ResourceName = "sunol_cubemap.dds";
    string ResourceType = "CUBE";
>;

samplerCUBE BgSampler = sampler_state
{
    Texture = <BgTexture>;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = Point;
    AddressU = CLAMP;
    AddressV = CLAMP;
    AddressW = CLAMP;
};

float BgIntensity <
	string UIName = "Bkgd Intensity";
	string UIWidget = "slider";
	float UIMin = 0.0;
	float UIMax = 1.0;
	float UIStep = 0.01;
> = 1.0f;


//////////////////////////////////////////

#include "Quad.fxh"

float4x4 WorldViewI : WORLDVIEWINVERSE <string UIWidget="None";>;

//////////////////////////

struct CubeVertexOutput
{
   	float4 Position	: POSITION;
    float3 UV		: TEXCOORD0;
};

CubeVertexOutput CubeVS(
		float3 Position : POSITION, 
		float3 TexCoord : TEXCOORD0
) 
{
    CubeVertexOutput OUT;
	OUT.Position = float4(Position.xyz, 1);
	OUT.UV = mul(float4(Position.xyz,0.0f),WorldViewI).xzy; 
	return OUT;
}


float4 CubePS(CubeVertexOutput IN) : COLOR
{   
	float4 texCol = BgIntensity*texCUBE(BgSampler, IN.UV);
	return texCol;
}  

///////////////////////////////////

technique CubeMap 
<	
	string Script = "Pass=Bg;";
>
{
	pass Bg 
	<
	    	string Script = "Draw=Buffer;";	
	>
	{
		VertexShader = compile vs_2_0 CubeVS();
		cullmode = none;
		ZEnable = false;
		PixelShader  = compile ps_2_0 CubePS();
	}
}

/***************************** eof ***/

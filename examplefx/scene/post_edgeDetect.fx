/*********************************************************************NVMH3****
File:  $Id: //sw/devtools/SDK8.5/SDK/MEDIA/HLSL/post_edgeDetect2.fx#1 $

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

Same as scene_edgeDetect, but with the kernel values "hand-cooked" for
	efficiency

******************************************************************************/
string ParamID = "0x003";
float Script : STANDARDSGLOBAL <
	string UIWidget = "none";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
	string ScriptOutput = "color";
	string Script = "Technique=Main;";
> = 0.8; // version #


#include "Quad.fxh"

float NPixels <
    string UIName = "Pixels Steps";
    string UIWidget = "slider";
    float UIMin = 1.0f;
    float UIMax = 5.0f;
    float UIStep = 0.01f;
> = 1.5f;

float Threshhold
<
	string UIName = "Threshold";
    string UIWidget = "slider";
    float UIMin = 0.01f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 0.2;

///////////////////////////////////////////////////////////
///////////////////////////// Render-to-Texture Data //////
///////////////////////////////////////////////////////////

DECLARE_QUAD_TEX(SceneMap,SceneSampler,"X8R8G8B8")
DECLARE_QUAD_DEPTH_BUFFER(DepthBuffer, "D24S8")

// QUAD_REAL Time : TIME <string UIWidget="None";>;

//////////////////////////// struct ///

struct EdgeVertexOutput
{
   	QUAD_REAL4 Position	: POSITION;
    QUAD_REAL2 UV00		: TEXCOORD0;
    QUAD_REAL2 UV01		: TEXCOORD1;
    QUAD_REAL2 UV02		: TEXCOORD2;
    QUAD_REAL2 UV10		: TEXCOORD3;
    QUAD_REAL2 UV12		: TEXCOORD4;
    QUAD_REAL2 UV20		: TEXCOORD5;
    QUAD_REAL2 UV21		: TEXCOORD6;
    QUAD_REAL2 UV22		: TEXCOORD7;
};

EdgeVertexOutput edgeVS(
		QUAD_REAL3 Position : POSITION, 
		QUAD_REAL3 TexCoord : TEXCOORD0
) {
    EdgeVertexOutput OUT;
    OUT.Position = QUAD_REAL4(Position, 1);
	QUAD_REAL2 off = QUAD_REAL2(QuadTexOffset/(QuadScreenSize.x),QuadTexOffset/(QuadScreenSize.y));
    QUAD_REAL2 ctr = QUAD_REAL2(TexCoord.xy+off); 
	QUAD_REAL2 ox = QUAD_REAL2(NPixels/QuadScreenSize.x,0.0);
	QUAD_REAL2 oy = QUAD_REAL2(0.0,NPixels/QuadScreenSize.y);
	OUT.UV00 = ctr - ox - oy;
	OUT.UV01 = ctr - oy;
	OUT.UV02 = ctr + ox - oy;
	OUT.UV10 = ctr - ox;
	OUT.UV12 = ctr + ox;
	OUT.UV20 = ctr - ox + oy;
	OUT.UV21 = ctr + oy;
	OUT.UV22 = ctr + ox + oy;
    return OUT;
}

//////////////////////////////////////////////////////
////////////////////////////////// pixel shader //////
//////////////////////////////////////////////////////

QUAD_REAL getGray(QUAD_REAL4 c)
{
    return(dot(c.rgb,((0.33333).xxx)));
}

QUAD_REAL4 edgeDetectPS(EdgeVertexOutput IN,
	uniform sampler2D ColorMap,
	uniform QUAD_REAL T2
) : COLOR {
	QUAD_REAL4 CC;
	CC = tex2D(ColorMap,IN.UV00); QUAD_REAL g00 = getGray(CC);
	CC = tex2D(ColorMap,IN.UV01); QUAD_REAL g01 = getGray(CC);
	CC = tex2D(ColorMap,IN.UV02); QUAD_REAL g02 = getGray(CC);
	CC = tex2D(ColorMap,IN.UV10); QUAD_REAL g10 = getGray(CC);
	CC = tex2D(ColorMap,IN.UV12); QUAD_REAL g12 = getGray(CC);
	CC = tex2D(ColorMap,IN.UV20); QUAD_REAL g20 = getGray(CC);
	CC = tex2D(ColorMap,IN.UV21); QUAD_REAL g21 = getGray(CC);
	CC = tex2D(ColorMap,IN.UV22); QUAD_REAL g22 = getGray(CC);
	QUAD_REAL sx = 0;
	sx -= g00;
	sx -= g01 * 2;
	sx -= g02;
	sx += g20;
	sx += g21 * 2;
	sx += g22;
	QUAD_REAL sy = 0;
	sy -= g00;
	sy += g02;
	sy -= g10 * 2;
	sy += g12 * 2;
	sy -= g20;
	sy += g22;
	QUAD_REAL dist = (sx*sx+sy*sy);
	QUAD_REAL result = 1;
	if (dist>T2) { result = 0; }
	return result.xxxx;
}

////////////////////////////////////////////////////////////
/////////////////////////////////////// techniques /////////
////////////////////////////////////////////////////////////

technique Main <
	string Script =
		"RenderColorTarget0=SceneMap;"
		"RenderDepthStencilTarget=DepthTex;"
		"ScriptExternal=color;"
		"Pass=dpass;";
> {
    pass dpass  <
		string Script =
			"RenderColorTarget0=;"
			"RenderDepthStencilTarget=;"
			"Draw=Buffer;";
	> {		cullmode = none;
		ZEnable = false;
		ZWriteEnable = false;
		AlphaBlendEnable = false;
		VertexShader = compile vs_1_1 edgeVS();
		PixelShader = compile ps_2_0 edgeDetectPS(SceneSampler,(Threshhold*Threshhold));
    }
}

////////////// eof ///

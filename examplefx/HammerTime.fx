/*********************************************************************NVMH3****
File:  $Id: //sw/devrel/SDK/MEDIA/HLSL/HammerTime.fx#9 $

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
    Render-to-Texture (RTT) glow example.
    Blurs is done in two separable passes.
    We can apply 9x9 or 5x5 blurs.

    Not made for EffectEdit.

******************************************************************************/

///////////////////////////////////////////////////////////
/////////////////////////////////////// Tweakables ////////
///////////////////////////////////////////////////////////

#define DCC_MAX

string ParamID = "0x000001";
float4 ClearColor : DIFFUSE = {0,0,0,1.0};
float ClearDepth
<
	string UIWidget = "none";
> = 1.0;

float Script : STANDARDSGLOBAL
<
	string UIWidget = "none";
	string ScriptClass = "object";
	string ScriptOrder = "postprocess";
	string ScriptOutput = "color";
	
	// We just call a script in the main technique.
	string Script = "Technique=GlowQuality?Glow_9Tap:Glow_5Tap;";

> = 0.8;

float3 baseColor : DIFFUSE
<
	string UIWidget = "Color";
> = {1.0f, 0.6f, 0.2f};

float fIntensity <
	string UIName = "Base Incand Strength";
	string UIWidget = "slider";
	float UIMin = 0.0;
	float UIMax = 30.0;
	float UIStep = 0.01;
> = 1.0f;

float Glowness <
    string UIName = "Glow Strength";
	string UIWidget = "slider";
	float UIMin = 0.0;
	float UIMax = 30.0;
	float UIStep = 0.01;
> = 3.0f;

// file texture (surface)

texture ModelTex : DIFFUSE
<
	string ResourceName="glowtest.dds";
	string UIName = "Glow Texture";
	
>;

sampler ModelTexSamp = sampler_state 
{
    texture = <ModelTex>;
    AddressU  = WRAP;        
    AddressV  = WRAP;
    AddressW  = WRAP;
    MIPFILTER = LINEAR;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

///////////////////////////////////////////////////////////
/////////////////////////////////////// Un-Tweakables /////
///////////////////////////////////////////////////////////

float4x4 WvpXf : WorldViewProjection < string UIWidget="None"; >;

///////////////////////////////////////////////////////////
///////////////////////////// Render-to-Texture Data //////
///////////////////////////////////////////////////////////

#define RTT_SIZE 128

float TexelIncrement <
    string UIName = "Texel Stride for Blur";
    string UIWidget = "None";
> = 1.0f / RTT_SIZE;

texture GlowMap1 : RENDERCOLORTARGET < 
	float2 Dimensions = { RTT_SIZE, RTT_SIZE };
    int MIPLEVELS = 1;
    string format = "X8R8G8B8";
    string UIWidget = "None";
>;

sampler GlowSamp1 = sampler_state 
{
    texture = <GlowMap1>;
    AddressU  = CLAMP;        
    AddressV  = CLAMP;
    AddressW  = CLAMP;
    MIPFILTER = NONE;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

texture GlowMap2 : RENDERCOLORTARGET < 
	float2 Dimensions = { RTT_SIZE, RTT_SIZE };
    int MIPLEVELS = 1;
    string format = "X8R8G8B8";
    string UIWidget = "None";
>;

sampler GlowSamp2 = sampler_state 
{
    texture = <GlowMap2>;
    AddressU  = CLAMP;        
    AddressV  = CLAMP;
    AddressW  = CLAMP;
    MIPFILTER = NONE;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

texture DepthBuffer : RENDERDEPTHSTENCILTARGET
<
	float2 Dimensions = { RTT_SIZE, RTT_SIZE };
    string format = "D24S8";
    string UIWidget = "None";
>;
///////////////////////////////////////////////////////////
/////////////////////////////////// data structures ///////
///////////////////////////////////////////////////////////

struct VS_OUTPUT_BLUR
{
    float4 Position   : POSITION;
    float4 Diffuse    : COLOR0;
    float4 TexCoord0   : TEXCOORD0;
    float4 TexCoord1   : TEXCOORD1;
    float4 TexCoord2   : TEXCOORD2;
    float4 TexCoord3   : TEXCOORD3;
    float4 TexCoord4   : TEXCOORD4;
    float4 TexCoord5   : TEXCOORD5;
    float4 TexCoord6   : TEXCOORD6;
    float4 TexCoord7   : TEXCOORD7;
    float4 TexCoord8   : COLOR1;   
};

struct VS_OUTPUT
{
   	float4 Position   : POSITION;
    float4 Diffuse    : COLOR0;
    float4 TexCoord0   : TEXCOORD0;
};

////////////////////////////////////////////////////////////
////////////////////////////////// vertex shaders //////////
////////////////////////////////////////////////////////////

VS_OUTPUT VS(float3 Position : POSITION, 
			float3 Normal : NORMAL,
			float3 TexCoord : TEXCOORD0)
{
    VS_OUTPUT OUT = (VS_OUTPUT)0;
    OUT.Position = mul(float4(Position, 1), WvpXf); 
    OUT.Diffuse = float4(baseColor,1);
    OUT.TexCoord0 = float4(TexCoord, 1);
    return OUT;
}

VS_OUTPUT VS_Quad(float3 Position : POSITION, 
			float3 TexCoord : TEXCOORD0)
{
    VS_OUTPUT OUT = (VS_OUTPUT)0;
    OUT.Position = float4(Position, 1);
    OUT.TexCoord0 = float4(TexCoord, 1); 
    return OUT;
}

VS_OUTPUT_BLUR VS_Quad_Vertical_9tap(float3 Position : POSITION, 
			float3 TexCoord : TEXCOORD0)
{
    VS_OUTPUT_BLUR OUT = (VS_OUTPUT_BLUR)0;
    OUT.Position = float4(Position, 1);
    
    float3 Coord = float3(TexCoord.x + TexelIncrement, TexCoord.y + TexelIncrement, 1);
    OUT.TexCoord0 = float4(Coord.x, Coord.y + TexelIncrement, TexCoord.z, 1);
    OUT.TexCoord1 = float4(Coord.x, Coord.y + TexelIncrement * 2, TexCoord.z, 1);
    OUT.TexCoord2 = float4(Coord.x, Coord.y + TexelIncrement * 3, TexCoord.z, 1);
    OUT.TexCoord3 = float4(Coord.x, Coord.y + TexelIncrement * 4, TexCoord.z, 1);
    OUT.TexCoord4 = float4(Coord.x, Coord.y, TexCoord.z, 1);
    OUT.TexCoord5 = float4(Coord.x, Coord.y - TexelIncrement, TexCoord.z, 1);
    OUT.TexCoord6 = float4(Coord.x, Coord.y - TexelIncrement * 2, TexCoord.z, 1);
    OUT.TexCoord7 = float4(Coord.x, Coord.y - TexelIncrement * 3, TexCoord.z, 1);
    OUT.TexCoord8 = float4(Coord.x, Coord.y - TexelIncrement * 4, TexCoord.z, 1);
    return OUT;
}

VS_OUTPUT_BLUR VS_Quad_Horizontal_9tap(float3 Position : POSITION, 
			float3 TexCoord : TEXCOORD0)
{
    VS_OUTPUT_BLUR OUT = (VS_OUTPUT_BLUR)0;
    OUT.Position = float4(Position, 1);
    
    float3 Coord = float3(TexCoord.x + TexelIncrement, TexCoord.y + TexelIncrement, 1);
    OUT.TexCoord0 = float4(Coord.x + TexelIncrement, Coord.y, TexCoord.z, 1);
    OUT.TexCoord1 = float4(Coord.x + TexelIncrement * 2, Coord.y, TexCoord.z, 1);
    OUT.TexCoord2 = float4(Coord.x + TexelIncrement * 3, Coord.y, TexCoord.z, 1);
    OUT.TexCoord3 = float4(Coord.x + TexelIncrement * 4, Coord.y, TexCoord.z, 1);
    OUT.TexCoord4 = float4(Coord.x, Coord.y, TexCoord.z, 1);
    OUT.TexCoord5 = float4(Coord.x - TexelIncrement, Coord.y, TexCoord.z, 1);
    OUT.TexCoord6 = float4(Coord.x - TexelIncrement * 2, Coord.y, TexCoord.z, 1);
    OUT.TexCoord7 = float4(Coord.x - TexelIncrement * 3, Coord.y, TexCoord.z, 1);
    OUT.TexCoord8 = float4(Coord.x - TexelIncrement * 4, Coord.y, TexCoord.z, 1);
    return OUT;
}

VS_OUTPUT_BLUR VS_Quad_Vertical_5tap(float3 Position : POSITION, 
			float3 TexCoord : TEXCOORD0)
{
    VS_OUTPUT_BLUR OUT = (VS_OUTPUT_BLUR)0;
    OUT.Position = float4(Position, 1);
    
    float3 Coord = float3(TexCoord.x + TexelIncrement, TexCoord.y + TexelIncrement, 1);
    OUT.TexCoord0 = float4(Coord.x, Coord.y + TexelIncrement, TexCoord.z, 1);
    OUT.TexCoord1 = float4(Coord.x, Coord.y + TexelIncrement * 2, TexCoord.z, 1);
    OUT.TexCoord2 = float4(Coord.x, Coord.y, TexCoord.z, 1);
    OUT.TexCoord3 = float4(Coord.x, Coord.y - TexelIncrement, TexCoord.z, 1);
    OUT.TexCoord4 = float4(Coord.x, Coord.y - TexelIncrement * 2, TexCoord.z, 1);
    return OUT;
}

VS_OUTPUT_BLUR VS_Quad_Horizontal_5tap(float3 Position : POSITION, 
			float3 TexCoord : TEXCOORD0)
{
    VS_OUTPUT_BLUR OUT = (VS_OUTPUT_BLUR)0;
    OUT.Position = float4(Position, 1);
    
    float3 Coord = float3(TexCoord.x + TexelIncrement, TexCoord.y + TexelIncrement, 1);
    OUT.TexCoord0 = float4(Coord.x + TexelIncrement, Coord.y, TexCoord.z, 1);
    OUT.TexCoord1 = float4(Coord.x + TexelIncrement * 2, Coord.y, TexCoord.z, 1);
    OUT.TexCoord2 = float4(Coord.x, Coord.y, TexCoord.z, 1);
    OUT.TexCoord3 = float4(Coord.x - TexelIncrement, Coord.y, TexCoord.z, 1);
    OUT.TexCoord4 = float4(Coord.x - TexelIncrement * 2, Coord.y, TexCoord.z, 1);
    return OUT;
}

//////////////////////////////////////////////////////
////////////////////////////////// pixel shaders /////
//////////////////////////////////////////////////////

// just map the glow-mask texture to the screen - no lighting
// this shader will draw to a texture
float4 PS_BlurBuffer(VS_OUTPUT IN) : COLOR
{   
	float3 Col = IN.Diffuse * tex2D(ModelTexSamp, float2(IN.TexCoord0.xy)).xyz;
	Col *= fIntensity;
	return float4(Col,1);
}  

////////

// For two-pass blur, we have chosen to do  the horizontal blur FIRST. The
//	vertical pass includes a post-blur scale factor.

// Relative filter weights indexed by distance from "home" texel
//    This set for 9-texel sampling
#define WT9_0 1.0
#define WT9_1 0.8
#define WT9_2 0.6
#define WT9_3 0.4
#define WT9_4 0.2

// Alt pattern -- try your own!
// #define WT9_0 0.1
// #define WT9_1 0.2
// #define WT9_2 3.0
// #define WT9_3 1.0
// #define WT9_4 0.4

#define WT9_NORMALIZE (WT9_0+2.0*(WT9_1+WT9_2+WT9_3+WT9_4))

float4 PS_Blur_Horizontal_9tap(VS_OUTPUT_BLUR IN) : COLOR
{   
    float4 OutCol = tex2D(GlowSamp1, IN.TexCoord0) * (WT9_1/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord1) * (WT9_2/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord2) * (WT9_3/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord3) * (WT9_4/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord4) * (WT9_0/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord5) * (WT9_1/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord6) * (WT9_2/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord7) * (WT9_3/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord8) * (WT9_3/WT9_NORMALIZE);
    return OutCol;
} 

float4 PS_Blur_Vertical_9tap(VS_OUTPUT_BLUR IN) : COLOR
{   
    float4 OutCol = tex2D(GlowSamp2, IN.TexCoord0) * (WT9_1/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord1) * (WT9_2/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord2) * (WT9_3/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord3) * (WT9_4/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord4) * (WT9_0/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord5) * (WT9_1/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord6) * (WT9_2/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord7) * (WT9_3/WT9_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord8) * (WT9_3/WT9_NORMALIZE);
    return Glowness*OutCol;
} 

// Relative filter weights indexed by distance from "home" texel
//    This set for 5-texel sampling
#define WT5_0 1.0
#define WT5_1 0.8
#define WT5_2 0.4

#define WT5_NORMALIZE (WT5_0+2.0*(WT5_1+WT5_2))

float4 PS_Blur_Horizontal_5tap(VS_OUTPUT_BLUR IN) : COLOR
{   
    float4 OutCol = tex2D(GlowSamp1, IN.TexCoord0) * (WT5_1/WT5_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord1) * (WT5_2/WT5_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord2) * (WT5_0/WT5_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord3) * (WT5_1/WT5_NORMALIZE);
    OutCol += tex2D(GlowSamp1, IN.TexCoord4) * (WT5_2/WT5_NORMALIZE);
    return OutCol;
} 

float4 PS_Blur_Vertical_5tap(VS_OUTPUT_BLUR IN) : COLOR
{   
    float4 OutCol = tex2D(GlowSamp2, IN.TexCoord0) * (WT5_1/WT5_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord1) * (WT5_2/WT5_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord2) * (WT5_0/WT5_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord3) * (WT5_1/WT5_NORMALIZE);
    OutCol += tex2D(GlowSamp2, IN.TexCoord4) * (WT5_2/WT5_NORMALIZE);
    return Glowness*OutCol;
} 

////////

// just drawn model itself

float4 PS_Model(VS_OUTPUT IN) : COLOR
{   
	float4 Col = IN.Diffuse * tex2D(ModelTexSamp, float2(IN.TexCoord0.xy));
	return Col;
}  

// add glow on top of model

float4 PS_GlowPass(VS_OUTPUT IN) : COLOR
{   
	float4 tex = tex2D(GlowSamp1, float2(IN.TexCoord0.x, IN.TexCoord0.y));
	return tex;
}  

////////////////////////////////////////////////////////////
/////////////////////////////////////// techniques /////////
////////////////////////////////////////////////////////////

technique Glow_9Tap
<
	string Script =
			"ClearSetColor=ClearColor;"
			"ClearSetDepth=ClearDepth;"
			"Pass=BlurPass;"      	
	        	"Pass=BlurGlowBuffer_Horz;"
		        "Pass=BlurGlowBuffer_Vert;"
		        "Pass=ModelPass;"
		        "Pass=GlowPass;";
>	        
{
	pass BlurPass
	<
    	string Script = "RenderColorTarget0=GlowMap1;"
    				"Clear=Color;"
				"Clear=Depth;"
				"Draw=Geometry;";
	>
	{
		cullmode = none;
		ZEnable = true;	
        VertexShader = compile vs_1_1 VS();
        PixelShader = compile ps_2_0 PS_BlurBuffer();
	
	}

    pass BlurGlowBuffer_Horz 
    < 
    	string Script ="RenderColorTarget0=GlowMap2;"
    			"Clear=Color;"
			"Clear=Depth;"

    							"Draw=Buffer;";
    >
	{
		cullmode = none;
		ZEnable = false;
		VertexShader = compile vs_2_0 VS_Quad_Horizontal_9tap();
		PixelShader  = compile ps_2_0 PS_Blur_Horizontal_9tap();
    }
    pass BlurGlowBuffer_Vert 
     <
    	string Script = "RenderColorTarget0=GlowMap1;"
    			"Clear=Color;"
			"Clear=Depth;"
			"Draw=Buffer;";
    >
    {
		cullmode = none;
		ZEnable = false;
		VertexShader = compile vs_2_0 VS_Quad_Vertical_9tap();
		PixelShader  = compile ps_2_0 PS_Blur_Vertical_9tap();
    }
    pass ModelPass
    <
    	string Script= "RenderColorTarget0=;"
						"Draw=Geometry;";
	>
	{
	    ZEnable = true;
		ZWriteEnable = true;
		AlphaBlendEnable = false;
		AlphaTestEnable = false;
        VertexShader = compile vs_1_1 VS();
        PixelShader = compile ps_2_0 PS_Model();
	}
    pass GlowPass 
    <
       	string Script= "RenderColorTarget0=;"
	   							"Draw=Buffer;";        	
	>
    {
		cullmode = none;
		ZEnable = false;
		ZWriteEnable = false;
		AlphaBlendEnable = true;
		SrcBlend = one;
		DestBlend = one;
		VertexShader = compile vs_1_1 VS_Quad();
		PixelShader = compile ps_2_0 PS_GlowPass();	
    }
}

//////////////

technique Glow_5Tap
<
	string Script =
			"ClearSetColor=ClearColor;"
			"ClearSetDepth=ClearDepth;"
  			"Pass=BlurPass;"      	
        	"Pass=BlurGlowBuffer_Horz;"
	        "Pass=BlurGlowBuffer_Vert;"
	        "Pass=ModelPass;"
	        "Pass=GlowPass;";
>	 
{

	pass BlurPass
	<
    	string Script = "RenderColorTarget0=GlowMap1;"
    					"Draw=Geometry;";
	>
	{
		cullmode = none;
		ZEnable = true;	
        VertexShader = compile vs_1_1 VS();
        PixelShader = compile ps_2_0 PS_BlurBuffer();
	
	}
    pass BlurGlowBuffer_Horz 
    < 
    	string Script ="RenderColorTarget0=GlowMap2;"
    							"Draw=Buffer;";
    >
	{
		cullmode = none;
		ZEnable = false;
		VertexShader = compile vs_2_0 VS_Quad_Horizontal_5tap();
		PixelShader  = compile ps_2_0 PS_Blur_Horizontal_5tap();
    }
    pass BlurGlowBuffer_Vert 
     <
    	string Script = "RenderColorTarget0=GlowMap1;"
								"Draw=Buffer;";
    >
	{
		cullmode = none;
		ZEnable = false;
		VertexShader = compile vs_2_0 VS_Quad_Vertical_5tap();
		PixelShader  = compile ps_2_0 PS_Blur_Vertical_5tap();
    }
    pass ModelPass
    <
   	string Script= "RenderColorTarget0=;"
						"Draw=Geometry;";
    >
    
    {
		ZEnable = true;
		ZWriteEnable = true;
		AlphaBlendEnable = false;
		AlphaTestEnable = false;		
		VertexShader = compile vs_1_1 VS();
		PixelShader = compile ps_2_0 PS_Model();
    }
    pass GlowPass
    <
       	string Script= "RenderColorTarget0=;"
			"Draw=Buffer;";        	
	>
    {
		cullmode = none;
		ZEnable = false;
		ZWriteEnable = false;
		AlphaBlendEnable = true;
		SrcBlend = one;
		DestBlend = one;
		VertexShader = compile vs_1_1 VS_Quad();
		PixelShader = compile ps_2_0 PS_GlowPass();	
    }
}

//////////////

technique NoGlow
{
    pass ObjectRender
    {
		ZWriteEnable = true;
		AlphaBlendEnable = false;    
		AlphaTestEnable = false;
        VertexShader = compile vs_1_1 VS();
        PixelShader = compile ps_1_1 PS_Model();
    }
}

////////////// eof ///

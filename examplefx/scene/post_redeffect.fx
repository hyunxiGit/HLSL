
#include "quad.fxh"

string ParamID = "0x003";

float Script : STANDARDSGLOBAL
<
	string UIWidget = "none";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
	string ScriptOutput = "color";

> = 0.8;

DECLARE_QUAD_TEX(SceneMap,SceneSampler,"X8R8G8B8")
DECLARE_QUAD_TEX(EnvMap,EnvSampler,"X8R8G8B8")

struct VertexOutput
{
	float4 Position	: POSITION;
	float3 UV	: TEXCOORD0;
};

VertexOutput OutputVS(
	float3 Position : POSITION, 
	float3 Tex : TEXCOORD0 ) 
{
	VertexOutput OUT;
	OUT.Position = float4(Position.xyz, 1);
	OUT.UV = Tex;
	return OUT;
}



float4 OutputPS(VertexOutput IN) : COLOR
{   
	float4 texCol = float4(tex2D(SceneSampler, IN.UV).xyz,1);
	float4 redCol = float4(tex2D(EnvSampler, IN.UV).xyz,1);
	texCol = texCol * redCol;
	return texCol;
} 
///////////////////////////////////

technique Default
<
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
	string ScriptOutput = "color";
	string Script =
			"RenderColorTarget0=SceneMap;"
			"ScriptExternal=color;"			
			"ScriptSignature=Env;"
			"ScriptExternal=EnvMap;"
	        "Pass=p0;";
	        
>
{
	pass p0 
	<
    	string Script = "Draw=Buffer;";	
	>
	{
		VertexShader = compile vs_1_1 OutputVS();
		cullmode = none;
		ZEnable = false;
		PixelShader  = compile ps_2_0 OutputPS();
	}
}

/***************************** eof ***/

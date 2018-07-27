#include "quad.fxh"
#include "environment.fxh"

string ParamID = "0x003";
/*
float4x4 WorldViewProj : 	WORLDVIEWPROJ;

float4 TintColor <
	string UIName = "Tint Color";
> = {1,0,0,1};

DECLARE_QUAD_TEX(EnvMap,EnvSampler,"X8R8G8B8")

struct VS_OUTPUT
{
    float4 Pos  : POSITION;
    float4 col : COLOR0;
       
};

VS_OUTPUT VS(
    float3 Pos  : POSITION 
)
{
    VS_OUTPUT Out;


    Out.Pos  = mul(float4(Pos,1),WorldViewProj);    // position (projected)
    Out.col = TintColor;	
    Out.col.a = 1.0f;
    return Out;
}


technique RedTint
<
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
	string ScriptOutput = "color";
	string Script =
	    		"RenderColorTarget0=EnvMap;"
				"Pass=RedPass;";
>
{
	pass RedPass 
	<
	
    	string Script = 
    	"Draw=Geometry;";	
	>
	{
  
       VertexShader = compile vs_2_0 VS();
	}
}
*/
float Script : STANDARDSGLOBAL
<
	string UIWidget = "none";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
	string ScriptOutput = "color";
	string Script = "Technique=RedTint;";
> = 0.8;

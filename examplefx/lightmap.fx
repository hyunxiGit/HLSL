//////////////////////////////////////////////////
//simple light map shader with blend amount
//It uses map channel 1 for the diffuse and map channel 4 for the light, and is designed for RTT usage.
//Complete over kill, but simple to write..
//////////////////////////////////////////////////

float4x4 World      : 		WORLD;
float4x4 View       : 		VIEW;
float4x4 Projection : 		PROJECTION;
float4x4 WorldViewProj : 	WORLDVIEWPROJ;
float4x4 WorldView : 		WORLDVIEW;

// tweakables

texture diffuseTexture : DiffuseMap< 
	string UIName = "Diffuse Texture";
	int Texcoord = 0;
	int MapChannel = 1;	
>;
	
texture lightTexture : LightMap < 
	string UIName = "Lightmap Texture";
	int Texcoord = 1;
	int MapChannel = 4;	
>;

float  Mix<
	string UIName = "Light amount";
	string UIType = "MaxSpinner";
	float UIMin = 0.0f;
	float UIMax = 1.0f;	
	float UIStep = 0.01;
	>  = 1.0f;
	

struct VS_OUTPUT
{
	float4 oPos : POSITION;
	float2 oDiffuseTex :TEXCOORD0;
	float2 oLightTex : TEXCOORD1;
};



// very simple - we don't need lighting as it is provided by the lightmap.

VS_OUTPUT VS(
	float3 Pos  : POSITION, 
	float3 Norm : NORMAL, 
	float2 DiffuseTex  : TEXCOORD0,
	float2 LightTex : TEXCOORD1)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;


	Out.oDiffuseTex = DiffuseTex;	// diffuse 
	Out.oLightTex = LightTex; // lightmap
	
	// Note: please use WORLDVIEWPROJ instead of WORLDVIEW and PROJECTION to avoid z-fighting in 3ds Max
	Out.oPos = mul(float4(Pos,1),WorldViewProj); // position (projected)
	return Out;
   
}


sampler DiffuseSampler = sampler_state
{
    Texture   = (diffuseTexture);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};


sampler LightSampler = sampler_state
{
    Texture   = (lightTexture);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};



float4 PS(
    float2 DiffuseTex  : TEXCOORD0,
    float2 LightTex : TEXCOORD1) : COLOR
{

    float4 diff = tex2D(DiffuseSampler, DiffuseTex);
    float4 light = tex2D(LightSampler, LightTex);
    return diff * (light * Mix);	

}

technique LightMap
{
    pass P0
    {
    	CullMode = None;
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_1_1 PS();
    }  
}
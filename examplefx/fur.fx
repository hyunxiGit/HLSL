//------------------------------------
string ParamID = "0x0001";
int shellcount = 20;
int shellnumber;

float Script : STANDARDSGLOBAL
<
	string UIWidget = "none";
	string ScriptClass = "object";
	string ScriptOrder = "postprocess";
	string ScriptOutput = "color";
	
	// We just call a script in the main technique.
	string Script = "Technique=Fur;";

> = 0.8;

float FurDistance
<
    string UIWidget = "slider";
    float UIMin = 0.0;
    float UIMax = 10.0;
    float UIStep = 0.01;
    string UIName = "Fur Shell Distance";
> = .0085f;


float FurStrength
<
    string UIWidget = "slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
    float UIStep = 0.1;
    string UIName = "Fur Strength";
> = .3f;


texture NoiseMap 
< 
    string TextureType = "2D"; 
    string UIName = "Fur map";
    string ResourceName="test_noise.dds";
    //string function = "NoiseMaker"; 
    //string UIWidget = "None";
    int width = 256;
    int height = 256;
>;


float4x4 worldViewProj : WorldViewProjection;
float4 furColor : Diffuse
<
    string UIName = "Fur Color";
> = {.3f, 0.2f, 0.0f, 1.0f};

//------------------------------------
struct vertexInput {
    float3 position				: POSITION;
    float3 normal				: NORMAL;
    float4 texCoordDiffuse		: TEXCOORD0;
};

struct vertexOutput {
    float4 HPOS		: POSITION;
    float4 T0	: TEXCOORD0;
};

float4 NoiseMaker(float2 Pos : POSITION) : COLOR
{
    float noise0 = (abs(noise(Pos * 100)));
    float noise1 = noise0.x > 0.25 ? 1.0f : 0.0f;
    return float4(noise0, noise0, noise0, noise1);
}

//------------------------------------
vertexOutput VS_TransformAndTexture(vertexInput IN) 
{
    vertexOutput OUT;

	float3 P = IN.position.xyz + (IN.normal * (FurDistance * (float)shellnumber));
	
	OUT.T0 = IN.texCoordDiffuse;
	OUT.HPOS = mul(float4(P, 1.0f), worldViewProj);
    
    return OUT;
}

vertexOutput VS_TransformAndTextureSetup(vertexInput IN) 
{
    vertexOutput OUT;

	float3 P = IN.position.xyz;
	
	OUT.T0 = IN.texCoordDiffuse;
	OUT.HPOS = mul(float4(P, 1.0f), worldViewProj);
    
    return OUT;
}

//------------------------------------
sampler TextureSampler = sampler_state 
{
    texture = <NoiseMap>;
    AddressU  = WRAP;        
    AddressV  = WRAP;
    AddressW  = WRAP;
    MIPFILTER = LINEAR;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};


//-----------------------------------
float4 PS_Textured( vertexOutput IN): COLOR
{
  float4 diffuseTexture = tex2D( TextureSampler, IN.T0 );
  
  return (float4(furColor.xyz, FurStrength) * diffuseTexture);
}


//-----------------------------------
technique Fur
<
	string ScriptClass = "object";
	string ScriptOrder = "standard";
	string ScriptOutput = "color";
	string Script =	"Pass=Setup;"
        	"LoopByCount=shellcount;"
        	"LoopGetIndex=shellnumber;"
	        "Pass=Shell;"
	        "LoopEnd;";
>	        
{

    pass Setup
    <
    	string script="Draw=Geometry;";
    >
    {		
		VertexShader = compile vs_1_1 VS_TransformAndTextureSetup();
		PixelShader  = compile ps_1_1 PS_Textured();
		AlphaBlendEnable = true;
		SrcBlend = srcalpha;
		DestBlend = zero;

    }
    pass Shell
    <
    	string script="Draw=Geometry;";
    >
    {		
		VertexShader = compile vs_1_1 VS_TransformAndTexture();
		PixelShader  = compile ps_1_1 PS_Textured();
		AlphaBlendEnable = true;
		SrcBlend = srcalpha;
		DestBlend = one;

    }

}
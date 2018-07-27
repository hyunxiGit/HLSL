//////////////////////////////////////////////////////////////
//light calculate in tangent space use Matrix right multiply
//////////////////////////////////////////////////////////////


// first shader calculate in tangent space
float4x4 wvp : WorldViewProjection <string UIWidget = "None";>;
float4x4 world : WORLD;
float4x4 worldI : WorldI;
float3 view : VIEW;

//ui elements
texture color_texture < 
	string UIName = "Color Map";
	string ResourceType = "2D";
>;

texture normal_texture<
	string UIName = "Normal Map";
	string ResourceType = "2D";
>;

float3 lightDir : Direction<
	string UIName = "Light Direction";
	string Object = "TargetLight";
	int RefId = 0;
> = {-0.5f,-1.0f,1.0f};

float4 I_d : LIGHTCOLOR <
    string UIName = "Light Color";
    int LightRef = 0;
> = {1,1,1,1};

struct app2vertex
{
    float4 pos  :   POSITION;
    float2 uv   :   TEXCOORD0;
    float3 binormal : BINORMAL;
    float3 tangent : TANGENT;
    float3 normal : NORMAL;

    
};

struct vertex2pixel
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
    float3 lightTangent : TEXCOORD1;
};

sampler2D colorMapSampler = sampler_state
{
	Texture = <color_texture>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
    AddressV = Wrap;
};

sampler2D normalMapSampler = sampler_state
{
	Texture = <normal_texture>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
    AddressV = Wrap;
};

vertex2pixel vertex(app2vertex In)
{
    vertex2pixel Out = (vertex2pixel) 0;

    float3 L = lightDir;
    float3 N = In.normal;
    float3 B = In.binormal;
    float3 T = In.tangent;
    
    float3x3 MOT; // this matrix conver Tv to Ov
    MOT[0] = B;
    MOT[1] = T;
    MOT[2] = N;
        
    float3x3 MTO = transpose(MOT); // this matrix conver Ov to Tv

    //conv L to O space
    L = normalize(mul(L, (float3x3) worldI));
    
    //conv L to T space ,  can use either of these 2
    //Out.lightTangent = mul(L, MTO); //left mul
    Out.lightTangent = normalize(mul(MOT, L)); //right mul

    Out.pos = mul(In.pos, wvp);
    Out.uv = In.uv;

	return Out;
}

float4 pixel(vertex2pixel In)  :  COLOR
{
    float4 color = tex2D(colorMapSampler, In.uv);
    float4 normalMap = tex2D(normalMapSampler, In.uv);
    float3 L = normalize(In.lightTangent);
    float3 N = normalMap * 2 - 1;

    float4 col = max(dot(N, L),0);

    //col = dot(In.B, float3(1, 0, 0));
    
    return col;
}

technique AmbientLight
{
	pass simple
	{
		VertexShader = compile vs_2_0 vertex();
		ZEnable = true;
		ZWriteEnable = true;
		cullMode = cw;
		AlphaBlendEnable = false;
		PixelShader = compile ps_2_0 pixel();
	}
}
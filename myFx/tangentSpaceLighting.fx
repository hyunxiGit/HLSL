// first shader calculate in tangent space
float4x4 wvp : WorldViewProjection <string UIWidget = "None";>;
float4x4 world : WORLD;
float3 view : VIEW;
float time : TIME;

//ui elements
texture color_texture < 
	string UIName = "Color Map";
	string ResourceType = "2D";
>;

texture normal_texture<
	string UIName = "Normal Map";
	string ResourceType = "2D";
>;

float3 lightDir<
	string UIName = "Light Direction";
	string Object = "TargetLight";
	int RefId = 0;
> = {-0.5f,-1.0f,1.0f};

struct app2vertex
{
	float2 textCoord :TEXCOORD0;
	float3 position : POSITION;
	float4 normal	: NORMAL;
	float4 tangent	: TANGENT;
	float4 binormal	: BINORMAL;
};

struct vertex2pixel
{
	float4 position  :  POSITION;
	float4 color     :  COLOR;
	float2 textCoord :  TEXCOORD0;
	float3 normal    :  TEXCOORD1;
	float3 viewVec   :  TEXCOORD2;
	float3x3 worldToTangentMx : TEXCOORD3;
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
	//vertexshader Inflate
	float inflateScale = 0.1;

	In.position = In.position + inflateScale*In.normal;
	In.position.y = In.position.y + sin(50);
	
	vertex2pixel Out = (vertex2pixel)0;

	Out.normal = normalize(mul(In.normal, world)); 
	Out.position = mul(float4(In.position,1), wvp); // worl view projection matrix
	

	Out.textCoord = In.textCoord;

	float3x3 twMx;
	twMx[0] = normalize(mul(In.tangent,world));
	twMx[1] = normalize(mul(In.binormal,world));
	twMx[2] = Out.normal;
	Out . worldToTangentMx = transpose(twMx);

	//convert normal to tanget space
	Out.normal = float3(0,0,1);

	//convert view to tangent	
	Out.viewVec = mul(normalize(view - Out.position ) , Out.worldToTangentMx );

	return Out;
}

float4 pixel(vertex2pixel In)  :  COLOR
{
    //ambient
	float4 colorMap = tex2D(colorMapSampler, In.textCoord);
	float4 AmbientColor = float4(0.2,0.2,0.25,1);
	float AmbientIntensity = 0.25;
	
	//normal
	float3 normal = tex2D(normalMapSampler, In.textCoord);
	normal = 2 * (normal - 0.5);
	//normal = In.normal;
	
    //directional light
	float4 DirectLightColor = float4(0.2,0.5,0.4,1);
	float3 DirectLightDirect = float3(-0.5,-1,1);
	DirectLightDirect = mul(DirectLightDirect , In.worldToTangentMx);	//convert to tangent
	float LightStrength = saturate(dot(normal,(-DirectLightDirect)));

	//specular light
	float specColor = float4(1,1,1,1);
	float3 reflectVec = DirectLightDirect - 2 * dot(DirectLightDirect, normal)*normal;
	float specStrength =pow(saturate(  dot(reflectVec , In.viewVec))*1.5,3) ;
	
    float4 col =colorMap * ( AmbientColor * AmbientIntensity + LightStrength * DirectLightColor + specColor * specStrength );
	col.w=0.3;
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
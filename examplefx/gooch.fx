//////////////////////////////////////////////////////////////
//simple gooch style render - adapted from the nVidia cgFX samples
//////////////////////////////////////////////////////////////

// transformations
float4x4 world      		: WORLD;
float4x4 worldIT		: WORLDIT;
float4x4 worldViewProj 		: WORLDVIEWPROJ;
float4x4 viewIT			: VIEWIT;

/*
float4 lightPos : Position
<
	string Object = "PointLight";
	string Space = "World";
> = {100.0f, 100.0f, 100.0f, 0.0f};
*/

float4 lightPos : Position <  string UIName = "Light Position"; string Object = "PointLight";> ={100.0f, 100.0f, 100.0f, 0.0f};


/////////////////

float4 warmColor  <string UIName = "Warm Tone";> = {0.5f, 0.4f, 0.05f, 1.0f};    
float4 coolColor  <string UIName = "Cool Tone";> = {0.05f, 0.05f, 0.6f, 1.0f} ;
float4 liteColor  <string UIName = "Surface Color";> = {0.8f, 0.5f, 0.1f, 1.0f};


float4 darkColor : Diffuse
<
    string Desc = "Black value for surface";
> = {0.0f, 0.0f, 0.0f, 1.0f};

/************* DATA STRUCTS **************/

/* data from application vertex buffer */
struct appdata {
    float3 Position	: POSITION;
    float4 UV		: TEXCOORD0;
    float4 Normal	: NORMAL;
};

/* data passed from vertex shader to pixel shader */
struct vertexOutput {
    float4 HPosition	: POSITION;
    float4 TexCoord0	: TEXCOORD0;
    float4 diffCol	: COLOR0;
    float4 specCol	: COLOR1;
};

/* Output pixel values */
struct pixelOutput {
  float4 col : COLOR;
};

/*********** vertex shader ******/

vertexOutput goochVS(appdata IN,
    uniform float4x4 WorldViewProj,
    uniform float4x4 WorldIT,
    uniform float4x4 World,
    uniform float4x4 ViewIT,
    uniform float4 LiteColor,
    uniform float4 DarkColor,
    uniform float4 WarmColor,
    uniform float4 CoolColor,
    uniform float3 LightPos
) {
    vertexOutput OUT;
    float3 Nn = mul(IN.Normal,WorldIT).xyz;
    Nn = normalize(Nn);

    float4 Po = float4(IN.Position.x,IN.Position.y,IN.Position.z,1.0);
    float3 Pw = mul(Po,World).xyz;
    float3 Ln = normalize(lightPos - Pw);
    float mixer = 0.5 * (dot(Ln,Nn) + 1.0);

    float4 surfColor = lerp(DarkColor,LiteColor,mixer);
    float4 toneColor = lerp(CoolColor,WarmColor,mixer);
    float4 mixColor = surfColor + toneColor;
    mixColor.w = 1.0;

    OUT.diffCol = mixColor;

    OUT.specCol = float4(0.0,0.0,0.0,1.0);	// not actually used
    OUT.TexCoord0 = IN.UV;

    OUT.HPosition = mul(Po,WorldViewProj);
    return OUT;
}

/********* pixel shader ********/

pixelOutput goochPS(vertexOutput IN) 
{
    pixelOutput OUT; 
    float4 result = IN.diffCol;
    OUT.col = result;
    return OUT;
}

/*************/

technique PixelShaderVersion
{
    pass p0 
    {		
	VertexShader = compile vs_2_0 goochVS(worldViewProj,worldIT,world,viewIT,
				liteColor,darkColor,warmColor,coolColor,lightPos);
	PixelShader = compile ps_2_0 goochPS();				
	ZEnable = true;
	ZWriteEnable = true;
	CullMode = None;
	ShadeMode = Gouraud;
    }
}

technique NoPixelShaderVersion
{
    pass p0 
    {		
	    VertexShader = compile vs_2_0 goochVS(worldViewProj,worldIT,world,viewIT,
				    liteColor,darkColor,
				    warmColor,coolColor,lightPos);

	    ZEnable = true;
	    ZWriteEnable = true;
	    CullMode = None;

        SpecularEnable = false;

        ColorArg1[ 0 ] = Diffuse;
        ColorOp[ 0 ]   = SelectArg1;
        ColorArg2[ 0 ] = Specular;

        AlphaArg1[ 0 ] = Diffuse;
        AlphaOp[ 0 ]   = SelectArg1;
    }
}
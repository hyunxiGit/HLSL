// this fx pack all used function in scene deffer rendering in one file
// this fx includes useful pass script setting for RTT
float Script : STANDARDSGLOBAL <
    string UIWidget = "none";
    string ScriptClass = "scene";
    string ScriptOrder = "standard";
    string ScriptOutput = "color";
    string Script = "Technique=Main10;";
> = 0.8;

// color and depth used for full-screen clears

float4 gClearColor <
    string UIWidget = "Color";
    string UIName = "Background";
> = {0,0,0,0};

float gClearDepth <string UIWidget = "none";> = 1.0;

/**** UNTWEAKABLES: Hidden & Automatically-Tracked Parameters **********/

float4x4 gWorldXf : World < string UIWidget="None"; >;
float4x4 gWorldITXf : WorldInverseTranspose < string UIWidget="None"; >;
float4x4 gWvpXf : WorldViewProjection < string UIWidget="None"; >;
float4x4 gViewIXf : ViewInverse < string UIWidget="None"; >;

/*********** Tweakables **********************/

// Directional Lamp 0 ///////////
// apps should expect this to be normalized
float3 gLamp0Dir : DIRECTION <
    string Object = "DirectionalLight0";
    string UIName =  "Lamp 0 Direction";
    string Space = ("World");
> = {0.7f,-0.7f,-0.7f};
float3 gLamp0Color : COLOR <
    string UIName =  "Lamp 0";
    string Object = "DirectionalLight0";
    string UIWidget = "Color";
> = {1.0f,1.0f,1.0f};


// surface color
float3 gSurfaceColor : DIFFUSE <
    string UIName =  "Surface";
    string UIWidget = "Color";
> = {1,1,1};

// Ambient Light
float3 gAmbiColor : AMBIENT <
    string UIName =  "Ambient Light";
    string UIWidget = "Color";
> = {0.07f,0.07f,0.07f};

float gKs <
    string UIWidget = "slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
    float UIStep = 0.05;
    string UIName =  "Specular";
> = 0.4;

float gSpecExpon <
    string UIWidget = "slider";
    float UIMin = 1.0;
    float UIMax = 128.0;
    float UIStep = 1.0;
    string UIName =  "Specular Exponent";
> = 30.0;

/// texture ///////////////////////////////////
//abedo color
texture gColorTexture < 
	string ResourceName = "default_color.dds"; 
    string ResourceType = "2D"; 
>;
sampler2D gColorSampler = sampler_state
{
    texture = <gColorTexture>;
    AddressU = WRAP;
    AddressV = WRAP;
    Filter = MIN_MAG_MIP_LINEAR;
};

//render target color
texture ColrTex : RENDERCOLORTARGET < 
    float2 ViewPortRatio = {1.0,1.0}; 
    int MipLevels = 1; 
    string Format = "A16B16G16R16" ; 
    string UIWidget = "None"; 
>; 
sampler2D ColrSampler = sampler_state { 
    texture = <ColrTex>; 
    AddressU = Clamp; 
    AddressV = Clamp; 
    Filter=MIN_MAG_LINEAR_MIP_POINT; };

//render target normal
texture NormTex : RENDERCOLORTARGET < 
    float2 ViewPortRatio = {1.0,1.0}; 
    int MipLevels = 1; 
    string Format = "A16B16G16R16" ; 
    string UIWidget = "None"; 
>;
sampler2D NormSampler = sampler_state
{
    texture = <NormTex>;
    AddressU = Clamp;
    AddressV = Clamp;
    Filter = MIN_MAG_LINEAR_MIP_POINT;
};

//render target view
texture ViewTex : RENDERCOLORTARGET < 
    float2 ViewPortRatio = {1.0,1.0}; 
    int MipLevels = 1; 
    string Format = "A16B16G16R16" ; 
    string UIWidget = ("None"); 
>;
sampler2D ViewSampler = sampler_state
{
    texture = <ViewTex>;
    AddressU = Clamp;
    AddressV = Clamp;
    Filter = MIN_MAG_LINEAR_MIP_POINT;
};

//render target depth
texture DepthBuffer : RENDERDEPTHSTENCILTARGET < 
    float2 ViewPortRatio = {1,1}; 
    string Format = "D24S8"; 
    string UIWidget = ("None"); 
>;

/************* DATA STRUCTS **************/

/* data from application vertex buffer */
struct appdata {
    float3 Position	: POSITION;
    float4 UV		: TEXCOORD0;
    float4 Normal	: NORMAL;
    float4 Tangent	: TANGENT0;
    float4 Binormal	: BINORMAL0;
};

/* data passed from vertex shader to pixel shader */
struct vertexOutput {
    float4 HPosition	: POSITION;
    float2 UV		: TEXCOORD0;
    // The following values are passed in "World" coordinates since
    //   it tends to be the most flexible and easy for handling
    //   reflections, sky lighting, and other "global" effects.
    float3 LightVec	: TEXCOORD1;
    float3 WorldNormal	: TEXCOORD2;
    float3 WorldTangent	: TEXCOORD3;
    float3 WorldBinormal : TEXCOORD4;
    float3 WorldView	: TEXCOORD5;
};

/*********** vertex shader ******/

//
// use the std connector declaration but we can ignore the light direction
//
vertexOutput unlitVS(appdata IN,
    uniform float4x4 WorldITXf, // our four standard "untweakable" xforms
	uniform float4x4 WorldXf,
	uniform float4x4 ViewIXf,
	uniform float4x4 WvpXf
) {
    vertexOutput OUT = (vertexOutput)0;
    // OUT.LightVec = 0; 
    OUT.WorldNormal = mul(IN.Normal,WorldITXf).xyz;
    OUT.WorldTangent = mul(IN.Tangent,WorldITXf).xyz;
    OUT.WorldBinormal = mul(IN.Binormal,WorldITXf).xyz;
    float4 Po = float4(IN.Position.xyz,1);
    float3 Pw = mul(Po,WorldXf).xyz;
    OUT.UV = IN.UV.xy;
    OUT.WorldView = normalize(ViewIXf[3].xyz - Pw);
    OUT.HPosition = mul(Po,WvpXf);
    return OUT;
}

/********* pixel shader ********/


float3 vector_to_texture(float3 v) { return ((v*0.5)+float3(0.5,0.5,0.5)); }
float3 texture_to_vector(float3 t) { return ((t-float3(0.5,0.5,0.5))*2.0); }

//
//    Create MRTs for defered shading
//
void prepMRTPS(vertexOutput IN,
	uniform float3 SurfaceColor,
	uniform sampler2D ColorSampler,
	out float4 ColorOutput : COLOR0,
	out float4 NormalOutput : COLOR1,
	out float4 ViewptOutput : COLOR2)
{
    float3 Nn = vector_to_texture(normalize(IN.WorldNormal));
    NormalOutput = float4(Nn,0);
    float3 Vn = vector_to_texture(normalize(IN.WorldView));
    ViewptOutput = float4(Vn,0);
    float3 texC = SurfaceColor*tex2D(ColorSampler,IN.UV).rgb;
    ColorOutput = float4(texC,1);
}

//
// full-screen pass that uses the above values
//

struct QuadVertexOutput
{
    float4 Position : POSITION;
    float2 UV : TEXCOORD0;
};

float4 useMRTPS(QuadVertexOutput IN,
	    uniform float Ks,
	    uniform float SpecExpon,
	    uniform float3 LightDir,
	    uniform float3 LightColor,
	    uniform float3 AmbiColor) : COLOR
{
    float3 texC = tex2D(ColrSampler,IN.UV).rgb;
    float3 Nn = texture_to_vector(tex2D(NormSampler,IN.UV).xyz);
    float3 Vn = texture_to_vector(tex2D(ViewSampler,IN.UV).xyz);
    float3 Ln = normalize(-LightDir); // normalize() potentially un-neccesary
    float3 Hn = normalize(Vn + Ln);
    float ldn = dot(Ln,Nn);
    float hdn = dot(Hn,Nn);
    float4 lv = lit(ldn,hdn,SpecExpon);
    float3 specC = (Ks * lv.y * lv.z) * LightColor;
    float3 diffC = ((lv.y * LightColor) + AmbiColor) * texC;
    float3 result = diffC + specC;
    return float4(result.rgb,1.0);
}
//
float4 useMRTPS2(QuadVertexOutput IN,
	    uniform float Ks,
	    uniform float SpecExpon,
	    uniform float3 LightDir,
	    uniform float3 LightColor,
	    uniform float3 AmbiColor) : COLOR
{
    float3 texC = tex2D(ColrSampler, IN.UV).rgb;
    float3 Nn = texture_to_vector(tex2D(NormSampler, IN.UV).xyz);
    float3 Vn = texture_to_vector(tex2D(ViewSampler, IN.UV).xyz);
    float3 Ln = normalize(-LightDir); // normalize() potentially un-neccesary
    float3 Hn = normalize(Vn + Ln);
    float ldn = dot(Ln, Nn);
    float hdn = dot(Hn, Nn);
    float4 lv = lit(ldn, hdn, SpecExpon);
    float3 specC = (Ks * lv.y * lv.z) * LightColor;
    float3 diffC = ((lv.y * LightColor) + AmbiColor) * texC;
    float3 result = diffC + specC;
    return float4(Nn, 1.0);
}

QuadVertexOutput ScreenQuadVS2(
    float3 Position : POSITION,
    float3 TexCoord : TEXCOORD0
)
{
    QuadVertexOutput OUT;
    OUT.Position = float4(Position, 1);
    OUT.UV = float2(TexCoord.xy );
    return OUT;
}

///////////////////////////////////////
/// TECHNIQUES ////////////////////////
///////////////////////////////////////


//
// Standard DirectX10 Material State Blocks
//
RasterizerState DisableCulling { CullMode = NONE; };
DepthStencilState DepthEnabling { DepthEnable = TRUE; };
DepthStencilState DepthDisabling {
	DepthEnable = FALSE;
	DepthWriteMask = ZERO;
};
BlendState DisableBlend { BlendEnable[0] = FALSE; };

technique10 Main10 <
    string Script =
	"Pass=create_MRTs;"
	"Pass=deferred_lighting;";
> {
    pass create_MRTs <
	string Script =
	    "RenderColorTarget0=ColrTex;"
	    "RenderColorTarget1=NormTex;"
	    "RenderColorTarget2=ViewTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "ClearSetColor=gClearColor;"
	    "ClearSetDepth=gClearDepth;"
	    "Clear=Color0;"
	    "Clear=Color1;"
	    "Clear=Color2;"
	    "Clear=Depth;"
	    "Draw=Geometry;";
    >
    {
        SetRasterizerState(DisableCulling);
        SetDepthStencilState(DepthEnabling, 0);
        SetBlendState(DisableBlend, float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
        SetVertexShader(CompileShader(vs_4_0, unlitVS(gWorldITXf,
					gWorldXf, gViewIXf, gWvpXf)));
        SetGeometryShader(NULL);
        SetPixelShader( CompileShader(ps_4_0, prepMRTPS(gSurfaceColor,gColorSampler)));	    
    }
    pass deferred_lighting <
	string Script =
	    "RenderColorTarget0=;"
	    "RenderColorTarget1=;"
	    "RenderColorTarget2=;"
	    "RenderDepthStencilTarget=;"
	    "ClearSetColor=gClearColor;"
	    "ClearSetDepth=gClearDepth;"
	    "Clear=Color;"
	    "Clear=Depth;"
	    "Draw=Buffer;";
    > {        
        SetVertexShader( CompileShader( vs_4_0, ScreenQuadVS2()));
	SetGeometryShader( NULL );
	    SetRasterizerState(DisableCulling);
	    SetDepthStencilState(DepthDisabling, 0);
	    SetBlendState(DisableBlend, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF);
        SetPixelShader( CompileShader(ps_4_0, useMRTPS2(gKs,gSpecExpon,
						gLamp0Dir,gLamp0Color,
						gAmbiColor)));
    }
}

// 3ds max effect file
// Simple example of hooking up additional data from lights - in this case
// the diffuse value is obtained from the cuurent light color
// 



// light direction (view space)
float3 lightDir : Direction <  
	string UIName = "Light Direction"; 
	string Object = "TargetLight";
	int RefID = 0;
	> = {-0.577, -0.577, 0.577};

//diffuse setting controlled by the light if available	
float4 k_d : LIGHTCOLOR <
	int LightRef = 0;
> = float4( 1.0f, 1.0f, 1.0f, 1.0f );    // diffuse


// material reflectivity
float4 k_a  <
	string UIName = "Ambient";
> = float4( 0.1f, 0.1f, 0.1f, 0.1f );    // ambient

	
float4 k_s  <
	string UIName = "Specular";
	> = float4( 1.0f, 1.0f, 1.0f, 1.0f );    // diffuse    // specular

int n<
	string UIName = "Specular Power";
	string UIType = "IntSpinner";
	float UIMin = 0.0f;
	float UIMax = 50.0f;	
	>  = 15;

// texture
texture Tex0 : DiffuseMap < 
	string name = "tiger.bmp"; 
	string UIName = "Base Texture";
	>;
	
// light intensity
float4 I_a = { 0.1f, 0.1f, 0.1f, 1.0f };    // ambient
float4 I_d = { 1.0f, 1.0f, 1.0f, 1.0f };    // diffuse
float4 I_s = { 1.0f, 1.0f, 1.0f, 1.0f };    // specular

// transformations
float4x4 World      : 		WORLD;
float4x4 View       : 		VIEW;
float4x4 Projection : 		PROJECTION;
float4x4 WorldViewProj : 	WORLDVIEWPROJ;
float4x4 WorldView : 		WORLDVIEW;


struct VS_OUTPUT
{
    float4 Pos  : POSITION;
    float4 Diff : COLOR0;
    float4 Spec : COLOR1;
    float2 Tex  : TEXCOORD0;
};

VS_OUTPUT VS(
    float3 Pos  : POSITION, 
    float3 Norm : NORMAL, 
    float3 Tex  : TEXCOORD0
    )
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    float3 L = lightDir;
       

    float3 P = mul(float4(Pos, 1),(float4x4)World);  // position (view space)
    float3 N = normalize(mul(Norm,(float3x3)World)); // normal (view space)

    float3 R = normalize(2 * dot(N, L) * N - L);          // reflection vector (view space)
    float3 V = normalize(P);                             // view direction (view space)

    Out.Pos  = mul(float4(Pos,1),WorldViewProj);    // position (projected)
    
    Out.Diff = I_a * k_a + I_d * k_d * max(0, dot(N, L)); // diffuse + ambient
    Out.Spec = I_s * k_s * pow(max(0, dot(R, V)), n/4);   // specular
    Out.Tex  = Tex;   

    return Out;
}

sampler Sampler = sampler_state
{
    Texture   = (Tex0);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};


float4 PS(
    float4 Diff : COLOR0,
    float4 Spec : COLOR1,
    float3 Tex  : TEXCOORD0
    ) : COLOR
{
    float4 color = tex2D(Sampler, Tex) * Diff + Spec;
    return  color ;
}

technique DefaultTechnique
{
    pass ALPHA
    {
        // shaders
        CullMode = None;
       	VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_1_1 PS();

        // enable alpha blending
        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
    }  
}


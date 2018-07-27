// 3ds max effect file
// Simple Lighting Model

// This is used by 3dsmax to load the correct parser
string ParamID = "0x0";

//DxMaterial specific 

// light direction (world space)
float3 lightDir : Direction <  
	string UIName = "Light Direction"; 
	string Object = "TargetLight";
	> = {-0.577, -0.577, 0.577};

// light intensity
float4 I_a = { 0.1f, 0.1f, 0.1f, 1.0f };    // ambient
float4 I_d = { 1.0f, 1.0f, 1.0f, 1.0f };    // diffuse
float4 I_s = { 1.0f, 1.0f, 1.0f, 1.0f };    // specular

// material reflectivity
float4 k_a  <
	string UIName = "Ambient";
	> = float4( 0.47f, 0.47f, 0.47f, 1.0f );    // ambient
	
float4 k_d  <
	string UIName = "Diffuse";
	> = float4( 0.47f, 0.47f, 0.47f, 1.0f );    // diffuse
	
float4 k_s  <
	string UIName = "Specular";
	> = float4( 1.0f, 1.0f, 1.0f, 1.0f );    // specular

int n<
	string UIName = "Specular Power";
	string UIType = "IntSpinner";
	float UIMin = 0.0f;
	float UIMax = 50.0f;	
	>  = 15;


// transformations
float4x4 World : WORLD;
float4x4 WorldIT : WORLDINVERSETRANSPOSE;
float4x4 WorldViewProj : WORLDVIEWPROJ;
float4x4 ViewI : VIEWINVERSE;

struct VS_OUTPUT
{
    float4 Pos  : POSITION;
    float4 Diff : COLOR0;
	float4 Spec : COLOR1;
#ifdef NITROUS_DX_POST_PROCESS
	float3 hPos : TEXCOORD5;
	float3 Norm : TEXCOORD6;
#endif
};

VS_OUTPUT VS(
    float3 Pos  : POSITION, 
    float3 Norm : NORMAL)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    float3 L = lightDir;

    float3 P = mul(Pos, (float3x3)World); // position (world space)
    float3 N = normalize(mul(Norm, (float3x3)WorldIT)); // normal (world space)
    float3 R = normalize(2 * dot(N, L) * N - L); // reflection vector (world space)
    float3 V = normalize(ViewI[3].xyz - P); // view direction (world space)

    Out.Pos  = mul(float4(Pos,1),WorldViewProj);    // position (projected)
    
    Out.Diff = I_a * k_a + I_d * k_d * max(0, dot(N, L)); // diffuse + ambient
    Out.Spec = I_s * k_s * pow(max(0, dot(R, V)), n/4);   // specular
	
#ifdef NITROUS_DX_POST_PROCESS
	Out.hPos = Pos;
	Out.Norm = Norm;
#endif

    return Out;
}



float4 PS(
    float4 Diff : COLOR0,
    float4 Spec : COLOR1
#ifdef NITROUS_DX_POST_PROCESS
    ,float3 hPos : TEXCOORD5,
	float3 Norm : TEXCOORD6
#endif
     ) : COLOR
{
    float4 color = Diff + Spec;
#ifdef NITROUS_DX_POST_PROCESS
    NITROUS_DX_POST_PROCESS(color, hPos, Norm);
#endif	
    return color ;
}

technique DefaultTechnique
{
    pass P0
    {
        // shaders
        CullMode = None;
        ShadeMode = Gouraud;
        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 PS();
    }
}



float4x4 wvp : WORLDVIEWPROJ <string UIWidget = "None";>;
float4x4 world : WORLD;
float4x4 view : VIEW;
float4 camPos : WORLD_CAMERA_POSITION;

//diffuse should come from scene light
float3 lightDir : Direction<
    string UIName = "light direction";
    string Object = "TargetLight";
    int RefID = 0;
> = { 0.0f, 0.0f, 1.0f };

float4 k_d : LIGHTCOLOR <
    int LightRef = 0;
> = float4(1.0f, 1.0f, 1.0f, 1.0f);

float I_d = 1.0f;

//ambient
float I_a
<
    string UIName = "ambient intensity";
> = 0.04f;

float4 k_a <
    string UIName = "ambient color";
> = { 0.2f, 0.2f, 1.0f, 1.0f };


//specular
float4 k_s <
    string UIName = "specular color";
> = { 0.0f, 1.0f, 0.0f, 1.0f };

int p_s <
    string UIName = "specular power";
	float UIMin = 1.0f;
	float UIMax = 10.0f;
> = 5.0f;

struct VS_Input
{
    float3 normal: NORMAL;
    float3 binormal: BINORMAL;
    float3 tangent : TANGENT;
    float4 pos: POSITION;
    //float3 view : VIEW;
    float2 texCoord : TEXCOORD0;
};

struct PS_Input
{
    float4      pos         : POSITION;
    float3      lightVec    : COLOR1;
    float3      reflectVec  : COLOR0;
    float2      texCoord    : TEXCOORD0;
    float3      viewVec     : TEXCOORD1;
    float3x3    w_t         : TEXCOORD2;
    

    //float3 look : TEXCOORD2;
    //float4 diffuse : COLOR0;
    //float4 specular : COLOR1;
    
};

PS_Input VS(VS_Input In)
{
    PS_Input Out = (PS_Input) 0;  

    float3 N = mul(In.normal, (float3x3)world);
    float3 T = mul(In.tangent, (float3x3) world);
    float3 B = mul(In.binormal, (float3x3) world);
    Out.w_t = transpose(float3x3(B, T, N ));
    //Out.w_t = float3x3(B, T, N);

    Out.lightVec = mul(lightDir, Out.w_t); //tangent space
    Out.pos = mul(In.pos, wvp);//here the pos is in view space . (0,0,0) is view point, so it can be use as view vector

    //specular
    float3 L = Out.lightVec;
    Out.reflectVec = L - 2 * dot(L, float3(0.0f, 1.0f, 0.0f)) * float3(0.0f, 1.0f, 0.0f);
    Out.viewVec = mul(normalize((mul(In.pos, world) - camPos).xyz), Out.w_t);

    Out.texCoord = In.texCoord;
    return Out ;
}

//color map
texture Tex0 : DiffuseMap <
    string UIName = "Color map";
    string ResourceType = "2D";
>;

sampler2D c_Sampler = sampler_state
{
    Texture = <Tex0>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

//normal map
texture Tex1 : NormalMap <
    string UIName = "Normal map";
    string ResourceType = "2D";
>;

float I_n <
    string UIName = "Normal intensity";
    float UIMin = 0.0f;
	float UIMax = 1.0f;
> = 1;

sampler2D n_Sampler = sampler_state
{
    Texture = <Tex1>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

float4 PS(PS_Input In) :  COLOR
{
    float3 normalMap = tex2D(n_Sampler, In.texCoord).xyz * 2 -1.0f;
    float3 N = normalMap;
    N = float3(N.x * I_n, N.y * I_n,1);
    float3 L = In.lightVec;
    float3 R = normalize(2 * dot(L, N) * N - L);
    float3 V = In.viewVec;

    float4 diffuse = I_a * k_a + k_d * I_d * max(dot(L, N), 0);
    float4 specular = k_s * pow(max(dot(V, R), 0), p_s);

    float4 color = tex2D(c_Sampler, In.texCoord) * diffuse +float4(0,0,0,1) + specular;
    return color;
}

technique DefaultTechnique
{
    pass P0
    {
        CullMode = None;

        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PS();
    }
}
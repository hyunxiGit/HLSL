float4x4 wvp : WORLDVIEWPROJ <string UIWidget = "None";>;
float4x4 world : WORLD;
float4x4 worldi : WorldI;
float4 camPos : WORLD_CAMERA_POSITION;
float time : TIME;

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
    float3 normal   : NORMAL;
    float3 binormal : BINORMAL;
    float3 tangent  : TANGENT;
    float4 pos      : POSITION;
    float2 uv       : TEXCOORD0;
};

struct PS_Input
{
    float4      pos   : POSITION;
    float3      L     : TEXCOORD1;
    float3      N     : COLOR0;
    float2      uv    : TEXCOORD0;   
};

PS_Input VS(VS_Input IN)
{
    PS_Input OUT = (PS_Input) 0; 
    float t = time / 300;
    float3 N = IN.normal;
    float4 P = IN.pos;

    //wave   
    float fx = sin(t) * 10;
    float fy = sin(t) * 20;
    float fz = sin(t) * 40;

    //P.x += fx;
    //P.y += fy;
    //P.z += fz;

    float cx = sin(P.x * t/200) *5;
    float cy = sin(P.y * t/200) ;
    P.z += (cx +cy);

    float3x3 MOT; // this matrix conver Tv to Ov
    //float3x3 MOT;
    MOT[0] = IN.binormal;
    MOT[1] = IN.tangent;
    MOT[2] = IN.normal;

    float3 L = lightDir;
    OUT.L = normalize(mul(lightDir, (float3x3) worldi));
    OUT.L = mul(MOT, OUT.L);
    OUT.L = normalize(OUT.L);

    OUT.N = mul(MOT, N);
    OUT.pos = mul(P, wvp);
    OUT.uv = IN.uv;
    return OUT;
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

float4 PS(PS_Input IN) :  COLOR
{
    float4 C = tex2D(c_Sampler, IN.uv);
    float4 col = C * max(dot(IN.N, IN.L), 0);
    col.a = 0.3f;
    return col;
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
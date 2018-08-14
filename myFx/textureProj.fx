float4x4 wvp : WorldViewProjection;
float4x4 viewI : ViewInverse;
float4x4 world : WORLD;
float4x4 worldI : WorldInverseTranspose;

float script : STANDARDSGLOBAL <
    string UIWidget = "none";
    string ScriptClass = "object";
    string ScriptOrder = "standard";
    string ScriptOutput = "color";
    string Script = "Technique = Main;";
> = 0.8f;

float3 Lamp0Pos : POSITION
<   
    string Object = "PointLight0";
    string UIName = "Light Position";
    string Space = "World";
    int refID = 0;
> = { -0.5f, 2.0f, 1.25f };

TextureCube lightProjMap < 
	string UIName = "cubemap";
	string ResourceType = "CUBE";
>;

SamplerState lightProjSampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
    AddressW = Clamp;
};

Texture2D<float4> projectMap2 < 
	string UIName = "projection texture";
	string ResourceType = "2D";
	int Texcoord = 0;
>;

SamplerState projectMap2_Sampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

struct VS_IN
{
    float4 pos : POSITION;
    float3 nor : NORMAL;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 p_w : TEXCOORD1;
    float3 n_w : TEXCOORD2;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.p_w = mul(IN.pos, world);
    OUT.n_w = normalize(mul(IN.nor, world));
    return OUT;
}

float4 PS(PS_IN IN) : SV_Target
{
    float4 COL = { 1, 0, 1, 1 };   
    float3 L = normalize(Lamp0Pos - IN.p_w);

    //light space 
    float3x3 M_lw;
    float3 l_normalized = normalize(Lamp0Pos);
    M_lw[0] = float3(l_normalized.x, 0, 0);
    M_lw[1] = float3(0, l_normalized.y, 0);
    M_lw[2] = float3(0, 0, l_normalized.z);

    float3 N = mul(M_lw, IN.n_w);
    L = mul(M_lw, L);


    //cube map
    float3 L2 = normalize(mul(M_lw, normalize(IN.p_w - Lamp0Pos)));
    float4 lightMap = lightProjMap.Sample(lightProjSampler, L2);

    //att
    float l_r = 0.00006f;
    float att_r = 1-saturate(length(Lamp0Pos - IN.p_w) * l_r);
    att_r *= att_r;

    float CosIn = 0.866; // 30 degree
    float CosOut = 0.5; //60 sdegree

    float3 LD = normalize( Lamp0Pos);
    float3 LP = normalize( Lamp0Pos - IN.p_w);

    float cosThe = dot(LD, LP);

    float attCon = saturate((cosThe - CosOut) / (CosIn - CosOut));

    lightMap = float4(1, 1, 1, 1);

    //projection matrix
    float f = 16666;
    float n = 0.00001f;
    float Q1 = -(f + n) / (f - n);
    float Q2 = -2*f*n / (f - n);

    float4x4 proj;
    proj[0] = float4(0.577f, 0, 0, 0);
    proj[1] = float4(0, 0.577f, 0, 0);
    proj[2] = float4(0, 0, Q1, Q2);
    proj[3] = float4(0, 0, -1, 0);

    float4 L_proj = mul(float4(L2, -L2.z), proj);
    


    COL.xyz = saturate(lightMap * dot(N, L)) * att_r * attCon + float3(0.01f, 0.01f, 0.015f);
    //COL.xyz = dot(N, L);
    return COL;
}

fxgroup dx11
{

technique11 Main_11 <
	string Script = "Pass=p0;";
>
{
    pass p0 <
	string Script = "Draw=geometry;";
    >
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, PS()));
    }
}
}
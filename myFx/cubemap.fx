//#include "Common/Common.hlsli"

float4x4 wvp : WorldViewProjection;
float4x4 ViewIXf : ViewInverse < string UIWidget="None"; >;
float4x4 world : WORLD;
float4x4 WorldITXf : WorldInverseTranspose < string UIWidget="None"; >;

TextureCube g_ReflectionTexture < 
	string UIName = "Reflection";
	string ResourceType = "CUBE";
>;
SamplerState g_ReflectionSampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
    AddressW = Clamp;
};

SamplerState cubemapSampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
    AddressW = Clamp;
};

float script : STANDARDSGLOBAL <
    string UIWidget = "none";
    string ScriptClass = "object";
    string ScriptOrder = "standard";
    string ScriptOutput = "color";
    string Script = "Technique = Main;";
> = 0.8f;

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
    float3 WorldView : TEXCOORD1;
    float3 WorldNormal : NORMAL;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    float3 Pw = mul(IN.pos, world).xyz;
    OUT.pos = mul(IN.pos, wvp);
    OUT.WorldView = normalize(ViewIXf[3].xyz - Pw);
    //OUT.WorldNormal = mul(IN.nor, WorldITXf).xyz;
    OUT.WorldNormal = mul(IN.nor, world).xyz;
    return OUT;
}

float4 PS(PS_IN IN) : SV_Target
{
    float3 Vn = normalize(IN.WorldView);
    float3 Nn = normalize(IN.WorldNormal);
    float4 COL = { 1, 0, 1, 1 };
   // float3 R = Vn - 2 * dot(Vn, Nn) * Nn;
    float3 R = reflect(Vn, Nn);
    float3 reflColor = g_ReflectionTexture.Sample(g_ReflectionSampler, R.xyz).rgb;
    COL.xyz = reflColor;
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
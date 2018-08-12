//#include "Common/Common.hlsli"
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

TextureCube cubeMap < 
	string UIName = "cubemap";
	string ResourceType = "CUBE";
>;

SamplerState cubeMapSampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
    AddressW = Clamp;
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
    float3 nor_w : TEXCOORD1;
    float3 view_w : TEXCOORD2;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.nor_w = mul(IN.nor, worldI);
    float3 p_w = mul(IN.pos, world);
    OUT.view_w = normalize(viewI[3].xyz - p_w);
    return OUT;
}



float4 PS(PS_IN IN) : SV_Target
{
    float4 COL = { 1, 0, 1, 1 };
   // float3 R = normalize(IN.view_w - 2 * dot(IN.view_w, IN.nor_w) * IN.nor_w);
    float3 R = reflect(IN.view_w, IN.nor_w);
    float3 reflection = cubeMap.Sample(cubeMapSampler, R);
    COL.xyz = reflection;
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
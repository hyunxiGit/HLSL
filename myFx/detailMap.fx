float4x4 wvp : WorldViewProjection;

string ParamID = "0x003";

float Script : STANDARDSGLOBAL <
    string UIWidget = "none";
    string ScriptClass = "object";
    string ScriptOrder = "standard";
    string ScriptOutput = "color";
    string Script = "Technique=Main;";
> = 0.8;

struct VS_IN
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
};

//ui elements
//base map
Texture2D<float4> color_texture < 
	string UIName = "Base Map";
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;

//detail map
Texture2D<float4> detail_map_r < 
	string UIName = "detail map 1";
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;
float3 d1HSV = float3(0, 1, 1); //red

Texture2D<float4> detail_map_g < 
	string UIName = "detail map 2";
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;
float3 d2HSV = float3(0.333, 1, 1); //green

SamplerState colorMapSampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

SamplerState detail_map_r_Sampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};
SamplerState detail_map_g_Sampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.uv = IN.uv;
    return (OUT);
}
float3 RGBtoHSV(float3 RGB)
{
    float3 HSL;

    float r = RGB.r;
    float g = RGB.g;
    float b = RGB.b;

    float M = max(max(r, g), b);
    float m = min(min(r, g), b);
    float C = M - m;
    float H;

    if (C>0)
    {
        if ( r == M)
        {
            H = fmod((g - b) / C, 6) / 6;
        }
        else if (g == M)
        {
            H = ((b - r) / C + 2) / 6;
        }
        else
        {
            H = ((r - g) / C + 4) / 6;
        }
    }
    else
    {
        H = 0.0f;
    }

    float S = C / M;
    float V = M;

    HSL.x = H;
    HSL.y = S;
    HSL.z = V;
    return HSL;
}

float4 PS(PS_IN IN) : SV_Target
{
    float4 col;
    float4 bCol = color_texture.Sample(colorMapSampler, IN.uv);
    float4 d1Col = detail_map_r.Sample(detail_map_r_Sampler, IN.uv);
    float4 d2Col = detail_map_g.Sample(detail_map_g_Sampler, IN.uv);
    col = bCol * 0.3 + d1Col * 0.3 + d2Col * 0.3;
    return col;
}

struct vertex2pixel
{
    float4 pos : SV_Position;
    float2 uv : TEXCOORD0;
    float3 lightTangent : TEXCOORD1;
};


fxgroup dx11
{

technique11 Main<
    string script = "Pass = p0;";
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
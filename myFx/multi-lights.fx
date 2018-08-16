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

float3 Lamp0Pos : Direction <
    string Object = "TargetLight";
    string UIName =  "Direction Light ";
	int refID = 0;
> = { -0.5f, 2.0f, 1.25f };

float4 Lamp0Att : LIGHTATTENUATION <
    int LightRef = 0;
> = float4(10.f,1.0f,1.0f,1.0f);

float3 Lamp1Pos : POSITION <
    string Object = "PointLight";
    string UIName =  "Spot Light";
    string Space = "World";
	int refID = 0;
> = { -0.5f, 2.0f, 1.25f };


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
    float3 pos_w : TEXCOORD2;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.nor_w = mul(IN.nor, world);
    OUT.pos_w = mul(IN.pos, world);
    return OUT;
}

float4 PS(PS_IN IN) : SV_Target
{
    float4 COL = { 1, 1, 1, 1 };
    float att = 0;
    COL.xyz = dot(IN.nor_w, Lamp0Pos) * att;
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

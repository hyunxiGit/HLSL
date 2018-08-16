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

struct VS_IN
{
    float4 pos : POSITION;
    float3 nor : NORMAL;
    float2 uv : TEXCOORD0;
    float4 col : COLOR;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float4 col : COLOR0;
    float2 uv : TEXCOORD0;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.col = IN.col;
    return OUT;
}

float4 PS(PS_IN IN) : SV_Target
{
    float4 COL = { 1, 1, 1, 1 };
    COL=COL *IN.col;
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
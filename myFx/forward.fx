string ParamID = "0x003";

float4x4 world : WORLD;
float4x4 worldI : WorldInverseTranspose;
float4x4 view : VIEW;
float4x4 proj : Projection;
float4x4 wvp : WorldViewProjection;
float4x4 ViewI : ViewInverse ;

float script : STANDARDSGLOBAL<
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
float3 Lamp0Color : Specular <
    string UIName =  "Lamp 0";
    string Object = "Pointlight0";
    string UIWidget = "Color";
> = { 1.0f, 1.0f, 1.0f };

struct VS_IN
{
    float4 pos : POSITION;
    float3 nor : NORMAL;
}; 

struct PS_IN
{
    float4 pos : SV_POSITION;
    float3 nor_w : TEXCOORD1;
    float3 viw : TEXCOORD2;
    float3 light : TEXCOORD3;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.nor_w = mul(IN.nor, (float3x3)world);

    float3 pw = mul(IN.pos, world);

    //ViewI[3] : viewpoint in world space
    OUT.viw.xyz = normalize((ViewI[3] - pw).xyz);

    OUT.light = normalize(Lamp0Pos - pw);
    return OUT;
}

float4 PS (PS_IN IN) : SV_Target
{
    float4 COL = { 0,0,0,1 };
    float3 N = IN.nor_w;
    float3 L = IN.light;
    float3 LC = Lamp0Color;
    float3 V = IN.viw;

    //hemisphere ambient light
    float3 colUp_a = { 0.5, 0, 0 };
    colUp_a *= 0.5f;//Intensity
    float3 colDown_a = {0, 0.5, 0 };
    colDown_a *= 0.5f;
    float3 A = mad(N.z, colUp_a - colDown_a, colDown_a);

    //direction light phon diffuse
    float3 D = LC * dot(N, L) * 0.7f; //intensity

    //blinn specular
    float3 Hn = normalize(L + V);
    float3 S = pow(dot(Hn, N) , 35);
  
    //if use lit function
    float4 litV = lit(dot(L, N), dot(Hn, N), 25);
    D = litV.y * LC;
    S = litV.y * litV.z; 

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
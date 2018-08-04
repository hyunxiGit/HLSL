string ParamID = "0x003";

float Script : STANDARDSGLOBAL <
    string UIWidget = "none";
    string ScriptClass = "object";
    string ScriptOrder = "standard";
    string ScriptOutput = "color";
    string Script = "Technique=Main;";
> = 0.8;

float4x4 wvp : WorldViewProjection <string UIWidget = "None";>;
float4x4 world : WORLD <string UIWidget = "None";>;
float4x4 worldI : WorldI <string UIWidget = "None";>;
float3 view : VIEW <string UIWidget = "None";>;

//ui elements
Texture2D <float4> color_texture < 
	string UIName = "Color Map";
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;

Texture2D <float4> normal_texture <
	string UIName = "Normal Map";
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;

float3 lightDir : POSITION <
	string UIName = "Light Direction";
	string Object = "PointLight0";
	int RefId = 0;
> = { -0.5f, -1.0f, 1.0f };

float4 I_d : Specular <
    string UIName = "Light Color";
    string Object = "PointLight0";
    string UIWidget = "Color";
> = { 1, 1, 1, 1 };

struct app2vertex
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
    float3 binormal : BINORMAL;
    float3 tangent : TANGENT;
    float3 normal : NORMAL;

    
};

struct vertex2pixel
{
    float4 pos : SV_Position;
    float2 uv : TEXCOORD0;
    float3 lightTangent : TEXCOORD1;
};

SamplerState colorMapSampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

SamplerState normalMapSampler
{
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

vertex2pixel vertex(app2vertex In)
{
    vertex2pixel Out = (vertex2pixel) 0;

    float3 L = lightDir;
    float3 N = In.normal;
    float3 B = In.binormal;
    float3 T = In.tangent;
    
    float3x3 MOT; // this matrix conver Tv to Ov
    MOT[0] = B;
    MOT[1] = T;
    MOT[2] = N;
        
    float3x3 MTO = transpose(MOT); // this matrix conver Ov to Tv

    //conv L to O space
    L = normalize(mul(L, (float3x3) worldI));
    
    //conv L to T space ,  can use either of these 2
    //Out.lightTangent = mul(L, MTO); //left mul
    Out.lightTangent = normalize(mul(MOT, L)); //right mul

    Out.pos = mul(In.pos, wvp);
    Out.uv = In.uv;

    return Out;
}

float4 pixel(vertex2pixel In) : COLOR
{
    float4 color = color_texture.Sample(colorMapSampler, In.uv);
    float4 normalMap = normal_texture.Sample(normalMapSampler, In.uv);
    float3 L = normalize(In.lightTangent);
    float3 N = normalMap * 2 - 1;

    float4 col = max(dot(N, L), 0);

    //col = dot(In.B, float3(1, 0, 0));
    
    return col;
}

fxgroup dx11
{

    technique11 Main_11<
    string script = "Pass = p0;";
    >
    {
    pass p0 <
    string Script = "Draw=geometry;";
    >
    {
        SetVertexShader(CompileShader(vs_5_0, vertex()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, pixel()));
    }

    }

}
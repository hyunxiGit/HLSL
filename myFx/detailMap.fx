float4x4 wvp : WorldViewProjection;
float4x4 ViewI : ViewInverse;
float4x4 world : WORLD;

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
    float3 nor : NORMAL;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 viw : TEXCOORD2;
    float3 nor : TEXCOORD3;
};

//ui elements
//lights

float3 Lamp0Pos : POSITION <
    string Object = "PointLight0";
    string UIName =  "Light Position";
    string Space = "World";
	int refID = 0;
> = { -0.5f, 2.0f, 1.25f };

//base map
Texture2D<float4> color_texture < 
	string UIName = "Base Map";
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;

//detail map 


float4 d1HSV <
	string UIName = "detail map 1 color";
	string UIWidget = "Color";
> = float4(0.39f, 0.26f, 0.157f, 1.0f);

Texture2D<float4> detail_map_r < 
	string UIName = "detail map 1";
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;

Texture2D<float4> normalmap1 < 
	string UIName = "normal map 1";
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;

Texture2D<float4> roughmap1 < 
	string UIName = "roughness map";
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;


//float3 d1HSV = detailC1.xyz; //red

Texture2D<float4> detail_map_g < 
	string UIName = "detail map 2";
	string ResourceType = "2D";
    int Texcoord = 0;
	int MapChannel = 1;
>;

float4 d2HSV <
	string UIName = "detail map 2 color";
	string UIWidget = "Color";
> = float4(0.149f, 0.537f, 0.098f, 1.0f);

//blending parameters
int n <
    string UIName = "blend power";
	string UIWidget = "slider";
	float UIMin = 0.0f;
	float UIMax = 50.0f;	
> = 8;

float m <
    string UIName = "blend strength";
	string UIWidget = "slider";
	float UIMin = 0.0f;
	float UIMax = 1.0f;	
> = 0.0f;

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

SamplerState roughMapSampler
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
    float3 pw = mul(IN.pos, world).xyz;
    OUT.pos = mul(IN.pos, wvp);
    OUT.uv = IN.uv;
    OUT.viw.xyz = normalize((ViewI[3].xyz - pw).xyz);
    OUT.nor = IN.nor;
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

float4 detailBlending(float4 baseColor, float4 d1, float4 d2)
{
    float4 col;

    float3 bHSV = RGBtoHSV(baseColor.rgb);

    //calculate distance 
    int detailSize = 2;
    float3 detailVec[2] = { RGBtoHSV(d1HSV.xyz), RGBtoHSV(d2HSV.xyz) };
    float distance[2] = { 0, 0 };
    float C = 0;
    
    for (int i = 0; i < 2; i++)
    {
        float3 v;
        v.x = bHSV.x - detailVec[i].x;
        v.y = bHSV.y - detailVec[i].y;
        v.z = bHSV.z - detailVec[i].z;

        v.x = min(v.x, 1.0 - v.x);

        float dis = 1.0f / pow(dot(v, v), n);
        distance[i] = dis;
        C += dis;
    }

    for (int j = 0; j < 2; j++)
    {
        distance[j] = distance[j] / C;
    }

    col = baseColor * (1 - m) + (d1 * distance[0] + d2 * distance[1]) * m;

    return col;
}

float4 PS(PS_IN IN) : SV_Target
{
    float4 col;
    int UVscale = 5;
    float4 bCol = color_texture.Sample(colorMapSampler, IN.uv);
    float4 d1Col = detail_map_r.Sample(detail_map_r_Sampler, IN.uv * UVscale);
    float4 d2Col = detail_map_g.Sample(detail_map_g_Sampler, IN.uv * UVscale);
    float4 normal = normalmap1.Sample(normalMapSampler, IN.uv * UVscale);
    float4 rought = roughmap1.Sample(roughMapSampler, IN.uv * UVscale);
    float specular = saturate(pow(0.7 - rought.x, 4) * 40);
    specular = saturate(pow(1 - rought.x, 5));
    
    //normal

    float3 diffuse = detailBlending(bCol, d1Col, d2Col).xyz;
    float3 N = normal * 2.0f - 1.0f;
    N = normalize(float3((N.xy + IN.nor.xy), IN.nor.z));
    N = normalize(mul(N, (float3x3) world));
    
    float3 L = normalize(Lamp0Pos - mul(IN.pos , world).xyz);
    float3 V = IN.viw;

    float3 Hn = normalize(L + V);

    float4 litV = lit(dot(L, N), dot(Hn, N), 5);
    float3 D = litV.y * diffuse;
    float3 S = litV.y * litV.z * specular * (diffuse * 0.5 + float3(1, 1, 1)*0.5);

    col.xyz = D +S;
    
    col.w = 1;
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
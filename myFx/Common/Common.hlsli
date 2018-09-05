float4x4 wvp : WorldViewProjection;
float4x4 viewI : ViewInverse;
float4x4 world : WORLD;
float4x4 worldI : WorldInverseTranspose;

#define PI 3.14159

#define SCRIPT_FX(usetechnique) float Script : STANDARDSGLOBAL <\
string UIWidget = "none";\
string ScriptClass = "object";\
string ScriptOrder = "standard";\
string ScriptOutput = "color";\
string Script = (usetechnique);\
> = 0.8;\
string ParamID = "0x003";

#define DECLARE_FLOAT_UI(name ,uiMin, uiMax,defaultV, uiName, uiOrder) float name <\
    string UIName = (uiName);\
	string UIWidget = "slider";\
    float UIMin = (uiMin);\
    float UIMax = (uiMax);\
    int UIOrder = (uiOrder);\
> = (defaultV);
#define DECLARE_FLOAT(name ,uiMin, uiMax,defaultV, uiName ) DECLARE_FLOAT_UI(name ,uiMin, uiMax,defaultV, uiName, 0)

#define DECLARE_COLOR_UI(name, value , uiName, uiOrder)\
float4 name <\
string UIName = (uiName);\
string UIWidget = "Color";\
int UIOrder = (uiOrder);\
> = (value);
#define DECLARE_COLOR(name, value , uiName ) DECLARE_COLOR_UI(name, value , uiName, 0)

#define DECLARE_LIGHT_UI(lightName , objectName, uiName, id , uiOrder)\
float3 lightName : POSITION <\
string Object = (objectName);\
string UIName = (uiName);\
string Space = "World";\
int refID = (id);\
int UIOrder = (uiOrder);\
> = { -0.5f, 2.0f, 1.25f };
#define DECLARE_LIGHT(lightName , objectName, uiName, id ) DECLARE_LIGHT_UI(lightName , objectName, uiName, id, 0)

#define TEXTURE2DNO(TextName , SampName) \
Texture2D<float4> TextName <\
	string ResourceType = "2D";\
    int Texcoord = 0;\
	int MapChannel = 1;\
>;\
SamplerState SampName\
{\
    Filter = MIN_MAG_MIP_LINEAR;\
    AddressU = Wrap;\
    AddressV = Wrap;\
};

#define TEXTURE2D(TexName, SampName, filename, uiName , uIOrder)\
Texture2D<float4> TexName <\
	string UIName = (uiName);\
    string name = (filename);\
	string ResourceType = "2D";\
    int UIOrder = (uIOrder);\
    int Texcoord = 0;\
	int MapChannel = 1;\
>;\
SamplerState SampName\
{\
    Filter = MIN_MAG_MIP_LINEAR;\
    AddressU = Wrap;\
    AddressV = Wrap;\
};

#define DECLARE_CUBE_UI(TexName, SampName, uiName , uIOrder)\
TextureCube TexName < \
    string UIName = (uiName);\
	string ResourceType = "CUBE";\
    int UIOrder = (uIOrder);\
>;\
SamplerState SampName\
{\
    Filter = MIN_MAG_MIP_LINEAR;\
    AddressU = Clamp;\
    AddressV = Clamp;\
    AddressW = Clamp;\
};
#define DECLARE_CUBE(TexName, SampName, uiName) DECLARE_CUBE_UI(TexName, SampName, uiName , 0)

#define RENDERTARGET(TexName,SampName, r_x, r_y,PixelFormat) Texture2D<float4> TexName : RENDERCOLORTARGET\
<\
    float2 ViewPortRatio = {r_x,r_y}; \
	string ResourceType = "2D";\
    string Format = (PixelFormat) ; \
    int Texcoord = 0;\
	int MapChannel = 1;\
>;\
SamplerState SampName\
{\
    AddressU = Wrap;\
    AddressV = Wrap;\
};

#define DECLARE_SIZED_QUAD_TEX(TexName,SampName,PixFmt,Multiple) texture TexName : RENDERCOLORTARGET < \
    float2 ViewPortRatio = {Multiple,Multiple}; \
    int MipLevels = 1; \
    string Format = PixFmt ; \
    string UIWidget = (TARGETWIDGET); \
>; \
sampler2D SampName = sampler_state { \
    texture = <TexName>; \
    AddressU = Clamp; \
    AddressV = Clamp; \
    MagFilter = Linear; \
    MinFilter = Linear; \
    MipFilter = Point; };

//#define DECLARE_SAMPLER_2D("Diffuse", _diffuseSampler, _diffuse_map, "default_c.png")

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

    if (C > 0)
    {
        if (r == M)
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

float3 vector_to_texture(float3 v) { return ((v * 0.5) + float3(0.5, 0.5, 0.5));}
float3 texture_to_vector(float3 t) { return ((t - float3(0.5, 0.5, 0.5)) * 2.0);}
float4x4 wvp : WorldViewProjection;
float4x4 viewI : ViewInverse;
float4x4 world : WORLD;
float4x4 worldI : WorldInverseTranspose;

#define SCRIPT_FX(usetechnique) float Script : STANDARDSGLOBAL <\
string UIWidget = "none";\
string ScriptClass = "object";\
string ScriptOrder = "standard";\
string ScriptOutput = "color";\
string Script = (usetechnique);\
> = 0.8;\
string ParamID = "0x003";

#define FLOATUI(name ,uiMin, uiMax,defaultV, uiName, uiOrder) float name <\
    string UIName = (uiName);\
	string UIWidget = "slider";\
    float UIMin = (uiMin);\
    float UIMax = (uiMax);\
    int UIOrder = (uiOrder);\
> = (defaultV);

#define COLORS(name, value , uiName, uiOrder)\
float4 name <\
string UIName = (uiName);\
string UIWidget = "Color";\
int UIOrder = (uiOrder);\
> = (value);

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
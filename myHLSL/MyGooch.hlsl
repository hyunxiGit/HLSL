cbuffer perObjectVS : register(b0)
{
    matrix MVP : packoffset(c0);
    matrix World : packoffset(c4);
}

cbuffer perObjectPS : register(b0)
{
    float3 eyePos : packoffset(c0);
    float specExp : packoffset(c0.w);
    float specIntensity : packoffset(c1);
}

cbuffer perDirectionalLightPS : register(b1)
{
    float3 ambienColorLow : packoffset(c0);
    float3 ambientColorRange : packoffset(c1);
    float3 dirLightVector : packoffset(c2);
    float3 dirLightColor : packoffset(c3);
}

struct VIN
{
    float4 pos : POSITION;
    float3 nor : NORMAL;
    float2 uv : TEXCOORD0;
};

struct VOUT
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 nor_w : TEXCOORD1;
    float4 pos_w : TEXCOORD2;
};

struct Material
{
    float3 col;
    float3 pos;
    float3 nor_w;
    float specExp;
    float specIntens;
};

float4 DepthPrePassVS(float4 pos : POSITION) : SV_Position
{
    return mul(pos, MVP);
}

float3 rgb2Srgb(float3 c)
{
    return pow(c, 2.2);
}

Material prepareMaterial(VOUT IN)
{
    Material m;
    m.col = float3(0.5, 0.5, 0.5);
    m.pos = IN.pos_w;
    m.nor_w = IN.nor_w;
    m.specExp = specExp;
    m.specIntens = specIntensity;
    return m;
}

VOUT MyRenderSceneVS(VIN IN)
{
    VOUT OUT;
    OUT.pos = mul(IN.pos, MVP);
    OUT.nor_w = mul(IN.nor, (float3x3) World);
    OUT.pos_w = mul(IN.pos, World);
    OUT.uv = IN.uv;
    return OUT;
}

void goofShade(Material m, VOUT IN, inout float3 specContrib, inout float3 diffuseContrib)
{
    float goochScale = 0.2;
    float3 H = normalize(dirLightVector + (eyePos - m.pos));
    float NoL = dot(m.nor_w, dirLightVector);
    float NoH = dot(m.nor_w, H);
    float3 warmColor = float3(0.5, 0.203, 0.0988);
    float3 coolColor = float3(0.19, 0.3, 0.26);
    float3 litV = lit(NoL, NoH, m.specExp);
    float goochContrib = (dot(m.nor_w, dirLightColor) + 1)*0.5;
    specContrib = float3(litV.z, litV.z, litV.z) * m.specIntens * dirLightColor;
    diffuseContrib = lerp(coolColor, warmColor,NoL);
}

float4 MyDirectionalLightPS(VOUT IN) : SV_Target
{
    float3 col;
    float3 specContrib = float3(0,0,0);
    float3 diffuseContrib = float3(0, 0, 0);
    float3 surfaceColor = float3(1, 1, 1);
    Material m = prepareMaterial(IN);
    float3 ambient = ambientColorRange + ambienColorLow * (m.nor_w / 2 + 0.5);
    ambient = float3(0, 0, 0);
    goofShade(m, IN, specContrib, diffuseContrib);
    col = specContrib + surfaceColor * (diffuseContrib + ambient);
    col = rgb2Srgb(col);

    return float4(col, 1);
}
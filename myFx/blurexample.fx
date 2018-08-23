#include "Common/Common.hlsli"
//////////////////////////
//       OUTPUT

struct VertexOut
{
    float4 PosH : SV_POSITION;
    float2 Tex : TEXCOORD;
};

//////////////////////////
//     Screen Quad

VertexOut VS(uint id : SV_VertexId)
{
    VertexOut vout;
    vout.Tex = float2(id % 2, (id % 4) >> 1);//output : (0,0) (1,0),(0,1)(1,1)
    vout.PosH = float4((vout.Tex.x - 0.5f) * 2, -(vout.Tex.y - 0.5f) * 2, 0, 1);
    return vout;
}

//////////////////////////
//        Blur
float pixelOffset[7] =
{
    -3, -2, -1, 0, 1, 2, 3
};

float blurFactor[7] =
{
    1, 3, 5, 9, 5, 3, 1
};
TEXTURE2D(txBlur, sampleLinear, "D:/work/HLSL/texture/blendBase.png", "Base Map", 0)
float4 PS_BlurX(VertexOut pin) : SV_TARGET
{
    float4 sum = float4(0.0f, 0.0f, 0.0f, 0.0f);

    [unroll]
    for (int i = 0; i < 7; i++)
    {
        float4 col = txBlur.Sample(sampleLinear, pin.Tex + float2(pixelOffset[i], 0));
        sum += col * blurFactor[i];
    }
    return sum / 27;
}

float4 PS_BlurY(VertexOut pin) : SV_TARGET
{
    float4 sum = float4(0.0f, 0.0f, 0.0f, 0.0f);

    [unroll]
    for (int i = 0; i < 7; i++)
    {
        float4 col = txBlur.Sample(sampleLinear, pin.Tex + float2(0, pixelOffset[i]));
        sum += col * blurFactor[i];
    }
    return sum / 27;
}

//////////////////////////
//      TECHNIQUES

DepthStencilState DepthDisabling
{
    DepthEnable = FALSE;
    DepthWriteMask = ZERO;
};

technique11 BlurTech
{
    pass P0
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetPixelShader(CompileShader(ps_5_0, PS_BlurX()));
        SetDepthStencilState(DepthDisabling, 0);
        SetRasterizerState(0);
    }

    pass P1
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetPixelShader(CompileShader(ps_5_0, PS_BlurY()));
        SetDepthStencilState(DepthDisabling, 0);
        SetRasterizerState(0);
    }
};
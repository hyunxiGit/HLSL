float4x4 wvp : WorldViewProjection;
float4x4 viewI : ViewInverse;
float4x4 world : WORLD;

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

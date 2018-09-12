#ifndef PBRBASE_HLSLI
#define PBRBASE_HLSLI
#include "Common.hlsli"

float GlV(float NoV, float k)
{
    return NoV / (NoV * (1 - k) + k);
}

float G_Smith(float r, float NoV, float NoL)
{
    //float k = (r + 1) * (r + 1) / 8;
    float k = sqrt(2 * pow(r, 2) / PI);
    float G = GlV(NoV, k) * GlV(NoL, k);
    return G;
    //float R2 = r * r;
    //float G_V = NoV + sqrt((NoV - NoV * R2) * NoV + R2);
    //float G_L = NoL + sqrt((NoL - NoL * R2) * NoL + R2);
    //return rcp(G_V * G_L);
}

float RadicalInverse_VdC(uint bits)
{
    bits = (bits << 16u) | (bits >> 16u);
    bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
    bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
    bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
    bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
    return float(bits) * 2.3283064365386963e-10; // / 0x100000000
}

float2 Hammersley(uint i, uint N)
{
    return float2(float(i) / float(N), RadicalInverse_VdC(i));
}

float3 ImportanceSampleGGX(float2 Xi, float Roughness, float3 N)
{
    float a = Roughness * Roughness;
    float Phi = 2 * PI * Xi.x;
    float CosTheta = sqrt((1 - Xi.y) / (1 + (a * a - 1) * Xi.y));
    float SinTheta = sqrt(1 - CosTheta * CosTheta);
    float3 H;
    H.x = SinTheta * cos(Phi);
    H.y = SinTheta * sin(Phi);
    H.z = CosTheta;
    float3 UpVector = abs(N.z) < 0.999 ? float3(0, 0, 1) : float3(1, 0, 0);
    float3 TangentX = normalize(cross(UpVector, N));
    float3 TangentY = cross(N, TangentX);
	// Tangent to world space
    return TangentX * H.x + TangentY * H.y + N * H.z;
}

float3 specularIBL(TextureCube EnvMap, SamplerState EnvMapSampler, float3 SpecularColor, float Roughness, float3 N, float3 V)
{
    float3 SpecularLighting = 0;
    const uint NumSamples = 50;
    for (uint i = 0; i < NumSamples; i++)
    {
        float2 Xi = Hammersley(i, NumSamples);
        float3 H = ImportanceSampleGGX(Xi, Roughness, N);
        float3 L = 2 * dot(V, H) * H - V;
        float NoV = saturate(dot(N, V));
        float NoL = saturate(dot(N, L));
        float NoH = saturate(dot(N, H));
        float VoH = saturate(dot(V, H));
        if (NoL > 0)
        {
            float3 SampleColor = EnvMap.SampleLevel(EnvMapSampler, L, 0).rgb;
            float G = G_Smith(Roughness, NoV, NoL);
            float Fc = pow(1 - VoH, 5);
            float3 F = (1 - Fc) * SpecularColor + Fc;
			
            //Incident_light = SampleColor * NoL;
			//Microfacet specular = D*G*F / (4*NoL*NoV)
			// pdf = D * NoH / (4 * VoH)
            
            SpecularLighting += SampleColor * F * G * VoH / (NoH * NoV);
        }
    }
    return max(SpecularLighting / NumSamples,0);
}

float3 diffuseIBL(TextureCube EnvMap, SamplerState EnvMapSampler, float3 SpecularColor, float Roughness, float3 N, float3 V)
{
    //there is problem here to calculate the diffuse,
    float3 IncidentLighting = 0;
    const uint NumSamples = 50;
    for (uint i = 0; i < NumSamples; i++)
    {
        float2 Xi = Hammersley(i, NumSamples);
        float3 H = ImportanceSampleGGX(Xi, 0.99, N);
        float3 L = 2 * dot(V, H) * H - V;
        float NoV = saturate(dot(N, V));
        float NoL = saturate(dot(N, L));
        float NoH = saturate(dot(N, H));
        float VoH = saturate(dot(V, H));
        if (NoL > 0)
        {
            float3 SampleColor = EnvMap.SampleLevel(EnvMapSampler, L, 0).rgb;
            IncidentLighting += SampleColor * NoL;
        }
    }
    return max(IncidentLighting / NumSamples, 0);
}

float3 fresnelSchlick( float NoV , float3 surfaceColor, float metalic)
{
    //fresnelSchlick
    float3 F0 = lerp(float3(0.04, 0.04, 0.04), surfaceColor, metalic);
    float NoV5 = pow(1 - NoV, 5);
    float3 F = F0 + (1 - F0) * NoV5;
    return F;
}

float NDF(float r2, float NoH)
{
    //Trowbridge-Reitz GGX
    float D = pow(r2, 2) / (PI * pow(pow(NoH, 2) * (pow(r2, 2) - 1) + 1, 2));
    return D;
}

float GSX(float NoV, float k)
{
    //Geometry Schlick-GGX
    return NoV / (NoV * (1 - k) + k);
}

float GS(float NoV, float NoL, float k)
{
    //Geometry Smith
    //NoV = max(NoV, 0);
    //NoL = max(NoL, 0);
    float GNoV = GSX(NoV, k);
    float GNoL = GSX(NoL, k);
    return GNoV * GNoL;
}

float Cook_Torrance(float r, float3 n, float3 l, float3 v, float3 h , float3 surfaceColor,float metalic)
{
    float r2 = r * r;
    float NoH = saturate(dot(n, h));
    float NoV = saturate(dot(n, v));
    float NoL = saturate(dot(n, l));

    float k_direct = pow(r2 + 1, 2) / 8;
    float k_ibl = pow(r2, 2) / 2;

    float D = NDF(r2, NoH);
    float3 F = fresnelSchlick(NoV, surfaceColor, metalic);
    float G = GS(NoV, NoL, k_direct);

    float s = D * F * G / (4 * NoL * NoV);
    return s;
}

float DisneyDiffuse(float NoV, float NoL, float LoH, float R2)
{
    float fd90 = 0.5 + 2 * LoH * LoH * R2;
    // Two schlick fresnel term
    float lightScatter = (1 + (fd90 - 1) * pow(1 - NoL, 5));
    float viewScatter = (1 + (fd90 - 1) * pow(1 - NoV, 5));

    return lightScatter * viewScatter;
}

#endif
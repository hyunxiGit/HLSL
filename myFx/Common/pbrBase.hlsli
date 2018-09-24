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

float NDF(float r2, float NoH)
{
    //Trowbridge-Reitz GGX
    float D = pow(r2, 2) / (PI * pow(pow(NoH, 2) * (pow(r2, 2) - 1) + 1, 2));
    return D;
}

float3 fresnelSchlick(float NoH, float3 surfaceColor, float metalic)
{
    //fresnel-Schlick
    float3 F0 = lerp(float3(0.04, 0.04, 0.04), surfaceColor, metalic);
    float NoV5 = pow(1 - NoH, 5);
    float3 F = F0 + (float3(1, 1, 1) - F0) * NoV5;
    return F;
}


float compute_lod(uint NumSamples, float NoH,float r2)
{
    float dist = NDF(r2,NoH); // Defined elsewhere as subroutine
    return 0.5 * (log2(float(512 * 512) / NumSamples) - log2(dist));
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
    //Hammersley 2d
    return float2(float(i) / float(N), RadicalInverse_VdC(i));
}

float3 ImportanceSampleGGX(float2 Xi, float Roughness, float3 N)
{
    float a = Roughness * Roughness;
    float Phi = 2 * PI * Xi.x;
    float CosTheta = sqrt((1 - Xi.y) / (1 + (a * a - 1) * Xi.y));
    float SinTheta = sqrt(1 - CosTheta * CosTheta);

    // from spherical coordinates to cartesian coordinates
    float3 H;
    H.x = SinTheta * cos(Phi);
    H.y = SinTheta * sin(Phi);
    H.z = CosTheta;

    //from tangent-space to world-space
    float3 UpVector = abs(N.z) < 0.999 ? float3(0, 0, 1) : float3(1, 0, 0);
    float3 TangentX = normalize(cross(UpVector, N));
    float3 TangentY = cross(N, TangentX);
	// Tangent to world space
    return TangentX * H.x + TangentY * H.y + N * H.z;
}

float3 irradianceSample(TextureCube EnvMap, SamplerState EnvMapSampler,float3 N)
{
    //this is the function that can be used in CPU instead of GPU
    float3 irradiance = float3(0, 0, 0);
    float3 up = float3(0, 1, 0);
    float3 right = cross(up,N);
    up = cross(right,N);

    float sampleDelta = 0.025;
    float nrSamples = 0;

    for (float phi = 0.0; phi < 2 * PI; phi +=sampleDelta)
    {
        for (float theta = 0.0; phi < PI/2; theta += sampleDelta)
        {
            //sphere to cartesian
            float3 tangentSample = float3(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));
            //tangent space to world
            float3 sampleVec = tangentSample.x * right + tangentSample.y * up + tangentSample.z * N;
            irradiance += EnvMap.Sample(EnvMapSampler, sampleVec).rgb * cos(theta) * sin(theta);
            nrSamples++;
        }
    }
    irradiance = PI * irradiance * (1 / nrSamples);
    return irradiance;
}

//float3 specularIBL(TextureCube EnvMap, SamplerState EnvMapSampler, float3 SpecularColor, float Roughness, float3 N, float3 V)
//{
//    float3 SpecularLighting = 0;
//    const uint NumSamples = 50;
//    for (uint i = 0; i < NumSamples; i++)
//    {
//        float2 Xi = Hammersley(i, NumSamples);
//        float3 H = ImportanceSampleGGX(Xi, Roughness, N);
//        float3 L = 2 * dot(V, H) * H - V;
//        float NoV = saturate(dot(N, V));
//        float NoL = saturate(dot(N, L));
//        float NoH = saturate(dot(N, H));
//        float VoH = saturate(dot(V, H));

//        if (NoL > 0)
//        {
//            float3 SampleColor = EnvMap.SampleLevel(EnvMapSampler, L, 0).rgb;
//            float G = G_Smith(Roughness, NoV, NoL);
//            float Fc = pow(1 - VoH, 5);
//            float3 F = (1 - Fc) * SpecularColor + Fc;
			
//            //Incident_light = SampleColor * NoL;
//			//Microfacet specular = D*G*F / (4*NoL*NoV)
//			// pdf = D * NoH / (4 * VoH)
            
//            SpecularLighting += SampleColor * F * G * VoH / (NoH * NoV);
//        }
//    }
//    return max(SpecularLighting / NumSamples,0);
//}

float3 diffuseIBL(TextureCube EnvMap, SamplerState EnvMapSampler, float3 N)
{
    float3 SampleColor = EnvMap.SampleLevel(EnvMapSampler, N, 8).rgb;
    return SampleColor;
}

void tempCorrection(inout float3 LDR)
{
    LDR = pow(LDR, 2.2);
}

float3 sampleIBL(TextureCube EnvMap, SamplerState EnvMapSampler, float3 surfaceColor, float metalic , float Roughness, float3 N, float3 V)
{
    float3 SpecularLighting = 0;
    const uint NumSamples = 50;
    for (uint i = 0; i < NumSamples; i++)
    {
        float2 Xi = Hammersley(i, NumSamples);
        float3 H = ImportanceSampleGGX(Xi, Roughness, N);
        float3 L = normalize(2 * dot(V, H) * H - V);
        float NoV = saturate(dot(N, V));
        float NoL = saturate(dot(N, L));
        float NoH = saturate(dot(N, H));
        float VoH = saturate(dot(V, H));

        float r2 = Roughness * Roughness;
        float k_direct = pow(r2 + 1, 2) / 8;

        float mipLevel = compute_lod(NumSamples, NoH, r2);

        if (NoL > 0)
        {
            float3 SampleColor = EnvMap.SampleLevel(EnvMapSampler, L, mipLevel).rgb;
            float G = GS(NoV, NoL, k_direct);
            float3 F = fresnelSchlick(NoH, surfaceColor, metalic);
			
            //Incident_light = SampleColor * NoL;
			//Microfacet specular = D*G*F / (4*NoL*NoV)
			// pdf = D * NoH / (4 * VoH)
            
            SpecularLighting += SampleColor * F * G * VoH / (NoH * NoV);
        }
    }
    return max(SpecularLighting / NumSamples, 0);
}

struct IBL_BRDFOUT
{
    float3 preC;
    float3 A;
    float3 B;
};


IBL_BRDFOUT sampleIBL_BRDF(TextureCube EnvMap, SamplerState EnvMapSampler, float3 surfaceColor, float metalic, float Roughness, float3 N, float3 V)
{
    IBL_BRDFOUT OUT;
    float3 SpecularLighting = 0;
    const uint NumSamples = 50;

    for (uint i = 0; i < NumSamples; i++)
    {
        float2 Xi = Hammersley(i, NumSamples);
        float3 H  = ImportanceSampleGGX(Xi, Roughness, N);
        float3 L  = normalize(2 * dot(V, H) * H - V);
        float NoV = saturate(dot(N, V));
        float NoL = saturate(dot(N, L));
        float NoH = saturate(dot(N, H));
        float VoH = saturate(dot(V, H));

        float r2 = Roughness * Roughness;
        float k_ibl = r2 *r2 / 8;

        //this should be used if the mipmap is embeded roughness
        //float mipLevel = compute_lod(NumSamples, NoH, r2);
        float mipLevel = 0;

        if (NoL > 0)
        {
            float3 SampleColor = EnvMap.SampleLevel(EnvMapSampler, L, mipLevel).rgb;
            float G = GS(NoV, NoL, k_ibl);
            float3 F = fresnelSchlick(NoH, surfaceColor, metalic);
			
            //Incident_light = SampleColor * NoL;
			//Microfacet specular = D*G*F / (4*NoL*NoV)
			// pdf = D * NoH / (4 * VoH)
            
            SpecularLighting += SampleColor * F * G * VoH / (NoH * NoV);
            //new
            float G_Vis = G * VoH / (NoH * NoV);
            float Fc = pow(1 - VoH, 5);
            OUT.A += (1 - Fc) * G_Vis;
            OUT.B += Fc * G_Vis;
        }
    }
    OUT.A /= float(NumSamples);
    OUT.B /= float(NumSamples);
    OUT.preC = max(SpecularLighting / NumSamples, 0);
    return OUT;
}


float3 fresnelSchlickRoughness(float cosTheta, float3 surfaceColor, float metalic, float roughness)
{
    float3 F0 = lerp(float3(0.04, 0.04, 0.04), surfaceColor, metalic);
    float cosTheta5 = pow(1 - cosTheta, 5);
    float rr = 1.0 - roughness ;
    float3 F = F0 + (max(float3(rr, rr, rr), F0) - F0) * cosTheta5;
    return F;
}




struct BRDFOUT
{
    float3 specular;
    float3 Ks;
    float3 Kd;
};

BRDFOUT BRDF(float r, float3 n, float3 l, float3 v, float3 h, float3 surfaceColor, float metalic)
{
    //Cook_Torrance
    BRDFOUT OUT;
    float r2 = r * r;
    float NoH = max(dot(n, h), 0);
    float NoV = max(dot(n, v), 0);
    float NoL = max(dot(n, l), 0);

    float k_direct = pow(r2 + 1, 2) / 8;
    float k_ibl = pow(r2, 2) / 2;

    float D = NDF(r2, NoH);
    float3 F = fresnelSchlick(NoH, surfaceColor, metalic);
    float G = GS(NoV, NoL, k_direct);

    OUT.specular = D * F * G / max(4 * NoL * NoV, 0.001f);

    //specular & diffuse contributer
    OUT.Ks = F;
    OUT.Kd = float3(1, 1, 1) - OUT.Ks;
    OUT.Kd *= 1 - metalic;
    
    return OUT;
}

float DisneyDiffuse(float NoV, float NoL, float LoH, float R2)
{
    float fd90 = 0.5 + 2 * LoH * LoH * R2;
    // Two schlick fresnel term
    float lightScatter = (1 + (fd90 - 1) * pow(1 - NoL, 5));
    float viewScatter = (1 + (fd90 - 1) * pow(1 - NoV, 5));

    return lightScatter * viewScatter;
}

// lighting models

float pLightAtt(float3 P, float3 L)
{
    //invers square att
    float distance = length(L - P);
    return 1.0 / (distance * distance);
}
float3 pointLight(float3 lColor, float3 N , float3 L , float3 P )
{
    float3 Wi = normalize(L - P);
    float cosTheta = max(dot(N, Wi), 0);
    float attenuation = pLightAtt(P,L);
    float3 radiance = lColor * attenuation * cosTheta;
    return radiance;
}

void gammarCorrect( inout float3 input)
{
    float R = 1 / 2.2;
    input = input / (input + float3(1, 1, 1));
    input = pow(input, float3(R,R,R));
}
#endif
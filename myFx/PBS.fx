#include "Common/Common.hlsli"

SCRIPT_FX("Technique=Main_11;")

DECLARE_COLOR(abedo, float4(1,0.88,0.61,1), "abedo color")
DECLARE_FLOAT(roughness, 0,1,0.5,"roughness")
DECLARE_FLOAT(metalness, 0,1,1,"metalness")
DECLARE_FLOAT(F0, 0,1,0.5,"fresnel")
DECLARE_LIGHT(myLight, "PointLight0", "Light Position", 0)
DECLARE_CUBE(EnvMap, EnvMapSampler, "Reflection")


struct VS_IN
{
    float4 P_O : POSITION;
    float3 N_O : NORMAL;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 P_P : SV_POSITION;
    float2 uv :  TEXCOORD0;
    float3 N_W : TEXCOORD1;
    float4 P_W : TEXCOORD2;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.P_P = mul(IN.P_O, wvp);
    OUT.P_W = mul(IN.P_O, world);
    OUT.N_W = normalize(mul(IN.N_O, (float3x3) worldI));
    return OUT;
}
float GlV(float NoV, float k)
{
    return NoV / (NoV * (1 - k) + k);
}

float G_Smith(float r, float NoV, float NoL)
{
    float k = (r + 1) * (r + 1) / 8;
    float G = GlV(NoV, k) * GlV(NoL, k);
    return G;
}

float Cook_Torrance(float r, float3 n , float3 l , float3 v, float3 h )
{   
    float r2 = r * r;
    float NoH = dot(n, h);
    float NoV = dot(n, v);
    float NoL = dot(n, l);

    //NDF
	float D = pow(r2, 2) / (PI * pow(pow(NoH, 2) * (pow(r2, 2) - 1) + 1, 2));
	//G
    float k = (r + 1) * (r + 1) / 8;
    float G = GlV(NoV, k) * GlV(NoL, k);
	//Fresnel
    float NoL5 = pow(1 - dot(l, h), 5);
    float F = F0 + (1 - F0) * NoL5;
    
    float s = D * F * G / (4 * NoL *NoV);
	return s;
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

float3 specularIBL(float3 SpecularColor, float Roughness, float3 N, float3 V)
{
    float3 SpecularLighting = 0;
    const uint NumSamples = 1024;
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
			// Incident light = SampleColor * NoL
			// Microfacet specular = D*G*F / (4*NoL*NoV)
			// pdf = D * NoH / (4 * VoH)
            SpecularLighting += SampleColor * F * G * VoH / (NoH * NoV);
        }
    }
    return SpecularLighting / NumSamples;
}


float3 specularIBLTEST(float3 SpecularColor, float Roughness, float3 N, float3 V)
{
    float3 SpecularLighting = 0;
    const uint NumSamples = 2;
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
			// Incident light = SampleColor * NoL
			// Microfacet specular = D*G*F / (4*NoL*NoV)
			// pdf = D * NoH / (4 * VoH)
            SpecularLighting += SampleColor * F * G * VoH / (NoH * NoV);
        }
    }
    return SpecularLighting / NumSamples;
}


float4 PS(PS_IN IN) : SV_Target
{
    int lightModel = 2; //0, blinn; 1 , phon ; 2 ,BRDF
    float4 COL = { 1, 0, 1, 1 };
    float4 A = abedo;
    float3 L = normalize(myLight);
    float3 N = IN.N_W;
    float3 V = normalize((viewI[3] - IN.P_W).xyz);
    float3 H = normalize(V + L);
    float NoL = dot(N, L);

    float4 D = float4(0, 0, 0, 0);
    float4 S = float4(0, 0, 0, 0);
    float3 R = -L - 2 * dot(N, -L) * N;
    
    if (NoL > 0)
    {
		D =  NoL;
        if (lightModel == 0)
        {
            float3 R = -L - 2 * dot(N, -L) * N;
            S = dot(R, V);
        }
        else if (lightModel == 1)
        {
            S = dot(N, H);
            S = pow(S, 20);
        }
        else if (lightModel == 2)
        {
            S = Cook_Torrance(roughness, N , L , V, H );
        }
    }
    
    COL.xyz = specularIBLTEST(float3(1, 1, 1), roughness, N, V);

        

    //COL.xyz = D * A + S;
    COL.w = 1;

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
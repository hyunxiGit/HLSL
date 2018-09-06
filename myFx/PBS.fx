#include "Common/Common.hlsli"

SCRIPT_FX("Technique=Main_11;")

DECLARE_COLOR(abedo, float4(1,0.88,0.61,1), "abedo color")
DECLARE_FLOAT(roughness, 0.05, 0.99, 0.5, "roughness")
DECLARE_FLOAT(metalness, 0, 1, 1, "metalness")
DECLARE_FLOAT(F0, 0, 1, 0.5, "fresnel")
DECLARE_LIGHT(myLight, "PointLight0", "Light Position", 0)
DECLARE_CUBE(EnvMap, EnvMapSampler, "cube")
DECLARE_FLOAT(EnvI, 0, 1, 0.5f, "cube intensity")

struct VS_IN
{
    float4 P_O : POSITION;
    float3 N_O : NORMAL;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 P_P : SV_POSITION;
    float2 uv : TEXCOORD0;
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
    //float k = (r + 1) * (r + 1) / 8;
    float k = sqrt(2 * pow(r, 2) / PI);
    float G = GlV(NoV, k) * GlV(NoL, k);
    return G;
    //float R2 = r * r;
    //float G_V = NoV + sqrt((NoV - NoV * R2) * NoV + R2);
    //float G_L = NoL + sqrt((NoL - NoL * R2) * NoL + R2);
    //return rcp(G_V * G_L);
}


float Cook_Torrance(float r, float3 n, float3 l, float3 v, float3 h)
{
    float r2 = r * r;
    float NoH = saturate(dot(n, h));
    float NoV = saturate(dot(n, v));
    float NoL = saturate(dot(n, l));

    //NDF
    //float D = pow(r2, 2) / (PI * pow(pow(NoH, 2) * (pow(r2, 2) - 1) + 1, 2));
    float D = pow(r2, 2) / (PI * pow(pow(NoH, 2) * (pow(r2, 2) - 1) + 1, 2));
	//G
    float G = G_Smith(r, NoV, NoL);

	//Fresnel
    float NoL5 = pow(1 - dot(l, h), 5);
    float F = F0 + (1 - F0) * NoL5;
    
    float s = D * F * G /*/ (4 * NoL * NoV)*/;
    //s = G;
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
    return SpecularLighting / NumSamples;
}

float3 diffuseIBL(float3 SpecularColor, float Roughness, float3 N, float3 V)
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
    return IncidentLighting / NumSamples;
}

float DisneyDiffuse(float NoV , float NoL , float LoH , float R2)
{
    float fd90 = 0.5 + 2 * LoH * LoH * R2;
    // Two schlick fresnel term
    half lightScatter = (1 + (fd90 - 1) * pow(1 - NoL,5));
    half viewScatter = (1 + (fd90 - 1) * pow(1 - NoV,5));

    return lightScatter * viewScatter;
}

float4 PS(PS_IN IN) : SV_Target
{
    int lightModel = 2; //0, blinn; 1 , phon ; 2 ,BRDF
    int useIBL = 1;
    float4 COL = { 1, 0, 1, 1 };
    float4 A = abedo;
    float3 L = normalize(myLight);
    float3 N = IN.N_W;
    float3 V = normalize((viewI[3] - IN.P_W).xyz);
    float3 H = normalize(V + L);
    float NoL = dot(N, L);

    float4 D = float4(0, 0, 0, 0);
    float4 S = float4(0, 0, 0, 0);

    float4 SC = lerp(DielectricSpec, A, metalness);
    float4 DC = A * (DielectricSpec.a * (1 - metalness));
    
    if (NoL > 0)
    {
        float3 R = -L - 2 * dot(N, -L) * N;
        if (lightModel == 0)
        {
            D = NoL;
            float3 R = -L - 2 * dot(N, -L) * N;
            S = dot(R, V);
        }
        else if (lightModel == 1)
        {
            D = NoL;
            S = dot(N, H);
            S = pow(S, 20);
        }
    }

    if (lightModel == 2)
    {
        float NoV = saturate(dot(N, V));
        float NoL = saturate(dot(N, L));
        float NoH = saturate(dot(N, H));
        float VoH = saturate(dot(V, H));
        float LoH = saturate(dot(L, H));
        float R2 = roughness * roughness;

        //metalness = 0;
        D += NoL;
        // D = DisneyDiffuse(NoV, NoL, LoH, R2);
        S += Cook_Torrance(roughness, N, L, V, H);
        if (useIBL == 1)
        {
            S.xyz += S.xyz + EnvI * specularIBL(float3(1, 1, 1), roughness, N, V) ;
            D.xyz += diffuseIBL(float3(1, 1, 1), roughness, N, V) ;
        }
        if (metalness == 1)
        {
            D = 0;
        }
        COL = D * DC + S * SC;
    }

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
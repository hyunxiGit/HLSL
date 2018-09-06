#include "Common/Common.hlsli"

SCRIPT_FX("Technique=Main_11;")

DECLARE_COLOR(abedo, float4(1,0.85,0.61,1), "abedo color")
DECLARE_FLOAT(roughness, 0.05, 0.99, 0.5, "roughness")
DECLARE_FLOAT(metalness, 0, 1, 1, "metalness")
DECLARE_FLOAT(F0, 0, 1, 0.5, "fresnel")
DECLARE_LIGHT(myLight, "PointLight0", "Light Position", 0)
DECLARE_FLOAT(EnvI, 0, 1, 0.5f, "cube intensity")


#define BASE_A "D:/work/HLSL/texture/dettail_a.png"
#define BASE_N "D:/work/HLSL/texture/dettail_n.png"
#define BASE_R "D:/work/HLSL/texture/dettail_r.png"
#define BASE_M "D:/work/HLSL/texture/dettail_m.png"
#define CUBE_M   "D:/work/HLSL/texture/default_reflection_cubic.dds"

DECLARE_FLOAT(useMap, 0, 1, 1, "use map")


DECLARE_CUBE(EnvMap, EnvMapSampler, CUBE_M, "cube")
TEXTURE2D(Amap, a_Sampler, BASE_A, "abedo")
TEXTURE2D(Nmap, n_Sampler, BASE_N, "normal")
TEXTURE2D(Rmap, r_Sampler, BASE_R, "roughness")
TEXTURE2D(Mmap, m_Sampler, BASE_M, "metalness")

struct VS_IN
{
    float4 P_O : POSITION;
    float3 N_O : NORMAL;
    float3 T : TANGENT;
    float3 B : BINORMAL;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 P_P : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 P_W : TEXCOORD1;
    float3 N_O : TEXCOORD2;
    float3 B_O : TEXCOORD3;
    float3 T_O : TEXCOORD4;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.P_P = mul(IN.P_O, wvp);
    OUT.P_W = mul(IN.P_O, world);
    OUT.N_O = IN.N_O;
    OUT.uv = IN.uv;
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

float DisneyDiffuse(float NoV, float NoL, float LoH, float R2)
{
    float fd90 = 0.5 + 2 * LoH * LoH * R2;
    // Two schlick fresnel term
    half lightScatter = (1 + (fd90 - 1) * pow(1 - NoL, 5));
    half viewScatter = (1 + (fd90 - 1) * pow(1 - NoV, 5));

    return lightScatter * viewScatter;
}


float4 PS(PS_IN IN) : SV_Target
{

    float3x3 objToTangentSpace;
    objToTangentSpace[0] = IN.B_O;
    objToTangentSpace[1] = IN.T_O;
    objToTangentSpace[2] = IN.N_O;

    float4 Ab = lerp(abedo, Amap.Sample(a_Sampler, IN.uv), useMap);
    float Ro = lerp(roughness, Rmap.Sample(r_Sampler, IN.uv), useMap);
    float Me = lerp(metalness, Amap.Sample(m_Sampler, IN.uv), useMap);
    float3 nMap = mul(objToTangentSpace,texture_to_vector(Nmap.Sample(n_Sampler, IN.uv).xyz));
    float3 No = mul(lerp(IN.N_O, normalize(float3(IN.N_O.xy + nMap.xy, IN.N_O.z)), useMap),(float3x3)worldI);
    //No = mul(IN.N_O, (float3x3) worldI);

    int lightModel = 2; //0, blinn; 1 , phon ; 2 ,BRDF
    int useIBL = 1;
    float4 COL = { 0, 0, 1, 1 };
    float3 L = normalize(myLight);
    float3 N = No;
    float3 V = normalize((viewI[3] - IN.P_W).xyz);
    float3 H = normalize(V + L);
    float NoL = dot(N, L);

    float4 D = float4(0, 0, 0, 0);
    float4 S = float4(0, 0, 0, 0);

    float4 SC = lerp (DielectricSpec, Ab, Me);
    float4 DC = Ab * (DielectricSpec.a * (1 - Me));
    

    if (lightModel == 2)
    {
        float NoV = saturate(dot(N, V));
        float NoL = saturate(dot(N, L));
        float NoH = saturate(dot(N, H));
        float VoH = saturate(dot(V, H));
        float LoH = saturate(dot(L, H));
        float R2 = Ro * Ro;

        if (NoL > 0)
        {
            D += NoL;
            S += Cook_Torrance(Ro, N, L, V, H);
        }

        if (useIBL == 1)
        {
            S.xyz +=  EnvI * specularIBL(float3(1, 1, 1), Ro, N, V);
            D.xyz +=  EnvI * diffuseIBL(float3(1, 1, 1), Ro, N, V);
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
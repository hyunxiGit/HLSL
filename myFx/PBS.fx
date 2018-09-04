#include "Common/Common.hlsli"

SCRIPT_FX("Technique=Main_11;")

DECLARE_COLOR(abedo, float4(1,0.88,0.61,1), "abedo color")
DECLARE_FLOAT(roughness, 0,1,0.5,"roughness")
DECLARE_FLOAT(metalness, 0,1,1,"metalness")
DECLARE_FLOAT(F0, 0,1,0.5,"fresnel")
DECLARE_LIGHT(myLight, "PointLight0", "Light Position", 0)

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

float Cook_Torrance(float r, float3 n , float3 l , float3 v, float3 h )
{   
    float r2 = r * r;
    float NoH = dot(n, h);
    float NoV = dot(n, v);
    float NoL = dot(n, l);

    //NDF
	float D = pow(r2, 2) / (Pi * pow(pow(NoH, 2) * (pow(r2, 2) - 1) + 1, 2));
	//G
    float k = (r + 1) * (r + 1) / 8;
    float G = GlV(NoV, k) * GlV(NoL, k);
	//Fresnel
    float NoL5 = pow(1 - dot(l, h), 5);
    float F = F0 + (1 - F0) * NoL5;
    
    float s = D * F * G / (4 * NoL *NoV);
	return s;
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
        

    COL.xyz = D * A + S;
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
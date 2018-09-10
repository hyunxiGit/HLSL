#include "Common/Common.hlsli"

SCRIPT_FX("Technique=Main_11;")

#define BASE_N "C:\\MyGit\\HLSL\\texture\\normal1.png"
#define BASE_N1 "C:\\MyGit\\HLSL\\texture\\normal2.png"
DECLARE_FLOAT(mode, 0, 10, 0, "normal mode")
DECLARE_LIGHT(myLight, "PointLight0", "Light Position", 0)
TEXTURE2D(Nmap, n_Sampler, BASE_N, "normal")
TEXTURE2D(N1map, n1_Sampler, BASE_N1, "normal")

struct VS_IN
{
    float4 P : POSITION;
    float3 N : NORMAL;
    float3 B : BINORMAL;
    float3 T : TANGENT;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 N : TEXCOORD1;
    float3 B : TEXCOORD2;
    float3 T : TEXCOORD3;
    float3 P : TEXCOORD4;
    float3 V : TEXCOORD5;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.uv = IN.uv;
    OUT.pos = mul(IN.P, wvp);
    OUT.P = mul(IN.P, world);
    OUT.N = normalize(mul(IN.N, world));
    OUT.T = normalize(mul(IN.T, world));
    OUT.B = normalize(mul(IN.B, world));
    OUT.V = normalize(viewI[3].xyz - OUT.P);
    return OUT;
}

void applyN(inout float3 NM, float3 B, float3 T, float3 N)
{
    NM = normalize(1 * (NM.x * T + NM.y * B) + NM.z * N);
}

float4 PS(PS_IN IN) : SV_Target
{
    float3 N = IN.N;
    float4 COL = { 1, 0, 0, 1 };
    float3 L = normalize(myLight - IN.P);
    float4 n1 = Nmap.Sample(n_Sampler, IN.uv)*2-1;
    float4 n2 = N1map.Sample(n1_Sampler, IN.uv) * 2 - 1;

    n1.g = -n1.g;
    n2.g = -n2.g;

    if (mode ==0)
    {
        N = n2;
    }
    else if (mode == 1)
    {
        N = n1;

    }
    else if (mode ==2)
    {
        //fade between normal
        N = normalize(float3(n1.xy * n2.z + n2.xy * n1.z, n1.z * n2.z));
    }
    else if (mode == 3)
    {
        //whiteout
        N = normalize(float3(n1.xy  + n2.xy, n1.z * n2.z));
    }
    else if (mode ==4)
    {
        //unity

        float3x3 nBasis = float3x3(
        float3(n1.z, n1.y, -n1.x), // +90 degree rotation around y axis
        float3(n1.x, n1.z, -n1.y), // -90 degree rotation around x axis
        float3(n1.x, n1.y, n1.z));

        float3 r = normalize(n2.x * nBasis[0] + n2.y * nBasis[1] + n2.z * nBasis[2]);
        N = r * 0.5 + 0.5;
    }
    else if (mode == 5)
    {
        n1.g = -n1.g;
        n2.g = -n2.g;
        float a = 1 / (1 + n1.z);
        float b = -n1.x * n1.y * a;

        // Form a basis
        float3 b1 = float3(1 - n1.x * n1.x * a, b, -n1.x);
        float3 b2 = float3(b, 1 - n1.y * n1.y * a, -n1.y);
        float3 b3 = n1;

        if (n1.z < -0.9999999) // Handle the singularity
        {
            b1 = float3(0, -1, 0);
            b2 = float3(-1, 0, 0);
        }

        // Rotate n2 via the basis
        float3 r = n2.x * b1 + n2.y * b2 + n2.z * b3;

        N =  r * 0.5 + 0.5;
    }
    else if (mode ==6 )
    {
        float3 t = Nmap.Sample(n_Sampler, IN.uv).xyz * float3(2, 2, 2) + float3(-1, -1, 0);
        float3 u = N1map.Sample(n1_Sampler, IN.uv).xyz * float3(-2, -2, 2) + float3(1, 1, -1);
        float3 r = t * dot(t, u) / t.z - u;
        N = r * 0.5 + 0.5;
    }
    applyN(N, IN.B, IN.T, IN.N);
    
    COL = dot(N, L);
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
//#include "Common/Common.hlsli"
//#include "Common/shadowMap.hlsli"
#define BASE_N "D:/work/HLSL/texture/pbrT_n.png"
TEXTURE2D(Nmap, n_Sampler, BASE_N, "normal")

SCRIPT_FX("Technique=Main_11;")

DECLARE_FLOAT(myFloat, 0, 1, 0.5, "my float")
DECLARE_COLOR(myColor, float4(1,1,1,1), "my color")
DECLARE_LIGHT(myLight, "PointLight0", myLightColor, "Light Position", 0)
struct VS_IN
{
    float4 pos : POSITION;
    float3 N : NORMAL;
    float3 T : TANGENT;
    float3 B : BINORMAL;
    float2 uv : TEXCOORD0;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv :  TEXCOORD0;
    float3 N : TEXCOORD1;
    float3 B : TEXCOORD3;
    float3 T : TEXCOORD4;
};

PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.uv = IN.uv;
    OUT.N = IN.N;
    OUT.B = IN.B;
    OUT.T = IN.T;
    return OUT;
}

float4 PS(PS_IN IN) : SV_Target
{
    float4 COL = { 1, 1, 1, 1 };
    float4 NMap = Nmap.Sample(n_Sampler, IN.uv);
    //COL = NMap;

    float3x3 objToTangentSpace;
    objToTangentSpace[0] = IN.B;
    objToTangentSpace[1] = IN.T;
    objToTangentSpace[2] = IN.N;

    float3 N = mul(NMap.xyz, objToTangentSpace);
    N = mul(normalize(float3(IN.N.xy + N.xy, IN.N.z)), world);
    COL.xyz = dot(N, normalize(myLight));
    COL = myColor;
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
#include "Common/colorBaseBlending.hlsli"
#include "Common/Common.hlsli"

#define BASE_A "D:/work/HLSL/texture/blendBase.png"
#define BASE_A1 "C:\\Users\\hyunx\Desktop\\detailMap\\max\\texture\\reverbank_d.tga"
//d1
#define D1_A "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\concrete_a.png"
//d2
#define D2_A "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\oiloP_4K_Albedo.jpg"
//d3
#define D3_A "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\pjuu52_8K_Albedo.jpg"
//d4
#define D4_A "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\pjEfn2_4K_Albedo.jpg"

#define da 4
#define da_ 5

SCRIPT_FX("Technique=Main;")

//lights
DECLARE_LIGHT(Lamp0Pos, "PointLight0", Lamp0Col, "Light Position", 0)

//base map
TEXTURE2D_UI(blendBase, blendBaseSampler, BASE_A, "Base Map", 0)
//blending parameters
DECLARE_FLOAT_UI(n, 0.0f, 15.0f, 8, "blend power", 1)
DECLARE_FLOAT_UI(m, 0.0f, 1.0f, 0.0f, "blend strength", 2)

DECLARE_BOOL_UI(detailColor, "Use detail Map Color", 3)

//detail 1
DECLARE_COLOR_UI(d1HSV, float4(0.75f, 0.725f, 0.71f, 1.0f), "d1", 4)
TEXTURE2D_UI(d1aMap, d1aMap_Sampler, BASE_A1, "d1", 5)

//detail 2
DECLARE_COLOR_UI(d2HSV, float4(0.09f, 0.341f, 0.231f, 1.0f), "d2", 6)
TEXTURE2D_UI(d2aMap, d2aMap_Sampler, D2_A, "d2", 7)

//detail 3
DECLARE_COLOR_UI(d3HSV, float4(0.09f, 0.056f, 0.02f, 1.0f), "d3", 8)
TEXTURE2D_UI(d3aMap, d3aMap_Sampler, D3_A, "d3", 9)

//detail 4
DECLARE_COLOR_UI(d4HSV, float4(0.404f, 0.153, 0.435f, 1.0f), "d4", 10)
TEXTURE2D_UI(d4aMap, d4aMap_Sampler, D4_A, "d4", 11)

//how to use vertex color
DECLARE_INT_UI(VM, "vertext mode" , 0,2,12)
//blend mode
DECLARE_INT_UI(BM, "blend mode" , 0,2,13)


DECLARE_FLOAT_UI(d1H, 0.0f, 10.0f, 9, "d1 height", 14)
DECLARE_FLOAT_UI(d2H, 0.0f, 10.0f, 6, "d2 height", 15)
DECLARE_FLOAT_UI(d3H, 0.0f, 10.0f, 3, "d3 height", 16)

struct VS_IN
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
    float3 nor : NORMAL;
    float4 col : COLOR;
};

struct PS_IN
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 p_w : TEXCOORD1;
    float3 viw : TEXCOORD2;
    float3 nor : TEXCOORD3;
    float4 col : TEXCOORD4;
};


PS_IN VS(VS_IN IN)
{
    PS_IN OUT = (PS_IN) 0;
    float3 pw = mul(IN.pos, world).xyz;
    OUT.pos = mul(IN.pos, wvp);
    OUT.p_w = mul(IN.pos, world);
    OUT.uv = IN.uv;
    OUT.viw.xyz = normalize((viewI[3].xyz - pw).xyz);
    OUT.nor = normalize(mul(IN.nor, world));
    OUT.col = IN.col;
    return (OUT);
}


void getWeight(float4 baseColor, inout float weight[2])
{
    float4 col;
    float3 bHSV = RGBtoHSV(baseColor.rgb);

    //calculate distance 

    float3 detailVec[2] = { RGBtoHSV(d1HSV.xyz), RGBtoHSV(d2HSV.xyz) };
    float distance[2] = { 0, 0 };
    float C = 0;
    
    for (int i = 0; i < 2; i++)
    {
        float3 v;
        v.x = bHSV.x - detailVec[i].x;
        v.y = bHSV.y - detailVec[i].y;
        v.z = bHSV.z - detailVec[i].z;

        v.x = min(v.x, 1.0 - v.x);

        float dis = 1.0f / pow(dot(v, v), n);
        distance[i] = dis;
        C += dis;
    }

    for (int j = 0; j < 2; j++)
    {
        weight[j] = saturate(distance[j] / C);
    }
}

void getWeightImg(float4 baseColor, float4 vertexColor, int C, inout float weight[2])
{
	//this is the blending meathod with vertex color
    float a = saturate(vertexColor.r + vertexColor.g + vertexColor.b);
    
    if (C == 0)
    {
        //use color
        float4 b_v = float4(baseColor.xyz * (1 - a) + a * vertexColor.zyx, baseColor.w);
        getWeight(b_v, weight);
    }
    else if (C == 1)
    {
        //use channel
        float3 V1 = d1HSV * vertexColor.b;
        float3 V2 = d2HSV * vertexColor.g;
        float4 b_v = float4(baseColor.xyz * (1 - a) + V1 + V2, 1);
        getWeight(b_v, weight);
    }
}

float3 baseMap_vertexColor(float4 baseColor, float4 vertexColor, int mode)
{
    float3 result;
    float a = saturate(vertexColor.r + vertexColor.g + vertexColor.b);
    if (mode == 1)
    {
        //use color
        result = float4(baseColor.xyz * (1 - a) + a * vertexColor.zyx, baseColor.w);
    }
    else if (mode == 2)
    {
        //use channel
        float3 V1 = d1HSV * vertexColor.b;
        float3 V2 = d2HSV * vertexColor.g;
        float3 V3 = d3HSV * vertexColor.r;
        result = float4(baseColor.xyz * (1 - a) + V1 + V2+V3, 1);
    }
    return result;
}

float3 overlayBlend(float3 a, float3 b)
{
    float3 r;
    if (a.r + a.g + a.b < 1.5)
    {
        r = 2 * a * b;
    }
    else
    {
        r = 1 - 2 * (1 - a) * (1 - b);
    }
    saturate(r);
    return r;
}

float3 blendByColor(float4 b_a, float4 d1_a, float4 d2_a, float4 d3_a, float4 d4_a, float4 vertextCol)
{
    float3 diffuse = float3(0, 0, 0);
    float4 base;
    base = b_a;
    float blend0 = 1.0f - m;
    float blend1 = m;

	//vertex color
    if (VM != 0)
    {
        base.xyz = baseMap_vertexColor(b_a, vertextCol, VM);

    }
	
    //prepare detail map
    float weight1[da] = { 0, 0, 0, 0 };
    weightData wd;
    wd.weight = weight1;
    wd.blendPower = n;

    wd.blendColor[0] = base;
    wd.blendColor[1] = d1HSV;
    wd.blendColor[2] = d2HSV;
    wd.blendColor[3] = d3HSV;
    wd.blendColor[4] = d4HSV;

    getWeight1(wd);

    //abedo


    //color
    //diffuse = b_a * blend0 + (d1_a * weight1[0] + d2_a * weight1[1]) * blend1;
  
    
    if (BM == 0)
    {
		//debug
        diffuse = wd.weight[0] * d1HSV + wd.weight[1] * d2HSV + wd.weight[2] * d3HSV + wd.weight[3] * d4HSV;

    }
    else if (BM == 1)
    {
		//color map
        diffuse = wd.weight[0] * d1_a + wd.weight[1] * d2_a + wd.weight[2] * d3_a + wd.weight[3] * d4_a;
    }
    if (!detailColor)
    {
        //grey
        float grey = (diffuse.x + diffuse.y + diffuse.z) / 3;
        diffuse = b_a.xyz * blend0 + overlayBlend(b_a.xyz, grey) * blend1;
    }

    diffuse = b_a.xyz * blend0 + diffuse * blend1;
    return diffuse;

}

float3 anchorDistribute(float M, float f1h, float f2h, float f3h)
{
    float3 diffuse = float3(0, 0, 0);
    float4 diffuse1 = float4(0, 0, 0, 0);

    if (M > f1h)
    {
        float N = linearMap(M, f1h, 1);
        diffuse = COLOR_R * N + COLOR_Y * (1 - N);
    }
    if (M < f1h && M > f2h)
    {
        float N = linearMap(M, f2h, f1h);
        diffuse = COLOR_Y * N + COLOR_G * (1 - N);
    }
    if (M < f2h && M > f3h)
    {
        float N = linearMap(M, f3h, f2h);
        diffuse = COLOR_G * N + COLOR_C * (1 - N);
    }
    if (M < f3h)
    {
        float N = linearMap(M, 0, f3h);
        diffuse = COLOR_C * N + COLOR_B * (1 - N);
    }
    return diffuse;
}

float3 blendByHeight(float height)
{
    //9.784 , 5.064 ,3.336
    //use heigh map to blend
    float f1h = d1H / 10.0f;
    float f2h = d2H / 10.0f;
    float f3h = d3H / 10.0f;
    float3 diffuse = anchorDistribute(height, f1h, f2h, f3h);
    return diffuse;
}

float3 blendByNormal(float NoU)
{
    //use heigh map to blend
    //10.0 , 8.368 , 5.732
    
    float f1h = d1H / 10.0f;
    float f2h = d2H / 10.0f;
    float f3h = d3H / 10.0f;
    float3 diffuse = anchorDistribute(NoU, f1h, f2h, f3h);
    return diffuse;
    return diffuse;
}

float4 PS_VERTEX(PS_IN IN, uniform int C) : SV_Target
{
	//M : blend meathod
    float4 col;
    float3 diffuse = float3(0, 0, 0);

    //maps
    int UVscale = 15;
    float4 blendmaps[da_];
    float4 b_a = blendBase.Sample(blendBaseSampler, IN.uv);  
    float4 d1_a = d1aMap.Sample(d1aMap_Sampler, IN.uv * UVscale);
    float4 d2_a = d2aMap.Sample(d2aMap_Sampler, IN.uv * UVscale);
    float4 d3_a = d3aMap.Sample(d3aMap_Sampler, IN.uv * UVscale);
    float4 d4_a = d4aMap.Sample(d4aMap_Sampler, IN.uv * UVscale);

	//blend meathods
    if (BM == 0)
    {
        diffuse = blendByColor(b_a, d1_a, d2_a, d3_a, d4_a, IN.col);
    }
    else if (BM == 1)
    {
		//use heigh to blend
        diffuse = blendByHeight(b_a.a);
    }
    else if (BM == 2)
    {
		//use normal
        float NoU = dot(IN.nor, float3(0, 0, 1));
        diffuse = blendByNormal(NoU);
    }
        
    //normal
    float3 N = IN.nor;

    //lighting
    float3 A = float3(0.36f, 0.37f, 0.38f) * 0.01;
    float3 L = normalize(Lamp0Pos - IN.p_w);
    float3 V = IN.viw;

    float3 Hn = normalize(L + V);

    float4 litV = lit(dot(L, N), dot(Hn, N), 5);
    float3 D = litV.y * diffuse;
    float3 S = litV.y * litV.z  * (diffuse * 0.5 + float3(1, 1, 1) * 0.5);

    col.xyz = D;

    col.w = 1;
    return col;
}


fxgroup dx11
{

technique11 VertexByColor<
            string script = "Pass = p0;";
            >
{
    pass p0 <
            string Script = "Draw=geometry;";
            >
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, PS_VERTEX(0)));
    }
}

technique11 VertexByChannel<
                string script = "Pass = p0;";
                >
{
    pass p0 <
                string Script = "Draw=geometry;";
                >
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, PS_VERTEX(1)));
    }
}


}
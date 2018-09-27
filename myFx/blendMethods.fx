#include "Common/colorBaseBlending.hlsli"
#include "Common/Common.hlsli"

#define BASE_A1 "C:\\Users\\hyunx\Desktop\\detailMap\\max\\texture\\reverbank_d.tga"
#define BASE_A2 "C:\\Users\\hyunx\Desktop\\detailMap\\max\\texture\\reverbank_do.tga"
#define BASE_N "C:\\Users\\hyunx\Desktop\\detailMap\\max\\texture\\riverbank_n.bmp"
//d1
#define D1_A "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\omfrl_4K_Albedo.tga"
#define D1_D "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\omfrl_4K_Displacement.jpg"
//d2
#define D2_A "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\oiloP_4K_Albedo.tga"
#define D2_D "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\oiloP_4K_Displacement.jpg"
//d3
#define D3_A "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\pjuu52_4K_Albedo.tga"
#define D3_D "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\pjuu52_4K_Displacement.jpg"
//d4
#define D4_A "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\pjEfn2_4K_Albedo.tga"
#define D4_D "C:\\Users\\hyunx\\Desktop\\detailMap\\blending\\ppjEfn2_4K_Displacement.jpg"

#define da 4
#define da_ 5

SCRIPT_FX("Technique=Main;")

//lights
DECLARE_LIGHT(Lamp0Pos, "PointLight0", Lamp0Col, "Light Position", 0)

//base map
TEXTURE2D_UI(blendBase, blendBaseSampler, BASE_A1, "Base Map", 0)
TEXTURE2D_UI(blendBase_o, blendBaseSampler_o, BASE_A2, "Base Map original", 0)
TEXTURE2D_UI(baseNormal, baseNormalSampler, BASE_N, "Normal Map", 0)
//blending parameters
DECLARE_FLOAT_UI(n, 0.0f, 15.0f, 8, "blend power", 1)
DECLARE_FLOAT_UI(m, 0.0f, 1.0f, 0.0f, "blend strength", 2)

DECLARE_BOOL_UI(detailColor, "Use detail Map Color", 3)

//detail 1
DECLARE_COLOR_UI(d1HSV, float4(0.75f, 0.725f, 0.71f, 1.0f), "d1", 4)
TEXTURE2D_UI(d1aMap, d1aMap_Sampler, D1_A, "d1", 5)

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
DECLARE_INT_UI(BM, "blend mode" , 0,3,13)


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
    
    float blend0 = 1.0f - m;
    float blend1 = m;

    diffuse = height * blend0 + diffuse * blend1;
    return diffuse;
}

float3 blendByNormal(float NoU, float3 N)
{
    //use heigh map to blend
    //10.0 , 8.368 , 5.732
    
    float f1h = d1H / 10.0f;
    float f2h = d2H / 10.0f;
    float f3h = d3H / 10.0f;
    float3 diffuse = anchorDistribute(NoU, f1h, f2h, f3h);
    
    float blend0 = 1.0f - m;
    float blend1 = m;
    
    diffuse = N * blend0 + diffuse * blend1;

    return diffuse;
}

float3 blendByMap(float4 d1_a, float4 d2_a,float4 bMap)
{
    float3 diffuse = float3(0, 0, 0);
    float f1h = d1H /10;
    float f2h = d2H /10;
    
    float d2 = d2_a.a ;
    d2 = linearMap(d2_a.a, f1h, f2h);
    
    float o1 = bMap.r;
    float o2 = 1 - o1;

    
    float mask = blend_overlay(d2, bMap);
    
    
    if (bMap.r < 0.01)
    {
        mask = bMap.r;
    }
    else if (bMap.r > 0.9999)
    {
        mask = bMap.r;
    }
    //mask = saturate(mask);
    float col1 = 1;
    float col2 = 0;


    //mask = bMap.r;
    diffuse = d1_a * (1 - mask) + d2_a * mask;
    //diffuse = col1 * (1 - mask) + col2 * mask;

    
    return diffuse;
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

float4 PS_VERTEX(PS_IN IN, uniform int C) : SV_Target
{
	//M : blend meathod
    float4 col;
    float3 diffuse = float3(0, 0, 0);

    //maps
    int UVscale = 15;
    float4 blendmaps[da_];
    float4 b_a = blendBase.Sample(blendBaseSampler, IN.uv);  
    float3 normal = baseNormal.Sample(baseNormalSampler, IN.uv).xyz;
    float4 d1_a = d1aMap.Sample(d1aMap_Sampler, IN.uv * UVscale);
    float4 d2_a = d2aMap.Sample(d2aMap_Sampler, IN.uv * UVscale);
    float4 d3_a = d3aMap.Sample(d3aMap_Sampler, IN.uv * UVscale);
    float4 d4_a = d4aMap.Sample(d4aMap_Sampler, IN.uv * UVscale);

	//blend meathods
    if (BM == 0)
    {
        //use base color
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
        diffuse = blendByNormal(NoU, IN.nor);
    }
    else if (BM ==3)
    {
        //use blend map or vertext blend
        diffuse = blendByMap(b_a, d1_a, IN.col);
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

float heighDetail(float a, float b)
{
    //a is the greyscale displacement map embeded in alpha
    float3 diffuse = float3(0, 0, 0);
    //float f1h = d1H / 10;
    //float f2h = d2H / 10; 
    //float d2 = linearMap(a, f1h, f2h);
    
    float mask = blend_overlay(a, b);
    
    if (b < 0.01)
    {
        mask = b;
    }
    else if (b > 0.9999)
    {
        mask = b;
    }
    //mask = saturate(mask);
    //float col1 = 1;
    //float col2 = 0;


    //mask = bMap.r;
    //diffuse = d1_a * (1 - mask) + d2_a * mask;
    //diffuse = col1 * (1 - mask) + col2 * mask;

    
    return mask;
}

float4 anchorDistribute_M(float4 d1_a, float4 d2_a, float4 d3_a, float4 d4_a, float M, float f1h, float f2h, float f3h)
{
    float4 diffuse = float4(0, 0, 0,0);

    float4 m1 = d1_a;
    float4 m2 = d2_a;
    float4 m3 = d3_a;
    float4 m4 = d4_a;
    float4 m5 = d4_a;


    float a = 0;

    if (M > f1h)
    {
        float N = linearMap(M, f1h, 1);
        diffuse = m1 * N + m2 * (1 - N);

    }
    if (M < f1h && M > f2h)
    {
        float N = linearMap(M, f2h, f1h);
        diffuse = m2 * N + m3 * (1 - N);
    }
    if (M < f2h && M > f3h)
    {
        float N = linearMap(M, f3h, f2h);
        diffuse = m3 * N + m4 * (1 - N);
    }
    if (M < f3h)
    {
        float N = linearMap(M, 0, f3h);
        diffuse = m4 * N + m5 * (1 - N);
    }
    return diffuse;
}

float4 blendByNormal_M(float4 b_a, float4 d1_a, float4 d2_a, float4 d3_a, float4 d4_a, float NoU)
{
    //use heigh map to blend
    //10.0 , 8.368 , 5.732
    
    float f1h = d1H / 10.0f;
    float f2h = d2H / 10.0f;
    float f3h = d3H / 10.0f;

    float4 diffuse = anchorDistribute_M(COLOR_WHITE, COLOR_WHITE, COLOR_BLACK, COLOR_BLACK, NoU, f1h, 0.8, f3h);
    
    float blend0 = 1.0f - m;
    float blend1 = m;
    
    //diffuse = b_a * blend0 + diffuse * blend1;
    //float a = linearMap(diffuse.a, 0.5, 0.6);
    //a = NoU *a /2; //blend_overlay(a, NoU * NoU/2);
    //diffuse.xyz = b_a.xyz * (1 - a) + diffuse.xyz * a;
    return diffuse;
}

float3 blendByColor_M(float4 b_a, float4 d1_a, float4 d2_a, float4 d3_a, float4 d4_a, float4 vertextCol)
{
    float3 diffuse = float3(0, 0, 0);
    float4 base;
    base = b_a;
    //float blend0 = 1.0f - m;
    //float blend1 = m;

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
  
    int debug = 0;
    if (debug == 1)
    {
		//debug
        //diffuse = wd.weight[0] * d1HSV + wd.weight[1] * d2HSV + wd.weight[2] * d3HSV + wd.weight[3] * d4HSV;
        diffuse = wd.weight[0] * COLOR_R + wd.weight[1] * COLOR_G + wd.weight[2] * COLOR_B + wd.weight[3] * COLOR_Y;

    }
    else if (debug == 0)
    {
		//color map

        //desaturate
        float desaturate_scale = 0.9;

        diffuse = wd.weight[0] * d1_a + wd.weight[1] * d2_a + wd.weight[2] * d3_a + wd.weight[3] * d4_a;
        //overlay and normal blending
        float k1 = 1;
        diffuse = blend_overlay(b_a, desaturate(diffuse, desaturate_scale)) * k1 + diffuse * (1 - k1);
        //diffuse = b_a;
    }

    //diffuse = b_a.xyz * blend0 + diffuse * blend1;
    return diffuse;
}

float4 blendByHeight_M(float4 b_a, float4 d1_a, float4 d2_a, float4 d3_a, float4 d4_a, float height)
{
    //9.784 , 5.064 ,3.336
    //use heigh map to blend
    float f1h = d1H / 10.0f;
    float f2h = d2H / 10.0f;
    float f3h = d3H / 10.0f;
    
    float4 diffuse = anchorDistribute_M(COLOR_CLEAR, COLOR_CLEAR, COLOR_CLEAR, d4_a, height, f1h, f2h, f3h);
    float4 alpha = anchorDistribute_M(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, COLOR_WHITE, height, f1h, f2h, f3h);
    
    // blend method
    diffuse.xyz = desaturate(diffuse.xyz, 0.35);
    //diffuse = diffuse * 1.2;
    diffuse.a = alpha.r;
    //diffuse = b_a*(1-k) + diffuse * k;
    //float blend0 = 1.0f - m;
    //float blend1 = m;

    //diffuse = height * blend0 + diffuse * blend1;
    return diffuse;
}

float4 PS_MULTI_LAYER(PS_IN IN, uniform int C) : SV_Target
{

    float blend0 = 1.0f - m;
    float blend1 = m;

	//M : blend meathod
    float4 col;
    float3 diffuse = float3(0, 0, 0);

    //maps
    int UVscale = 25;
    float4 blendmaps[da_];
    float4 b_a = blendBase.Sample(blendBaseSampler, IN.uv);
    float4 blend = blendBase_o.Sample(blendBaseSampler_o, IN.uv);
    float4 d1_a = d1aMap.Sample(d1aMap_Sampler, IN.uv * UVscale);
    float4 d2_a = d2aMap.Sample(d2aMap_Sampler, IN.uv * UVscale);
    float4 d3_a = d3aMap.Sample(d3aMap_Sampler, IN.uv * UVscale);
    float4 d4_a = d4aMap.Sample(d4aMap_Sampler, IN.uv * UVscale);

	//blend meathods
    if (BM == 0)
    {
        //layer1 blend by color , add general blend
        float3 l1 = blendByColor_M(b_a, d1_a, d2_a, d3_a, d4_a, IN.col);

        //layer 3 normal mask
        float NoU = dot(IN.nor, float3(0, 0, 1));
        float l3 = blendByNormal_M(b_a, d1_a, d2_a, d3_a, d4_a, NoU).x;

        //llayer2 blend by height , 
        float4 l2 = blendByHeight_M(b_a, d1_a, d2_a, d3_a, d4_a, b_a.a);
        l2.a *= l3;
        diffuse.xyz = (1 - l2.a) * l1 + l2.xyz * l2.a;
    }

    if (BM == 1)
    {
        diffuse = blendByColor(b_a, COLOR_R, COLOR_Y, COLOR_G, COLOR_B, IN.col);

    }

  //  if (BM == 0)
  //  {
  //      diffuse = blendByColor_M(b_a, d1_a, d2_a, d3_a, d4_a, IN.col);
  //  }
  //  if (BM == 1)
  //  {
		////use heigh to blend
  //      diffuse = blendByHeight_M(b_a, d1_a, d2_a, d3_a, d4_a, b_a.a).xyz;
  //  }
  //  if (BM == 2)
  //  {
		////use normal
  //      float NoU = dot(IN.nor, float3(0, 0, 1));
  //      diffuse = blendByNormal_M(b_a, d1_a, d2_a, d3_a, d4_a, NoU).xyz;
  //  }

    diffuse = blend.xyz * blend0 + diffuse * blend1;
        
    //normal
    float3 N = IN.nor;

    //lighting
    float3 A = float3(0.36f, 0.37f, 0.38f) * 0.01;
    float3 L = normalize(Lamp0Pos - IN.p_w);
    float3 V = IN.viw;

    float3 Hn = normalize(L + V);

    float4 litV = lit(dot(L, N), dot(Hn, N), 5);
    float3 D = litV.y * diffuse;
    float3 S = litV.y * litV.z * (diffuse * 0.5 + float3(1, 1, 1) * 0.5);

    col.xyz = diffuse;

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


technique11 multilayer<
                string script = "Pass = p0;";
                >
{
    pass p0 <
                string Script = "Draw=geometry;";
                >
    {
        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, PS_MULTI_LAYER(1)));
    }
}


}
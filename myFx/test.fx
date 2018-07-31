float4x4 wvp : WORLDVIEWPROJ <string UIWidget = "None";>;
float4x4 wvpi : WORLDVIEWPROJI;

float4x4 world : WORLD;
float3 max_dis = { 10, 10, 100 };
float time : TIME;
int i;

float3 lightDir : Direction <  
	string UIName = "Light Direction"; 
	string Object = "TargetLight";
	int RefID = 0;
	> = { -0.577, -0.577, 0.577 };

texture tex0
<
    string name = "ocean.tga"; 
    string UIName = "diffuse";
>;

sampler2D diffuseSampler = sampler_state
{
    Texture = <tex0>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};

struct VSin
{
    float4 pos : POSITION;
    float2 UV : TEXCOORD0;
};

struct VSout
{
    float4 pos : POSITION;
    float2 UV : TEXCOORD0;
    float2 UV2 : TEXCOORD1;
    float4 NORMAL : TEXCOORD2;
};

float2 transUV(float2 uv, float2 tile, float2 offset)
{
    float2 outUV = uv * tile + offset;
    return outUV;
}

void transPos(inout float4 pos, float scale)
{
    float z = (cos(pos.x / 70) + cos(pos.y / 70)) / 2 * scale;
    pos.z = z;
}

float4 transNormal(float4 p, float scaler)
{
    float4 N;

    //this factor doesn't reanlly matter
    float posOffset = 1.0f;
    float4 p1 = float4(p.x + posOffset, p.y, p.z, 1.0f);
    float4 p2 = float4(p.x - posOffset, p.y, p.z, 1.0f);
    float4 p3 = float4(p.x, p.y + posOffset, p.z, 1.0f);
    float4 p4 = float4(p.x, p.y - posOffset, p.z, 1.0f);

    transPos(p1, max_dis.z);
    transPos(p2, max_dis.z);
    transPos(p3, max_dis.z);
    transPos(p4, max_dis.z);

    float4 du = p1 - p2;
    float4 dv = p3 - p4;
    N = float4(normalize(cross(du.xyz, dv.xyz)), 1);

    return N;
}

VSout VS(VSin IN)
{
    VSout OUT = (VSout) 0;

    float4 p = IN.pos;

    //OUT.NORMAL = transNormal(p, max_dis.z);
    //transPos(p, max_dis.z);

    OUT.UV = IN.UV;
    //OUT.UV2 = transUV(IN.UV, float2(2, 1), float2(time / 10000, 0));
    OUT.pos = mul(p, wvp);
    return OUT;
}

float4 colorToGrey(float4 myCol)
{
    float4 col;
    float grey = myCol.r * 0.3f + myCol.g * 0.59 + myCol.b * 0.11f;
    col.rgb = grey;
    col.a = myCol.a;
    return col;
}

float4 HeighMapToNormal(sampler2D tSampler, float2 UV)
{
    float4 col;
    float uPixel = (float) 1.0 / 128;
    float vPixel = (float) 1.0 / 128;

    float4 height_pu = tex2D(tSampler, UV + float2(uPixel, 0));
    float4 height_mu = tex2D(tSampler, UV - float2(uPixel, 0));
    float4 height_pv = tex2D(tSampler, UV + float2(0, vPixel));
    float4 height_mv = tex2D(tSampler, UV - float2(0, vPixel));

    float du = colorToGrey(height_mu - height_pu).r;
    float dv = colorToGrey(height_mv - height_pv).r;
    float3 N = normalize(float3(du, dv, 1.0 / 2));

    col = float4(N, 1);
    return col;
}

float4 PS(VSout IN) : COLOR
{
    float4 col;

    float4 N = float4(normalize(mul(IN.NORMAL.xyz, (float3x3) world)), 1);
    float3 L = lightDir;
    
    float4 diffuse = tex2D(diffuseSampler, IN.UV2);
    
    //lighting
    col = max(dot(N.xyz, L), 0);
    col.a = 1;

    /*show normal*/
    //col = IN.NORMAL;
    

    return col;
}

const float2 gradientV[4] =
{
    float2(1, 1),
    float2(-1, 1),
    float2(1, -1),
    float2(-1, -1)
};

const float NTab[40] =
{
    0.369811f, 0.432591f, 0.698699f, 0.494396f,
		0.78118f, -0.163006f, 0.60265f, 0.124138f,
		0.436394f, -0.297978f, 0.848982f, -0.60845f,
		0.843762f, 0.185742f, 0.457153f, -0.420334f,
		0.663712f, -0.68443f, -0.301731f, -0.577495f,
		0.616757f, 0.768825f, 0.168875f, -0.503554f,
		0.457153f, -0.884439f, -0.093694f, -0.19049f,
		-0.956955f, 0.110962f, -0.268189f, 0.0572986f,
		0.115821f, 0.77523f, 0.620971f, 0.494396f,
		-0.716028f, -0.477247f, -0.50945f, 0.707089f
		/*0.819593, -0.123834, 0.559404, 10,
		-0.522782, -0.586534, 0.618609, 11,
		-0.792328, -0.577495, -0.196765, 12,
		-0.674422, 0.0572986, 0.736119, 13,
		-0.224769, -0.764775, -0.60382, 14,
		0.492662, -0.71614, 0.494396, 15,
		0.470993, -0.645816, 0.600905, 16,
		-0.19049, 0.321113, 0.927685, 17,
		0.0122118, 0.946426, -0.32269, 18,
		0.577419, 0.408182, 0.707089, 19,
		-0.0945428, 0.341843, -0.934989, 20,
		0.788332, -0.60845, -0.0912217, 21,
		-0.346889, 0.894997, -0.280445, 22,
		-0.165907, -0.649857, 0.741728, 23,
		0.791885, 0.124138, 0.597919, 24,
		-0.625952, 0.73148, 0.270409, 25,
		-0.556306, 0.580363, 0.594729, 26,
		0.673523, 0.719805, 0.168069, 27,
		-0.420334, 0.894265, 0.153656, 28,
		-0.141622, -0.279389, 0.949676, 29,
		-0.803343, 0.458278, 0.380291, 30,
		0.49355, -0.402088, 0.77119, 31,
		-0.569811, 0.432591, -0.698699, 0,
		0.78118, 0.163006, 0.60265, 1,
		0.436394, -0.297978, 0.848982, 2,
		0.843762, -0.185742, -0.503554, 3,
		0.663712, -0.68443, -0.301731, 4,
		0.616757, 0.768825, 0.168875, 5,
		0.457153, -0.884439, -0.093694, 6,
		-0.956955, 0.110962, -0.268189, 7,
		0.115821, 0.77523, 0.620971, 8,
		-0.716028, -0.477247, -0.50945, 9,
		0.819593, -0.123834, 0.559404, 10,
		-0.522782, -0.586534, 0.618609, 11,
		-0.792328, -0.577495, -0.196765, 12,
		-0.674422, 0.0572986, 0.736119, 13,
		-0.224769, -0.764775, -0.60382, 14,
		0.492662, -0.71614, 0.494396, 15,
		0.470993, -0.645816, 0.600905, 16,
		-0.19049, 0.321113, 0.927685, 17,
        -0.716028, -0.477247, -0.50945, 18,*/
};
float4 perlin(float2 uv)
{
    ////noise parameters
    //int xGrid = 4;
    //int yGrid = 4;
    ////noise parameters 

    ////get uv on grid value
    //float a = uv.x * xGrid;
    //a = frac(a);

    //float b = uv.y * yGrid;
    //b = frac(b);
    
    float4 no;
    ////get ramdom
    //float i = (floor((uv.x) * 1000)) % 39;
    //float j = (floor((uv.y) * 1000)) % 39;
    ////i = min(i, 39);
    //float d =  cos(NTab[j]);
    no.xyz = uv.x;
    no.a = 1;
    return no;
}
float4 PS2(VSout IN) : COLOR
{
    //float4 col = perlin(IN.UV);
    float4 col = float4(IN.UV.x, abs(IN.UV.y), 0, 1);
    return col;
}

technique test2
<
	string script = "Pass=p0;";
>
{
    pass p0
    <string script = "Draw = Geometry";>
    {
        CullMode = CW;
        ZWriteEnable = false;
		
        AlphaBlendEnable = true;
        BlendOp = Add;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;

        //alphatestenable = true;
        //alphafunc = greaterequal;
        //alpharef = 200;

        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS2();
    }
}


technique main
<
	string script = "Pass=p0;";
>
{
    pass p0
    <string script = "Draw = Geometry";>
    {
        CullMode = CW;
        ZWriteEnable = false;
		
        AlphaBlendEnable = true;
        BlendOp = Add;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;

        //alphatestenable = true;
        //alphafunc = greaterequal;
        //alpharef = 200;

        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    }
}


technique allAlpha
<
	string script = "Pass=p0;";
>
{
    pass p0
    <string script = "Draw = Geometry";>
    {
        CullMode = CW;
        ZWriteEnable = false;
		
        AlphaBlendEnable = true;
        BlendOp = Add;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;

        alphatestenable = true;
        alphafunc = greaterequal;
        alpharef = 200;

        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    }
    
}

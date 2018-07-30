float4x4 wvp : WORLDVIEWPROJ <string UIWidget = "None";>;
float4x4 wvpi : WORLDVIEWPROJI;

float4x4 world : WORLD;
float3 max_dis = { 10,10,100};
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
    float4 pos  : POSITION;
    float2 UV : TEXCOORD0;
};

struct VSout
{
    float4 pos : POSITION;
    float2 UV : TEXCOORD0;
    float2 UV2 : TEXCOORD1;
    float4 NORMAL : TEXCOORD2;
    float V : COLOR0;
};

float2 transUV(float2 uv, float2 tile, float2 offset)
{
    float2 outUV =  uv * tile + offset ;
    return outUV;
}

void transPos(inout float4 pos, float scale)
{
    float z = (cos(pos.x / 70) + cos(pos.y / 70)) / 2 * scale;
    pos.z = z;
}

float4 transNormal(float4 p , float scaler)
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

    OUT.NORMAL = transNormal(p, max_dis.z);
    transPos(p, max_dis.z);

    OUT.UV  = IN.UV;
    OUT.UV2 = transUV(IN.UV, float2(2, 1), float2(time / 10000, 0));
    OUT.pos = mul(p, wvp);
    OUT.V = IN.UV.x;
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

float4 HeighMapToNormal(sampler2D tSampler , float2 UV)
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
    
    float4 diffuse = tex2D(diffuseSampler , IN.UV2);
    
    //lighting
    col = max(dot(N.xyz, L) , 0);
    col.a = 1;

    /*show normal*/
    //col = IN.NORMAL;
    

    return col;
}

const float2 gradientV[4] = 
{
    float2(1  ,  1),
    float2(-1 ,  1),
    float2(1  , -1),
    float2(-1 , -1)
};

float map(float v, float max )
{
}

float4 perlin(float2 uv)
{
    //noise parameters
    int xGrid = 4;
    int yGrid = 4;
    //noise parameters 

    //get uv on grid value
    float a = uv.x * xGrid;
    a = frac(a);

    float b = uv.y * yGrid;
    b = frac(b);
    
    float4 no;



    no.xyz = (b,b,b);
    no.a = 1;
    return no;
}
float4 PS2(VSout IN) : COLOR
{
    float4 col = perlin(IN.UV);
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

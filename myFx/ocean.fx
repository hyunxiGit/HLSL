float4x4 wvp : WORLDVIEWPROJ <string UIWidget = "None";>;
float4x4 world : WORLD;
float3 max_dis = { 10,10,100};
float time : TIME;

float3 lightDir : Direction <  
	string UIName = "Light Direction"; 
	string Object = "TargetLight";
	int RefID = 0;
	> = { -0.577, -0.577, 0.577 };

struct VSin
{
    float4 pos  : POSITION;
    float2 UV : TEXCOORD0;
};

struct VSout
{
    float4 pos : POSITION;
    float4 DISPLACE : TEXCOORD1;
    float2 UV : TEXCOORD0;
    float4 NORMAL : TEXCOORD2;
};

float scaleFactor(float4 pos, float scale)
{
    float z = (cos(pos.x / 70) + cos(pos.y / 70)) / 2 * scale;
    return z;
}

VSout VS(VSin IN)
{
    VSout OUT = (VSout) 0;

    float4 p = IN.pos;

    float posOffset = 0.1f;
    float4 p1 = float4(p.x + posOffset, p.y , p.z, 1.0f);
    float4 p2 = float4(p.x - posOffset, p.y , p.z, 1.0f);
    float4 p3 = float4(p.x , p.y + posOffset, p.z, 1.0f);
    float4 p4 = float4(p.x , p.y - posOffset, p.z, 1.0f);

    float d = scaleFactor(p, max_dis.z);
    float dis1 = scaleFactor(p1, max_dis.z);
    float dis2 = scaleFactor(p2, max_dis.z);
    float dis3 = scaleFactor(p3, max_dis.z);
    float dis4 = scaleFactor(p4, max_dis.z);




    p.z += d;
    p1.z += dis1;
    p2.z += dis2;
    p3.z += dis3;
    p4.z += dis4;

    float4 du = p1 - p2;
    float4 dv = p3 - p4;
    float3 N = normalize(cross(du.xyz, dv.xyz));
    //float3 N = normalize(float3(du, dv, 1.0f));

    //OUT.NORMAL = float4(0, 0, 1,1);
    OUT.NORMAL = float4(N, 1);
    OUT.UV = IN.UV;
    OUT.pos = mul(p, wvp);
    return OUT;
}

texture tex0
<
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
    
    float4 diffuse = tex2D(diffuseSampler , IN.UV);
    
    //lighting
    //col = saturate(dot(N.xyz, L));
    //col.a = 1;

    /*show normal*/
    col = IN.NORMAL;
    

    return col;
}

technique test
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

        alphatestenable = true;
        alphafunc = greaterequal;
        alpharef = 200;

        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    }
    
}

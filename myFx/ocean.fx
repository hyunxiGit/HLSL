float4x4 wvp : WORLDVIEWPROJ <string UIWidget = "None";>;
float4x4 world : WORLD;

struct VSin
{
    float4 pos  : POSITION;
    float2 UV : TEXCOORD0;
};

struct VSout
{
    float4 pos : POSITION;
    float2 UV : TEXCOORD0;
};

VSout VS(VSin IN)
{
    VSin OUT = (VSout)0;
    OUT.UV = IN.UV;
    OUT.pos = mul(IN.pos, wvp);
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

float4 GreyToNormal(float4 myCol)
{
    float4 nor;

    return nor;
}

float4 PS(VSout IN) : COLOR
{
    float4 col = float4(1,0,0,0.2f);
    float4 diffuse = tex2D(diffuseSampler , IN.UV);

    float uPixel = (float) 1.0 / 128;
    float vPixel = (float) 1.0 / 128;

    float4 height_pu = tex2D(diffuseSampler, IN.UV + float2(uPixel, 0));
    float4 height_mu = tex2D(diffuseSampler, IN.UV - float2 (uPixel, 0));
    float4 height_pv = tex2D(diffuseSampler, IN.UV + float2 (0, vPixel));
    float4 height_mv = tex2D(diffuseSampler, IN.UV - float2 (0, vPixel));

    float du = height_mu - height_pu;
    float dv = height_mv - height_pv;
    float3 N = normalize(float3(du, dv, 1.0 / 2));

    //col = colorToGrey(diffuse);
    col = float4(N, 1);
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

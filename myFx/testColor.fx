float4x4 wvp : WORLDVIEWPROJ <string UIWidget = "None";>;
struct VS_Input
{
    float4 pos  : POSITION;
    float2 UV   : TEXCOORD0;
};

struct PS_Input
{
    float4 pos : POSITION;
    float2 UV : TEXCOORD0;
};

PS_Input VS(VS_Input IN)
{
    PS_Input OUT = (PS_Input) 0;
    OUT.pos = mul(IN.pos, wvp);
    OUT.UV = IN.UV;
    return OUT;
}

texture tex0
<
	string UIName = "Texture";
>;

sampler2D tSampler = sampler_state
{
    Texture   = <tex0>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

float4 PS(PS_Input IN) : COLOR
{
    float4 D = tex2D(tSampler, IN.UV);
    float4 col = D;
    return col;
}

technique alphaBlend 
{
    pass P0 
    < string script = "Draw = Geometry" ;>
    {
        AlphaBlendEnable = TRUE;
        DestBlend = InvSrcAlpha;
        SrcBlend = SrcAlpha;

        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    }
}

technique alphaTest<
	string script = "Pass=p0;";
>
{
    pass p0 <
		string script = "Draw=Geometry;";
    >
    {
        AlphaBlendEnable = TRUE;
        DestBlend = InvSrcAlpha;
        SrcBlend = SrcAlpha;
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    }
}
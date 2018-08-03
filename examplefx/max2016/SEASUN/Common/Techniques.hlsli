BlendState NoBlending
{
	BlendEnable[0] = FALSE;
	SrcBlend[0] = ONE;
	DestBlend[0] = ZERO;
	BlendOp[0] = ADD;
	SrcBlendAlpha[0] = ZERO;
	DestBlendAlpha[0] = ZERO;
	BlendOpAlpha[0] = ADD;
	RenderTargetWriteMask[0] = 0x0F;
};

BlendState AlphaBlending
{
	BlendEnable[0] = TRUE;
	SrcBlend[0] = SRC_ALPHA;
	DestBlend[0] = INV_SRC_ALPHA;
	BlendOp[0] = ADD;
	SrcBlendAlpha[0] = ZERO;
	DestBlendAlpha[0] = INV_SRC_ALPHA;
	BlendOpAlpha[0] = ADD;
	RenderTargetWriteMask[0] = 0x0F;
};

DepthStencilState WriteDepth
{
	DepthEnable = TRUE;
	DepthWriteMask = ALL;
	DepthFunc = LESS_EQUAL;
};

DepthStencilState NoWriteDepth
{
	DepthEnable = TRUE;
	DepthWriteMask = ZERO;
	DepthFunc = LESS_EQUAL;
};

RasterizerState NoCull
{
	CullMode = NONE;
};

RasterizerState CullBack
{
	CullMode = BACK;
};

RasterizerState CullFront
{
	CullMode = FRONT;
};

RasterizerState NoCullBias
{
	CullMode = NONE;
	DepthBias = -1000;
	SlopeScaledDepthBias = -100.0f;
	DepthBiasClamp = -0.000001f;
};

RasterizerState CullBackBias
{
	CullMode = BACK;
	DepthBias = -1000;
	SlopeScaledDepthBias = -100.0f;
	DepthBiasClamp = -0.000001f;
	
};

RasterizerState CullFrontBias
{
	CullMode = FRONT;
	DepthBias = -1000;
	SlopeScaledDepthBias = -100.0f;
	DepthBiasClamp = -0.000001f;
};

technique11 NoneNone <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
		SetBlendState( NoBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );
		SetRasterizerState( NoCull );
		SetDepthStencilState( WriteDepth, 0 );
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS(false, false)));
	}
}

technique11 NoneBack <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
		SetBlendState( NoBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );
		SetRasterizerState( CullBack );
		SetDepthStencilState( WriteDepth, 0 );
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS(false, false)));
	}
}

technique11 NoneFront <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
		SetBlendState( NoBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );
		SetRasterizerState( CullFront );
		SetDepthStencilState( WriteDepth, 0 );
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS(false, false)));
	}
}

technique11 TestNone <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
		SetBlendState( NoBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );
		SetRasterizerState( NoCull );
		SetDepthStencilState( WriteDepth, 0 );
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS(false, true)));
	}
}

technique11 TestBack <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
		SetBlendState( NoBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );
		SetRasterizerState( CullBack );
		SetDepthStencilState( WriteDepth, 0 );
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS(false, true)));
	}
}

technique11 TestFront <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
		SetBlendState( NoBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );
		SetRasterizerState( CullFront );
		SetDepthStencilState( WriteDepth, 0 );
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS(false, true)));
	}
}

technique11 StandardNone <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
		SetBlendState( AlphaBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );
		SetRasterizerState( NoCullBias );
		SetDepthStencilState( NoWriteDepth, 0 );
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS(true, false)));
	}
}

technique11 StandardBack <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
		SetBlendState( AlphaBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );
		SetRasterizerState( CullBackBias );
		SetDepthStencilState( NoWriteDepth, 0 );
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS(true, false)));
	}
}

technique11 StandardFront <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
		SetBlendState( AlphaBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );
		SetRasterizerState( CullFrontBias );
		SetDepthStencilState( NoWriteDepth, 0 );
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS(true, false)));
	}
}

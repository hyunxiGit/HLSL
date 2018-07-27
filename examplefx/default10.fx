// 3ds max effect file
// Simple Lighting Model, with data viewing
// DX10 Ready...

// light direction 
float3 lightDir : Direction <  
	string UIName = "Light Direction"; 
	string Object = "TargetLight";
> = {-0.577, -0.577, 0.577};

// light intensity
float4 I_a = { 0.1f, 0.1f, 0.1f, 1.0f };    // ambient
float4 I_d = { 1.0f, 1.0f, 1.0f, 1.0f };    // diffuse
float4 I_s = { 1.0f, 1.0f, 1.0f, 1.0f };    // specular

// material reflectivity
float4 k_a  <
	string UIName = "Ambient";
> = float4( 0.47f, 0.47f, 0.47f, 1.0f );    // ambient
	
float4 k_d  <
	string UIName = "Diffuse";
> = float4( 0.47f, 0.47f, 0.47f, 1.0f );    // diffuse
	
float4 k_s  <
	string UIName = "Specular";
> = float4( 1.0f, 1.0f, 1.0f, 1.0f );    // specular

int n<
	string UIName = "Specular Power";
	string UIType = "IntSpinner";
	float UIMin = 0.0f;
	float UIMax = 50.0f;	
	>  = 15;

// transformations
cbuffer everyFrame
{
	matrix World      : 		WORLD;
	matrix WorldIT   : 		WORLDINVERSETRANSPOSE;
	matrix WorldViewProj : 		WORLDVIEWPROJ;
	matrix WorldView 	: 		WORLDVIEW;
	matrix Projection 	: 		PROJECTION;
	matrix ViewI		:		VIEWINVERSE;
};

RasterizerState DataCulling
{
	FillMode = SOLID;
	CullMode = FRONT;
	FrontCounterClockwise = false;
};

RasterizerState NoCulling
{
	FillMode = SOLID;
	CullMode = NONE;

};

DepthStencilState EnableDepth
{
    DepthEnable = TRUE;
    DepthWriteMask = ALL;
};

DepthStencilState Depth
{
    DepthEnable = TRUE;
    DepthFunc = 4;//LESSEQUAL
    DepthWriteMask = ALL;
};

struct VS_INPUT
{
    float3 Pos  : POSITION;
    float3 Norm : NORMAL;
};

struct VS_OUTPUT
{
    float4 Pos  : SV_Position;
    float4 col : COLOR0;
    float3 Normal : NORMAL;
    uint VertexId : VERTEXID;
       
};

struct GSOutput
{
    float4 Position : SV_Position;
    float3 Color : COLOR;
};

float Bias = 1.00f;
float g_PointSize = 1.25f; 
float LineSize = 2.00f;

//--------------------------------------------------------------------------------------
// GeometryShader I/O for Points 
//--------------------------------------------------------------------------------------

void GSPointsPerVertex( VS_OUTPUT In , inout TriangleStream<GSOutput> outputStream )
{
    GSOutput Out;  
	Out.Color = In.col;
	    
    float4 center = mul(In.Pos, Projection);
//	float4 center = In.Pos;


    Out.Position = float4( center.x - g_PointSize, center.y - g_PointSize, center.z, center.w );
	outputStream.Append(Out);

    Out.Position = float4( center.x + g_PointSize, center.y - g_PointSize, center.z, center.w );
	outputStream.Append(Out);

    Out.Position = float4( center.x - g_PointSize, center.y + g_PointSize, center.z, center.w );
	outputStream.Append(Out);

    Out.Position = float4( center.x + g_PointSize, center.y + g_PointSize, center.z, center.w );
    
	outputStream.Append(Out);
	outputStream.RestartStrip();
}

[maxvertexcount(4)]
void GSPoints( point VS_OUTPUT In[1], inout TriangleStream<GSOutput> outputStream )
{
	GSPointsPerVertex( In[0], outputStream );
}


[maxvertexcount(6)]
void GSAdjacencies( triangleadj VS_OUTPUT In[6], inout LineStream<GSOutput> outputStream )
{
    GSOutput Extent;  
    GSOutput Center;  
    
    Extent.Color = float3(0.0f,0.0f,1.0f);
    Center.Color = float3(0.0f,1.0f,1.0f);
    
    
	Center.Position = mul( (In[0].Pos+In[2].Pos+In[4].Pos)/3.0f, Projection );

	if(In[1].VertexId != In[0].VertexId)
	{
		Extent.Position = mul( (In[0].Pos+In[2].Pos)/2.0f , Projection);

		outputStream.Append(Center);
		outputStream.Append(Extent);
		outputStream.RestartStrip();
	}


	if(In[3].VertexId != In[2].VertexId)
	{
		Extent.Position = mul( (In[2].Pos+In[4].Pos)/2.0f , Projection);

		outputStream.Append(Center);
		outputStream.Append(Extent);
		outputStream.RestartStrip();
	}

	if(In[5].VertexId != In[4].VertexId)
	{
		Extent.Position = mul( (In[4].Pos+In[0].Pos)/2.0f , Projection);

		outputStream.Append(Center);
		outputStream.Append(Extent);
		outputStream.RestartStrip();
	}
}
//--------------------------------------------------------------------------------------
// GeometryShader I/O for Vectors
//--------------------------------------------------------------------------------------

void GSVectorsPerVertex( VS_OUTPUT In, inout LineStream<GSOutput> outputStream)
{
    GSOutput BasePoint;  
    GSOutput EndPoint;  
    BasePoint.Position = mul(In.Pos, Projection);
        
	BasePoint.Color = In.col;
	EndPoint.Color = In.col;
	    
	EndPoint.Position = mul( ( In.Pos + float4(In.Normal.xyz * LineSize, 0.0f) ) , Projection);
	outputStream.Append(BasePoint);
	outputStream.Append(EndPoint);
	outputStream.RestartStrip();
}

[maxvertexcount(6)]
void GSVectors( triangle VS_OUTPUT In[3], inout LineStream<GSOutput> outputStream)
{
	GSVectorsPerVertex( In[0], outputStream);
	GSVectorsPerVertex( In[1], outputStream);
	GSVectorsPerVertex( In[2], outputStream);
}


VS_OUTPUT VS(     float3 Pos  : POSITION,
    			  float3 Norm : NORMAL,
    			  uint VertexId : SV_VERTEXID)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    float3 L = lightDir;


    float3 P = mul(float4(Pos, 1),World); 				  // position (world space)
    float3 N = normalize(mul(Norm,World)); 				  // normal (world space)
    float3 R = normalize(2 * dot(N, L) * N - L);          // reflection vector (world space)
    float3 V = normalize(ViewI[3].xyz - P);                              // view direction (world space)

    Out.Pos  = mul(float4(Pos,1),WorldViewProj);    	  // position (projected)
    
    float4 Diff = I_a * k_a + I_d * k_d * max(0, dot(N, L)); // diffuse + ambient
    float4 Spec = I_s * k_s * pow(max(0, dot(R, V)), n/4);   // specular
    
    Out.col = Diff + Spec;
    Out.VertexId = VertexId;

    return Out;
}

VS_OUTPUT VSG(     float3 Pos  : POSITION,
    			  float3 Norm : NORMAL,
    			  uint VertexId : SV_VERTEXID)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

	Out.Pos = mul(float4(Pos,1),WorldView);    	  // position (projected)
	Out.Normal =  normalize( mul( normalize(Norm), (float3x3)WorldView ) );
	Out.Pos.z  -= Bias;
    Out.col = float4(0.0f,0.0f,1.0f,1.0f);
    Out.VertexId = VertexId;
    return Out;
}



float4 PS( VS_OUTPUT input ) : SV_Target
{
    float4 color = input.col;  color.a = 1.0f;
    return  color ;
}

float3 PSG( GSOutput input ) : SV_Target
{
    float3 color = input.Color;
    return  color ;
}

technique10 Shaded
{
    pass P0
    {
    	//SetRasterizerState(DataCulling);
        //SetDepthStencilState( EnableDepth, 0 );	
        // shaders
       SetVertexShader( CompileShader( vs_4_0, VS()));
       SetGeometryShader(NULL);
       SetPixelShader( CompileShader( ps_4_0, PS()));
    }  
  
}


technique10 ShowPoints
{
    pass P0
    {
		SetRasterizerState(DataCulling);
        SetDepthStencilState( EnableDepth, 0 );	
        // shaders
       	SetVertexShader( CompileShader( vs_4_0, VS()));
       	SetGeometryShader(NULL);
       	SetPixelShader( CompileShader( ps_4_0, PS()));
    }  
    
    pass P1
    {
    	SetRasterizerState(DataCulling);
        SetDepthStencilState( Depth, 0 );	
        // shaders
       	SetVertexShader( CompileShader( vs_4_0, VSG()));
       	SetGeometryShader( CompileShader(gs_4_0, GSPoints()));
       	SetPixelShader( CompileShader( ps_4_0, PSG()));
    }  
    
}

technique10 ShowNormals
{
    pass P0
    {
    	SetRasterizerState(DataCulling);
        SetDepthStencilState( EnableDepth, 0 );	
        // shaders
       	SetVertexShader( CompileShader( vs_4_0, VS()));
       	SetGeometryShader(NULL);
       	SetPixelShader( CompileShader( ps_4_0, PS()));
    }  
    
    pass P1
    {
    	SetRasterizerState(DataCulling);
        SetDepthStencilState( Depth, 0 );	
        // shaders
       	SetVertexShader( CompileShader( vs_4_0, VSG()));
       	SetGeometryShader( CompileShader(gs_4_0, GSVectors()));
       	SetPixelShader( CompileShader( ps_4_0, PSG()));
    }  
    
}


technique10 ShowAdjacency
{
    pass P0
    {
    	SetRasterizerState(DataCulling);
        SetDepthStencilState( EnableDepth, 0 );	
        // shaders
       	SetVertexShader( CompileShader( vs_4_0, VS()));
       	SetGeometryShader(NULL);
       	SetPixelShader( CompileShader( ps_4_0, PS()));
    }  
    
    pass P1
    {
    	SetRasterizerState(DataCulling);
        SetDepthStencilState( Depth, 0 );	
        // shaders
       	SetVertexShader( CompileShader( vs_4_0, VSG()));
       	SetGeometryShader( CompileShader(gs_4_0, GSAdjacencies()));
       	SetPixelShader( CompileShader( ps_4_0, PSG()));
    }  
    
}



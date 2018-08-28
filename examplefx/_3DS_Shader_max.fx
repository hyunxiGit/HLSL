//render target example
/* version 2.0 */

//string ParamID = "0x00000";
//#ifdef _MAX_
	//string ParamID = "0x003";
//#endif

// Render State =======================================

int 	Blend_Mode	< string UIName = "Blend Mode"; > = 0;
bool	Alpha_Test 	< string UIName = "Alpha_Test_Enable"; > = false;
int		Alpha_Ref	< string UIName = "Alpha Reference"; > = 1;
bool	Cull_Face 	< string UIName = "Cull_Face_Enable"; > = true;
int 	Cull_Mode	< string UIName = "Cull Mode"; > = 2;
int 	Depth_Bias	< string UIName = "Depth Bias"; > = 0;

// Color Conversion ===================================
bool Color_Conversion < string UIName = "Color_Conversion"; > = false;

// Time Settings ======================================

float Time : Time 	< string UIWidget = "none"; > = 0;
float Frame_Rate	< string UIName = "Frame_Rate"; > = 1;

// Samplers State =====================================
float2 Texture0_Map_Address 	< string UIName = "Texture0_Map_Address"; > = {0,0};
float4 Texture0_Map_Filters 	< string UIName = "Texture0_Map_Filters"; > = {1,1,2,0};
float2 Texture0_Texel_Size 		< string UIName = "Texture0_Texel_Size"; > = {0.1,0.1};

float2 Texture1_Map_Address 	< string UIName = "Texture1_Map_Address"; > = {0,0};
float4 Texture1_Map_Filters 	< string UIName = "Texture1_Map_Filters"; > = {1,1,2,0};
float2 Texture1_Texel_Size 		< string UIName = "Texture1_Texel_Size"; > = {0.1,0.1};

float2 Texture2_Map_Address 	< string UIName = "Texture2_Map_Address"; > = {0,0};
float4 Texture2_Map_Filters 	< string UIName = "Texture2_Map_Filters"; > = {1,1,2,0};
float2 Texture2_Texel_Size 		< string UIName = "Texture2_Texel_Size"; > = {0.1,0.1};

////////////////////////////////
// Tweaks.
////////////////////////////////

static bool Skinning = false;
static bool Use_Specular = true;

// Lighting.

// Light 0 ==============================================
bool Add_Light0 < string UIName = "Add_Light0"; > = true;
int  Light0_Type < string UIName = "Light0_Type"; > = 1;
float4 Light0_Direction 
<
	string UIWidget = "Color";
	string UIName = "Light0_Direction";
	string Object = "TargetLight";
//	string SW_OBJECTNAME = "Light0";
	int refID = 1;
> = float4(-20,-10,30,0);

float4 Light0_Position : Position 
<
	string UIWidget = "Color";
	string UIName = "Light0_Position";
	string Object = "PointLight";
//	string SW_OBJECTNAME = "Light0";
	int refID = 1;
> = {0,0,0,0};

float4 Light0_Ambient_Color <
	string UIWidget = "Color"; 
	string UIName = "Light0_Ambient_Color";
> = float4(0,0,0,1);

float4 Light0_Diffuse_Color <
	string UIWidget = "Color"; 
	string UIName = "Light0_Diffuse_Color";
> = float4(0.5,0.5,0.5,1);

float4 Light0_Specular_Color <
	string UIWidget = "Color"; 
	string UIName = "Light0_Specular_Color";
> = float4(1,1,1,1);

// Light 1 ==============================================
bool Add_Light1 < string UIName = "Add_Light1"; > = false;
int  Light1_Type < string UIName = "Light1_Type"; > = 1;
float4 Light1_Direction 
<
	string UIWidget = "Color";
	string UIName = "Light1_Direction";
	string Object = "TargetLight";
	int refID = 2;
> = float4(-20,-10,30,0);

float4 Light1_Position : Position 
<
	string UIWidget = "Color";
	string UIName = "Light1_Position";
	string Object = "PointLight";
	int refID = 2;
> = {0,0,0,0};

float4 Light1_Ambient_Color <
	string UIWidget = "Color"; 
	string UIName = "Light1_Ambient_Color";
> = float4(0,0,0,1);

float4 Light1_Diffuse_Color <
	string UIWidget = "Color"; 
	string UIName = "Light1_Diffuse_Color";
> = float4(0.5,0.5,0.5,1);

float4 Light1_Specular_Color <
	string UIWidget = "Color"; 
	string UIName = "Light1_Specular_Color";
> = float4(1,1,1,1);

// Light 2 ==============================================
bool Add_Light2 < string UIName = "Add_Light2"; > = false;
int  Light2_Type < string UIName = "Light2_Type"; > = 1;
float4 Light2_Direction 
<
	string UIWidget = "Color";
	string UIName = "Light2_Direction";
	string Object = "TargetLight";
	int refID = 3;
> = float4(-20,-10,30,0);

float4 Light2_Position : Position 
<
	string UIWidget = "Color";
	string UIName = "Light2_Position";
	string Object = "PointLight";
	int refID = 3;
> = {0,0,0,0};

float4 Light2_Ambient_Color <
	string UIWidget = "Color"; 
	string UIName = "Light2_Ambient_Color";
> = float4(0,0,0,1);

float4 Light2_Diffuse_Color <
	string UIWidget = "Color"; 
	string UIName = "Light2_Diffuse_Color";
> = float4(0.5,0.5,0.5,1);

float4 Light2_Specular_Color <
	string UIWidget = "Color"; 
	string UIName = "Light2_Specular_Color";
> = float4(1,1,1,1);

#ifdef _3DSMAX_
// 3dsmax channels assignment.
int texcoord0 : Texcoord < string UIWidget = "None"; int Texcoord = 0; int MapChannel = 1;  >;
int texcoord1 : Texcoord < string UIWidget = "None"; int Texcoord = 1; int MapChannel = 2;  >;
int texcoord2 : Texcoord < string UIWidget = "None"; int Texcoord = 2; int MapChannel = 3;  >;
int texcoord3 : Texcoord < string UIWidget = "None"; int Texcoord = 3; int MapChannel = 4;  >;
int texcoord4 : Texcoord < string UIWidget = "None"; int Texcoord = 4; int MapChannel = 0;  >; // vertex color
int texcoord5 : Texcoord < string UIWidget = "None"; int Texcoord = 5; int MapChannel = -2; >; // vertex alpha
#endif

bool	Use_Diffuse			< string UIName = "Use_Diffuse"; > = true;
bool	Use_Vertex_Color	< string UIName = "Use_Vertex_Color"; > = true;
bool	Use_Geometric		< string UIName = "Use_Geometric"; > = true;
bool	Use_Height_Map		< string UIName = "Use_Height_Map"; > = false;
bool	Gen_Normal_Z		< string UIName = "Gen_Normal_Z"; > = true;
float2 	Height_Texel_Size	< string UIName = "Height_Texel_Size"; > = {256.,256.};

float4 Diffuse_Color <
	string UIWidget = "Color";
	string UIName = "Diffuse Color";
> = float4(0.5,0.5,0.5,1);

float4 Ambient_Color <
	string UIWidget = "Color"; 
	string UIName = "Ambient Color";
> = float4(0.25,0.25,0.25,1);

float4 Light_Color <
	string UIWidget = "Color"; 
	string UIName = "Light_Color";
> = float4(1,1,1,1);

float4 Specular0_Color <
	string UIWidget = "Color"; 
	string UIName = "Specular0_Color";
> = float4(1,1,1,1);

float4 Specular1_Color <
	string UIWidget = "Color"; 
	string UIName = "Specular1_Color";
> = float4(1,1,1,1);

int 	Primary_Alpha_Type 		< string UIName = "Primary_Alpha_Type"; > = 1;
float 	Primary_Alpha_Value 	< string UIName = "Primary_Alpha_Value"; > = 1.0;

int 	Secondary_Alpha_Type 	< string UIName = "Secondary_Alpha_Type"; > = 1;
float 	Secondary_Alpha_Value 	< string UIName = "Secondary_Alpha_Value"; > = 1.0;


// Specular ========================
bool	Use_Specular0			< string UIName = "Use_Specular0"; > = false;
int		Specular0_Anim			< string UIName = "Specular0_Anim"; > = 0;
float	Specular0_Anim_Rate		< string UIName = "Specular0_Anim_Rate"; > = 1; 
int		Specular0_Type			< string UIName = "Specular0_Type"; > = 0;
int		Specular0_Factor		< string UIName = "Specular0_Factor"; > = 0;

bool	Use_Specular1			< string UIName = "Use_Specular1"; > = false;
int		Specular1_Anim			< string UIName = "Specular1_Anim"; > = 0;
float	Specular1_Anim_Rate		< string UIName = "Specular1_Anim_Rate"; > = 1; 
int		Specular1_Type			< string UIName = "Specular1_Type"; > = 0;
int		Specular1_Factor		< string UIName = "Specular1_Factor"; > = 0;

bool	Use_Reflection			< string UIName = "Use_Reflection"; > = false;
int		Reflection_R_Anim		< string UIName = "Reflection_R_Anim"; > = 0;
float	Reflection_R_Anim_Rate	< string UIName = "Reflection_R_Anim_Rate"; > = 1; 
int		Reflection_R_Type		< string UIName = "Reflection_R_Type"; > = 0;
int		Reflection_R_Factor		< string UIName = "Reflection_R_Factor"; > = 0;
int		Reflection_G_Anim		< string UIName = "Reflection_G_Anim"; > = 0;
float	Reflection_G_Anim_Rate	< string UIName = "Reflection_G_Anim_Rate"; > = 1; 
int		Reflection_G_Type		< string UIName = "Reflection_G_Type"; > = 0;
int		Reflection_G_Factor		< string UIName = "Reflection_G_Factor"; > = 0;
int		Reflection_B_Anim		< string UIName = "Reflection_B_Anim"; > = 0;
float	Reflection_B_Anim_Rate	< string UIName = "Reflection_B_Anim_Rate"; > = 1; 
int		Reflection_B_Type		< string UIName = "Reflection_B_Type"; > = 0;
int		Reflection_B_Factor		< string UIName = "Reflection_B_Factor"; > = 0;
bool	Reflection_Only_R		< string UIName = "Reflection_Only_R"; > = false;

bool	Use_Fresnel				< string UIName = "Use_Fresnel"; > = false;
int		Fresnel_Anim			< string UIName = "Fresnel_Anim"; > = 0;
float	Fresnel_Anim_Rate		< string UIName = "Fresnel_Anim_Rate"; > = 1; 
int		Fresnel_Type			< string UIName = "Fresnel_Type"; > = 0;
int		Fresnel_Factor			< string UIName = "Fresnel_Factor"; > = 0;

// Textures ========================
// 0
bool Use_Texture0		< string UIName = "Use_Texture0"; > = false;
int  Texture0_Type 		< string UIName = "Texture0_Type"; > = 0;
int  Texture0_Channel 	< string UIName = "Texture0_Channel"; > = 0;

float Texture0_Opacity	< string UIName = "Texture0_Opacity"; > = 1.0;
float Texture0_Height	< string UIName = "Texture0_Height"; > = 0.4;
float Texture0_Reflect	< string UIName = "Texture0_Reflect"; > = 1.0;
float Texture0_Bias		< string UIName = "Texture0_Bias"; > = 0.0;

float4 Texture0_Map_uCoord	< string UIName = "Texture0_Map_uCoord"; > = {0,1,0,0};
float4 Texture0_Map_vCoord	< string UIName = "Texture0_Map_vCoord"; > = {0,1,0,0};
float  Texture0_Map_Anim	< string UIName = "Texture0_Map_Anim"; > = 0;

// 1
bool Use_Texture1		< string UIName = "Use_Texture1"; > = false;
int  Texture1_Type 		< string UIName = "Texture1_Type"; > = 0;
int  Texture1_Channel 	< string UIName = "Texture1_Channel"; > = 0;

float Texture1_Opacity	< string UIName = "Texture1_Opacity"; > = 1.0;
float Texture1_Height	< string UIName = "Texture1_Height"; > = 0.4;
float Texture1_Reflect	< string UIName = "Texture1_Reflect"; > = 1.0;
float Texture1_Bias		< string UIName = "Texture1_Bias"; > = 0.0;

float4 Texture1_Map_uCoord	< string UIName = "Texture1_Map_uCoord"; > = {0,1,0,0};
float4 Texture1_Map_vCoord	< string UIName = "Texture1_Map_vCoord"; > = {0,1,0,0};
float  Texture1_Map_Anim	< string UIName = "Texture1_Map_Anim"; > = 0;

// 2
bool Use_Texture2		< string UIName = "Use_Texture2"; > = false;
int  Texture2_Type 		< string UIName = "Texture2_Type"; > = 0;
int  Texture2_Channel 	< string UIName = "Texture2_Channel"; > = 0;

float Texture2_Opacity	< string UIName = "Texture2_Opacity"; > = 1.0;
float Texture2_Height	< string UIName = "Texture2_Height"; > = 0.4;
float Texture2_Reflect	< string UIName = "Texture2_Reflect"; > = 1.0;
float Texture2_Bias		< string UIName = "Texture2_Bias"; > = 0.0;

float4 Texture2_Map_uCoord	< string UIName = "Texture2_Map_uCoord"; > = {0,1,0,0};
float4 Texture2_Map_vCoord	< string UIName = "Texture2_Map_vCoord"; > = {0,1,0,0};
float  Texture2_Map_Anim	< string UIName = "Texture2_Map_Anim"; > = 0;

// Procedural
bool	Use_Procedural				< string UIName = "Use_Procedural"; > = false;
float4	Procedural_Map_uCoord		< string UIName = "Procedural_Map_uCoord"; > = {0,1,0,0};
bool	Use_Procedural_Noise		< string UIName = "Use_Procedural_Noise"; > = false;
int		Procedural_Map_uShiftMode	< string UIName = "Proc_Map_uShiftMode"; > = 0;
float4 	Procedural_Map_uNoise		< string UIName = "Proc_Map_uNoise"; > = {1.0,8,0,0};
float4 	Procedural_Map_vNoise		< string UIName = "Proc_Map_vNoise"; > = {1.0,8,0,0};
bool	Procedural_Map_Noise_Only_U < string UIName = "Proc_Noise_Only_U"; > = false;
int		Procedural_Function			< string UIName = "Proc_Anim"; > = 0;
float	Procedural_Scale				< string UIName = "Proc_Anim_Rate"; > = 0; 
int		Procedural_Type				< string UIName = "Proc_Type"; > = 0;
int  	Procedural_Channel 			< string UIName = "Proc_Channel"; > = 0;
int		Procedural_Factor			< string UIName = "Proc_Factor"; > = 0;


float inTransFalloff <
	string UIName = "TransFalloffIn";
> = 1;

float outTransFalloff <
	string UIName = "TransFalloffOut";
> = 0;

////////////////////////////////
// Textures.
////////////////////////////////

texture Specular0_Table <
	string UIName = "Specular0 Table";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string name = "";
	string TYPE = "2D";
>;

sampler2D Specular0_Table_Sampler
<
> = sampler_state
{
	Texture = <Specular0_Table>;
	AddressU = CLAMP;
	AddressV = WRAP;

	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	MaxAnisotropy = 0;
};

texture Specular1_Table <
	string UIName = "Specular1 Table";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string name = "";
	string TYPE = "2D";
>;

sampler2D Specular1_Table_Sampler
<
> = sampler_state
{
	Texture = <Specular1_Table>;
	AddressU = CLAMP;
	AddressV = WRAP;

	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	MaxAnisotropy = 0;
};

texture Reflection_Table <
	string UIName = "Reflection Table";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string name = "";
	string TYPE = "2D";
>;

sampler2D Reflection_Table_Sampler
<
> = sampler_state
{
	Texture = <Reflection_Table>;
	AddressU = CLAMP;
	AddressV = WRAP;

	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	MaxAnisotropy = 0;
};

texture Fresnel_Table <
	string UIName = "Fresnel Table";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string name = "";
	string TYPE = "2D";
>;

sampler2D Fresnel_Table_Sampler
<
> = sampler_state
{
	Texture = <Fresnel_Table>;
	AddressU = CLAMP;
	AddressV = WRAP;

	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	MaxAnisotropy = 0;
};

texture Texture0_Map <
	string UIName = "Texture0_Map";
	string name = "";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string TYPE = "2D";

>;
sampler2D Texture0_Map_Sampler
<
> = sampler_state
{
	Texture = <Texture0_Map>;
	AddressU = <Texture0_Map_Address[0]>;
	AddressV = <Texture0_Map_Address[1]>;

	MinFilter = <Texture0_Map_Filters[0]>;
	MagFilter = <Texture0_Map_Filters[1]>;
	MipFilter = <Texture0_Map_Filters[2]>;
	MaxAnisotropy = <Texture0_Map_Filters[3]>;
};

texture Texture1_Map <
	string UIName = "Texture1_Map";
	string name = "";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string TYPE = "2D";

>;
sampler2D Texture1_Map_Sampler
<
> = sampler_state
{
	Texture = <Texture1_Map>;
	AddressU = <Texture1_Map_Address[0]>;
	AddressV = <Texture1_Map_Address[1]>;

	MinFilter = <Texture1_Map_Filters[0]>;
	MagFilter = <Texture1_Map_Filters[1]>;
	MipFilter = <Texture1_Map_Filters[2]>;
	MaxAnisotropy = <Texture0_Map_Filters[3]>;
};

texture Texture2_Map <
	string UIName = "Texture2_Map";
	string name = "";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string TYPE = "2D";

>;
sampler2D Texture2_Map_Sampler
<
> = sampler_state
{
	Texture = <Texture2_Map>;
	AddressU = <Texture2_Map_Address[0]>;
	AddressV = <Texture2_Map_Address[1]>;

	MinFilter = <Texture2_Map_Filters[0]>;
	MagFilter = <Texture2_Map_Filters[1]>;
	MipFilter = <Texture2_Map_Filters[2]>;
	MaxAnisotropy = <Texture2_Map_Filters[3]>;
};

texture Reflection_Map <
	string UIName = "Reflection Map";
	string name = "";
	string ResourceName = ""; 
	string ResourceType = "Cube";
	string TYPE = "Cube";
>;
samplerCUBE Reflection_Map_Sampler
<
> = sampler_state
{
	Texture = <Reflection_Map>;

	AddressU = Wrap;
	AddressV = Wrap;
	AddressW = Wrap;

	MinFilter = <Texture0_Map_Filters[0]>;
	MagFilter = <Texture0_Map_Filters[1]>;
	MipFilter = <Texture0_Map_Filters[2]>;
	MaxAnisotropy = <Texture0_Map_Filters[3]>;
};

texture Procedural_Color_Table <
	string UIName = "Proc_Color_Table";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string name = "";
	string TYPE = "2D";
>;

sampler2D Procedural_Color_Table_Sampler
<
> = sampler_state
{
	Texture = <Procedural_Color_Table>;
	AddressU = <Procedural_Map_uCoord[3]>;
	AddressV = <Procedural_Map_uCoord[3]>;

	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	MaxAnisotropy = 8;
};

texture Procedural_Function_Table <
	string UIName = "Proc_Func_Table";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string name = "";
	string TYPE = "2D";
>;

sampler2D Procedural_Function_Table_Sampler
<
> = sampler_state
{
	Texture = <Procedural_Function_Table>;
	AddressU = Wrap; //<Procedural_Map_uCoord[3]>;
	AddressV = Wrap; //<Procedural_Map_uCoord[3]>;

	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	MaxAnisotropy = 8;
};

texture Procedural_Map <
	string UIName = "Proc_Map";
	string name = "";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string TYPE = "2D";
>;
sampler2D Procedural_Map_Sampler
<
> = sampler_state
{
	Texture = <Procedural_Map>;
	AddressU = Wrap; //<Procedural_Map_uNoise[3]>;
	AddressV = Wrap; //<Procedural_Map_vNoise[3]>;

	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	MaxAnisotropy = 8;
};

#define NOISE_SCALE 5
#define NOISE3D_LIMIT 32

#define NOISE_TEX_SIZE 256

// function used to fill the volume noise texture
float3 noise_2d(float3 Pos : POSITION) : COLOR
{
	return (noise(Pos * 10.5) * .5) + .5f; //make_marble_map(Pos.x);
}
texture procNoise2DTex
< 
//	string UIName = "2D_Noise_Texture";
    string ResourceType = "2D"; 
    string function = "noise_2d"; 
    float2 Dimensions = { NOISE_TEX_SIZE, NOISE_TEX_SIZE };
>;

// samplers
sampler2D NoiseSampler 
<
> = sampler_state
{
	Texture = <procNoise2DTex>;
    AddressU  = Wrap;        
    AddressV  = Wrap;

    MinFilter = Linear;
    MipFilter = Linear;
    MagFilter = Linear;
};

// Fog ===================================
bool	Add_Fog					< string UIName = "Add_Fog"; > = false;
int  	Fog_Type 				< string UIName = "Fog_Type"; > = 3;
float	Fog_Density				< string UIName = "Fog_Density"; float UIMin = 0.0; float UIMax = 9999999.0; > = 1.0; 
float	Fog_Near				< string UIName = "Fog_Near"; float UIMin = 0.0; float UIMax = 9999999.0; > = 0; 
float	Fog_Far					< string UIName = "Fog_Far"; float UIMin = 0.0; float UIMax = 9999999.0; > = 100; 
float4 	Fog_Color 				< string UIName = "Fog_Color"; > = {1,1,1,1};

texture Fog_Table <
	string UIName = "Fog Table";
	string ResourceName = ""; 
	string ResourceType = "2D";
	string name = "";
	string TYPE = "2D";
>;

sampler2D Fog_Table_Sampler
<
> = sampler_state
{
	Texture = <Fog_Table>;
	AddressU = CLAMP;
	AddressV = CLAMP;

	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	MaxAnisotropy = 0;
};

// Combiners =============================

bool Use_Combiner0 				< string UIName = "Use_Combiner0"; > = true;
float4 Combiner0_Color 			< string UIName = "Combiner0_Color"; > = {0,0,0,1};
float4 Combiner0_Input0			< string UIName = "Combiner0_Input0"; > = {9,0,9,0};
float4 Combiner0_Input1			< string UIName = "Combiner0_Input1"; > = {9,0,9,0};
float4 Combiner0_Input2			< string UIName = "Combiner0_Input2"; > = {9,0,9,0};
float3 Combiner0_Color_Output	< string UIName = "Combiner0_Color_Output"; > = {0,0,0};
float3 Combiner0_Alpha_Output	< string UIName = "Combiner0_Alpha_Output"; > = {0,0,0};

bool Use_Combiner1 				< string UIName = "Use_Combiner1"; > = false;
float4 Combiner1_Color 			< string UIName = "Combiner1_Color"; > = {1,1,1,1};
float4 Combiner1_Input0			< string UIName = "Combiner1_Input0"; > = {0,0,0,0};
float4 Combiner1_Input1			< string UIName = "Combiner1_Input1"; > = {0,0,0,0};
float4 Combiner1_Input2			< string UIName = "Combiner1_Input2"; > = {0,0,0,0};
float3 Combiner1_Color_Output	< string UIName = "Combiner1_Color_Output"; > = {0,0,0};
float3 Combiner1_Alpha_Output	< string UIName = "Combiner1_Alpha_Output"; > = {0,0,0};

bool Use_Combiner2 				< string UIName = "Use_Combiner2"; > = false;
float4 Combiner2_Color 			< string UIName = "Combiner2_Color"; > = {1,1,1,1};
float4 Combiner2_Input0			< string UIName = "Combiner2_Input0"; > = {0,0,0,0};
float4 Combiner2_Input1			< string UIName = "Combiner2_Input1"; > = {0,0,0,0};
float4 Combiner2_Input2			< string UIName = "Combiner2_Input2"; > = {0,0,0,0};
float3 Combiner2_Color_Output	< string UIName = "Combiner2_Color_Output"; > = {0,0,0};
float3 Combiner2_Alpha_Output	< string UIName = "Combiner2_Alpha_Output"; > = {0,0,0};

bool Use_Combiner3 				< string UIName = "Use_Combiner3"; > = false;
float4 Combiner3_Color 			< string UIName = "Combiner3_Color"; > = {1,1,1,1};
float4 Combiner3_Input0			< string UIName = "Combiner3_Input0"; > = {0,0,0,0};
float4 Combiner3_Input1			< string UIName = "Combiner3_Input1"; > = {0,0,0,0};
float4 Combiner3_Input2			< string UIName = "Combiner3_Input2"; > = {0,0,0,0};
float3 Combiner3_Color_Output	< string UIName = "Combiner3_Color_Output"; > = {0,0,0};
float3 Combiner3_Alpha_Output	< string UIName = "Combiner3_Alpha_Output"; > = {0,0,0};

bool Use_Combiner4 				< string UIName = "Use_Combiner4"; > = false;
float4 Combiner4_Color 			< string UIName = "Combiner4_Color"; > = {1,1,1,1};
float4 Combiner4_Input0			< string UIName = "Combiner4_Input0"; > = {0,0,0,0};
float4 Combiner4_Input1			< string UIName = "Combiner4_Input1"; > = {0,0,0,0};
float4 Combiner4_Input2			< string UIName = "Combiner4_Input2"; > = {0,0,0,0};
float3 Combiner4_Color_Output	< string UIName = "Combiner4_Color_Output"; > = {0,0,0};
float3 Combiner4_Alpha_Output	< string UIName = "Combiner4_Alpha_Output"; > = {0,0,0};

bool Use_Combiner5 				< string UIName = "Use_Combiner5"; > = false;
float4 Combiner5_Color 			< string UIName = "Combiner5_Color"; > = {1,1,1,1};
float4 Combiner5_Input0			< string UIName = "Combiner5_Input0"; > = {0,0,0,0};
float4 Combiner5_Input1			< string UIName = "Combiner5_Input1"; > = {0,0,0,0};
float4 Combiner5_Input2			< string UIName = "Combiner5_Input2"; > = {0,0,0,0};
float3 Combiner5_Color_Output	< string UIName = "Combiner5_Color_Output"; > = {0,0,0};
float3 Combiner5_Alpha_Output	< string UIName = "Combiner5_Alpha_Output"; > = {0,0,0};

// Animations =============================

bool Use_Animation0 			< string UIName = "Use_Animation0"; > = false;
float4 Animation0_uMotion		< string UIName = "Animation0_uMotion"; > = {0.5,0,0,0};
float4 Animation0_vMotion		< string UIName = "Animation0_vMotion"; > = {0.5,0,0,0};
float4 Animation0_Translation	< string UIName = "Animation0_Translation"; > = {0,0,0,0};
float4 Animation0_Rotation		< string UIName = "Animation0_Rotation"; > = {0,0,0,0};

bool Use_Animation1 			< string UIName = "Use_Animation1"; > = false;
float4 Animation1_uMotion		< string UIName = "Animation1_uMotion"; > = {0.5,0,0,0};
float4 Animation1_vMotion		< string UIName = "Animation1_vMotion"; > = {0.5,0,0,0};
float4 Animation1_Translation	< string UIName = "Animation1_Translation"; > = {0,0,0,0};
float4 Animation1_Rotation		< string UIName = "Animation1_Rotation"; > = {0,0,0,0};

bool Use_Animation2 			< string UIName = "Use_Animation2"; > = false;
float4 Animation2_uMotion		< string UIName = "Animation2_uMotion"; > = {0.5,0,0,0};
float4 Animation2_vMotion		< string UIName = "Animation2_vMotion"; > = {0.5,0,0,0};
float4 Animation2_Translation	< string UIName = "Animation2_Translation"; > = {0,0,0,0};
float4 Animation2_Rotation		< string UIName = "Animation2_Rotation"; > = {0,0,0,0};

////////////////////////////////
// Scene matrices.
///////////////////////////////
float4x4 worldViewProj	: WorldViewProjection;
float4x4 worldView		: WorldView;
float4x4 world			: World;
float4x4 view			: View;
float4x4 viewInv		: ViewInverse;
//float4x4 viewProj		: ViewProjection;
float4x4 proj			: Projection;

////////////////////////////////
// VC tweakables.
///////////////////////////////

bool Enable_Adjustments 	< string UIName = "Enable_Adjustments"; > = false;
int Adjustment_Type 		< string UIName = "Adjustment_Type"; > = 0;

float ColorR <
    string UIWidget = "slider";
	string UIName = "ColorR"; 
    float UIMin = -1.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 0.0f;

float ColorG <
    string UIWidget = "slider";
	string UIName = "ColorG"; 
    float UIMin = -1.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 0.0f;

float ColorB <
    string UIWidget = "slider";
	string UIName = "ColorB"; 
    float UIMin = -1.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 0.0f;

float Hue <
    string UIWidget = "slider";
	string UIName = "Hue"; 
    float UIMin = -1.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 0.0f;

float Saturation <
    string UIWidget = "slider";
	string UIName = "Saturation"; 
    float UIMin = -1.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 0.0f;
/*
float Lightness <
    string UIWidget = "slider";
	string UIName = "Lightness"; 
    float UIMin = -1.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 0.0f;
*/
float Brightness <
    string UIWidget = "slider";
	string UIName = "Brightness"; 
    float UIMin = -1.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 0.0f;

float Contrast <
    string UIWidget = "slider";
	string UIName = "Contrast"; 
    float UIMin = -1.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 0.0f;

bool Clamp_Normalize < string UIName = "Clamp_Normalize"; > = false;

float ClampMin <
    string UIWidget = "slider";
	string UIName = "ClampMin"; 
    float UIMin = .0f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 0.0f;

float ClampMax <
    string UIWidget = "slider";
	string UIName = "ClampMax"; 
    float UIMin = .0f;
    float UIMax = 1.0f;
    float UIStep = 0.01f;
> = 1.0f;

////////////////////////////////
// misc utility functions.
////////////////////////////////
#define PI 3.14159265f
#define HPI PI/2
#define DPI PI/180

float3 RGBToHSL(float3 color)
{
	float3 hsl; // init to 0 to avoid warnings ? (and reverse if + remove first part)
	
	float fmin = min(min(color.r, color.g), color.b);    //Min. value of RGB
	float fmax = max(max(color.r, color.g), color.b);    //Max. value of RGB
	float delta = fmax - fmin;             //Delta RGB value

	hsl.z = (fmax + fmin) / 2.0; // Luminance

	if (delta == 0.0)		//This is a gray, no chroma...
	{
		hsl.x = 0.0;	// Hue
		hsl.y = 0.0;	// Saturation
	}
	else                                    //Chromatic data...
	{
		if (hsl.z < 0.5)
			hsl.y = delta / (fmax + fmin); // Saturation
		else
			hsl.y = delta / (2.0 - fmax - fmin); // Saturation
		
		float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
		float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
		float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;

		if (color.r == fmax )
			hsl.x = deltaB - deltaG; // Hue
		else if (color.g == fmax)
			hsl.x = (1.0 / 3.0) + deltaR - deltaB; // Hue
		else if (color.b == fmax)
			hsl.x = (2.0 / 3.0) + deltaG - deltaR; // Hue

		if (hsl.x < 0.0)
			hsl.x += 1.0; // Hue
		else if (hsl.x > 1.0)
			hsl.x -= 1.0; // Hue
	}

	return hsl;
}

float HueToRGB(float f1, float f2, float hue)
{
	if (hue < 0.0)
		hue += 1.0;
	else if (hue > 1.0)
		hue -= 1.0;
	float res;
	if ((6.0 * hue) < 1.0)
		res = f1 + (f2 - f1) * 6.0 * hue;
	else if ((2.0 * hue) < 1.0)
		res = f2;
	else if ((3.0 * hue) < 2.0)
		res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
	else
		res = f1;
	return res;
}

float3 HSLToRGB(float3 hsl)
{
	float3 col;
	
	if (hsl.y == 0.0) col = float3(hsl.z,hsl.z,hsl.z); // Luminance
	else
	{
		float f2;
		
		if (hsl.z < 0.5)
			f2 = hsl.z * (1.0 + hsl.y);
		else
			f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
			
		float f1 = 2.0 * hsl.z - f2;
		
		col.r = HueToRGB(f1, f2, hsl.x + (1.0/3.0));
		col.g = HueToRGB(f1, f2, hsl.x);
		col.b = HueToRGB(f1, f2, hsl.x - (1.0/3.0));
	}
	
	return col;
}

float4x4 rotateMat(float3 d, float hue)
{
    float ang = -hue*PI;
	float s = sin(ang);
    float c = cos(ang);
    d = normalize(d);
    
	return float4x4
	(
		d.x*d.x*(1 - c) + c,
			d.x*d.y*(1 - c) - d.z*s,
			d.x*d.z*(1 - c) + d.y*s,
				0,
		d.x*d.y*(1 - c) + d.z*s,
			d.y*d.y*(1 - c) + c,
			d.y*d.z*(1 - c) - d.x*s,
				0, 
		d.x*d.z*(1 - c) - d.y*s,
			d.y*d.z*(1 - c) + d.x*s,
			d.z*d.z*(1 - c) + c,
				0, 
		0, 0, 0, 1
	);
}
	
static float4x4 hueMatrix = rotateMat(float3(1, 1, 1), Hue);
static float con = (Contrast < 0) ? (Contrast + 1.0) : pow(Contrast + 1.0, 3);
static float sat = (Saturation < 0) ? (Saturation + 1.0) : pow(Saturation + 1.0, 3);
static float brt = (Brightness < 0) ? (Brightness + 1.0) : pow(Brightness + 1.0, 3);
static float3 rgb = float3(ColorR, ColorG, ColorB);
//static float lit = (Lightness + 1.0);
	
float3 ColorRGB(float3 color)
{
	return saturate(color+rgb);
}
float3 ColorHue(float3 color)
{
	return mul(color, hueMatrix);
}
float3 mix(float3 x, float3 y, float a)
{
	return (x*(1.0 - a) + y*a);
} 	
float3 ColorContrastSaturationBrightness(float3 color)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;
	
	const float3 LumCoeff = float3(0.2125, 0.7154, 0.0721);
	
	float3 AvgLumin = float3(AvgLumR, AvgLumG, AvgLumB);
	float3 brtColor = color * brt;
	float3 intensity = dot(brtColor, LumCoeff);
	float3 satColor = mix(intensity, brtColor, sat);
	float3 conColor = mix(AvgLumin, satColor, con);
	return conColor;
}
float3 ColorLightness(float3 color, float lit)
{
	float3 hls = RGBToHSL(color);
	hls.z *= lit;
	return HSLToRGB(hls);
}
////////////////////////////////////////////////////////////////////////////////////////////
// Shader.
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////
// Vertex input declarition
////////////////////////////////
struct VertexInput {
	float3	pos			: POSITION;
	float3	normal		: NORMAL;
	float3	binormal	: BINORMAL0;
	float3	tangent		: TANGENT0;
	float2	texCoord0	: TEXCOORD0;
	float2	texCoord1	: TEXCOORD1;
	float2	texCoord2	: TEXCOORD2;
	float2	texCoord3	: TEXCOORD3;
#ifdef _3DSMAX_
	float3 ColorRGB		: TEXCOORD4;
	float3 ColorA		: TEXCOORD5;
#else
	float4 Color0 		: COLOR0;
#endif
};

////////////////////////////////
// Pixel input declarition
////////////////////////////////
struct PixelInput {
	float4	hPos		: POSITION;
	float2  texCoord0   : TEXCOORD0;
	float2  texCoord1   : TEXCOORD1;
	float2  texCoord2   : TEXCOORD2;
	float2  texCoord3   : TEXCOORD3;
	float2  texCoord4   : TEXCOORD4;
	float3	normal		: TEXCOORD5;
	float3	binormal	: TEXCOORD6;
	float3	tangent		: TEXCOORD7;
	float3	worldPos	: TEXCOORD8;
	float4	vertexColor	: COLOR0;
};

#define AnimationX_Motion float4x4(float4(0,0,0,0),float4(0,0,0,0),float4(0,0,0,0),float4(0,0,0,0))
struct CombinerData {
	float3x4	abc;
	float4		color;
	float2x3	output;
};
struct MotionData {
	float4x4	motion0;
	float4x4	motion1;
	float4x4	motion2;
};

static float4x4 Animation0_Motion = (Use_Animation0)*float4x4(Animation0_uMotion, Animation0_vMotion, Animation0_Translation, Animation0_Rotation);
static float4x4 Animation1_Motion = (Use_Animation1)*float4x4(Animation1_uMotion, Animation1_vMotion, Animation1_Translation, Animation1_Rotation);
static float4x4 Animation2_Motion = (Use_Animation2)*float4x4(Animation2_uMotion, Animation2_vMotion, Animation2_Translation, Animation2_Rotation);

static MotionData AnimationData = {Animation0_Motion,Animation1_Motion,Animation2_Motion};


float4 ColorOperand (float4 color, float c)
{
	float4 c_operands[10];
	
	c_operands[0] = color.rgba;
	c_operands[1] = color.aaaa;
	c_operands[2] = color.rrrr;
	c_operands[3] = color.gggg;
	c_operands[4] = color.bbbb;

	c_operands[5] = 1-color.rgba;
	c_operands[6] = 1-color.aaaa;
	c_operands[7] = 1-color.rrrr;
	c_operands[8] = 1-color.gggg;
	c_operands[9] = 1-color.bbbb;
	
	return c_operands[c];
}
float4 ComboOperand (float4 color, float c, float4 alpha, float a)
{
	float4 cc = ColorOperand (color, c);
	float4 aa = ColorOperand (alpha, a);
	return float4(cc.rgb,aa.a);
}
void CombinerOUT (CombinerData d, inout float4 Inputs [10]) {
		
		float4 result = 0;
		float4 buffer = Inputs[8];
		
		Inputs[9] = d.color;
			
		float4 a = d.abc[0];
		float4 b = d.abc[1];
		float4 c = d.abc[2];
		
		float4 A = ComboOperand(Inputs[a.x],a.y,Inputs[a.z],a.w);
		float4 B = ComboOperand(Inputs[b.x],b.y,Inputs[b.z],b.w);
		float4 C = ComboOperand(Inputs[c.x],c.y,Inputs[c.z],c.w);

		float4 results[10];
		results[0] = A;
		results[1] = A*B;
		results[2] = A+B;
		results[3] = A+B-0.5;
		results[4] = A*C + B*(1-C);
		results[5] = A-B;
		results[6] = saturate(A+B)*C;
		results[7] = A*B+C;
		
		float v = dot(A.rgb,B.rgb);
		results[8] = float4 (v,v,v,1);
		results[9] = float4 (v,v,v,v);
		
		float cs = pow(2,d.output[0].y);
		float as = pow(2,d.output[1].y);
		result = float4(results[d.output[0].x].rgb,results[d.output[1].x].a);
//		result = saturate(result*float4(cs,cs,cs,as));
		result = result*float4(cs,cs,cs,as);
		
		buffer.rgb = float2x3(buffer.rgb,result.rgb)[d.output[0].z];
		buffer.a = float2(buffer.a, result.a)[d.output[1].z];
			
		Inputs[8] = saturate(buffer);
		Inputs[0] = saturate(result);
}		


CombinerData UnpackCombiner (bool use, float4 a, float4 b, float4 c, float4 color, float3 c_out, float3 a_out) 
{
	CombinerData combo;
	
	combo.abc = float3x4(a,b,c)*use;
	combo.color = color;
	combo.output = float2x3(c_out, a_out)*use;
	
	return combo;
}

// Calculates various lighting/shadow contributions ================


// Cacluate texture coordinates ====================================
static float currenttime = 	
		#ifdef _3DSMAX_
			(Time*6.25/30);
		#else
			(Time);
		#endif

float2 CalcTextureCoord (float2 coord, float4 mat_u, float4 mat_v, float use, MotionData data)
{
	float t = currenttime;
	float c,s;

	sincos(mat_u.w*DPI,s,c);
	float2 uv_coords = mul(coord,float2x2(c,-s,s,c));
	#ifdef _3DSMAX_
		uv_coords += float2(0,1);
	#endif
	
	if (use != 0) 
	{
		float4x4 Anim = (use == 1) ? data.motion0 : (use == 2) ? data.motion1 : data.motion2;

		sincos(t*Anim[3].x*DPI,s,c);
		uv_coords -= Anim[3].yz;
		uv_coords = mul(uv_coords,float2x2(c,-s,s,c));
		uv_coords += Anim[3].yz;

		float sx = Anim[0].x*(sin ((Anim[0].z*t*Anim[0].y)*DPI));
		float sy = Anim[1].x*(cos ((Anim[1].z*t*Anim[1].y + Anim[1].w)*DPI));
		
		mat_u.z += Anim[2].x*Anim[2].y;
		mat_v.z += Anim[2].x*Anim[2].z;
		uv_coords += float2(sx,sy);
	}
	uv_coords = float2(mat_u.y,mat_v.y)*uv_coords + float2(mat_u.x,mat_v.x) + float2(mat_u.z,mat_v.z)*t;
	
	return uv_coords;
}

float2 pattern0 (float2 coord) { return float2(sqrt(coord.x*coord.x + coord.y*coord.y), 0); }			
float2 pattern1 (float2 coord) { return float2(abs(coord.x), 0); }
float2 pattern2 (float2 coord) { return float2(abs(coord.y), 0); }
float2 pattern3 (float2 coord) { return float2(min(abs(coord.x),abs(coord.y)), 0); }
float2 pattern4 (float2 coord) { return float2(max(abs(coord.x),abs(coord.y)), 0); }
float2 pattern5 (float2 coord) { return float2(abs(coord.x) + abs(coord.y), 0); }
float2 pattern6 (float2 coord) { return float2((sqrt(coord.x*coord.x + coord.y*coord.y))*(abs(coord.x) + abs(coord.y)), 0); }
float2 pattern7 (float2 coord) { return float2(coord.x*coord.x + coord.y*coord.y, 0); }
float2 pattern8 (float2 coord) { return float2(coord.x*coord.x, 0); }
float2 pattern9 (float2 coord) { return float2(coord.y*coord.y, 0); }
float2 patternX (float2 coord) { return float2(coord.x, coord.y); }
			
float2 CalcProceduralCoord (inout float2 coord, float4 mat_u, int factor, float use, MotionData data)
{
	float t = currenttime;
	float c,s;
	
	float address = Procedural_Map_uNoise[3];
	float odd = Procedural_Map_uShiftMode;

//	sincos(90*DPI,s,c);
	
	float u = Procedural_Map_Noise_Only_U;
	float v = (1 - u);
	
	coord = float2(mat_u.x,mat_u.y)*coord; 
	
	float2 cc = coord;
	if (address == 3) {
		if (fmod(floor(coord.x - odd),2) == 0) coord.y -= u*Procedural_Map_vNoise[3]; 
		if (fmod(floor(coord.y - odd),2) == 0) coord.x += v*Procedural_Map_vNoise[3]; 
		cc = 2*fmod(coord,1) - float2(1,-1);
	}
	else { 
		if (fmod(floor((coord.x - odd)/2),2) == 0) coord.y -= u*Procedural_Map_vNoise[3]; 
		if (fmod(floor((coord.y - odd)/2),2) == 0) coord.x += v*Procedural_Map_vNoise[3]; 
		cc = fmod(coord,1);
	}

	if (address == 2) {
		if (fmod(floor(coord.x),2) == 0) cc = cc - float2(1,0);
		if (fmod(floor(coord.y),2) != 0) cc = cc - float2(0,-1);
	}

	coord = cc;
		
	float2 patterns[11] = 
		{
			pattern0(cc),pattern1(cc),pattern2(cc),pattern3(cc),pattern4(cc),
			pattern5(cc), pattern6(cc),pattern7(cc),pattern8(cc),pattern9(cc), patternX(cc) 
		}; 
	
	float2 uv_coords = patterns[factor];

/*
	if (use != 0) 
	{
		float3x3 Anim = (use == 1) ? data.motion0 : (use == 2) ? data.motion1 : data.motion2;

		sincos(t*Anim[2].x*DPI,s,c);
		uv_coords -= Anim[2].yz;
//		uv_coords -= float2(Anim[2].y,-Anim[2].z);
		uv_coords = mul(uv_coords,float2x2(c,-s,s,c));
		uv_coords += Anim[2].yz;
//		uv_coords += float2(Anim[2].y,-Anim[2].z);

		float sx = Anim[0].x*(sin ((Anim[0].y*t + Anim[0].z)*DPI));
		float sy = Anim[1].x*(sin ((Anim[1].y*t + Anim[1].z)*DPI));
		uv_coords += float2(sx,sy);
	}
*/
	return uv_coords;
}		

float4 ColorConversion (float4 color)
{
	float A = color.a;
	color = color*255;
	float R = 
		  0.00000000000483248154*pow(color.r,6) 
		- 0.00000000365657475197*pow(color.r,5) 
		+ 0.00000102757545328291*pow(color.r,4) 
		- 0.00012874649109306800*pow(color.r,3) 
		+ 0.00614448620945041000*pow(color.r,2) 
		+ 1.01590738243613000000*pow(color.r,1);
	float G = 
		  0.00000000000329555011*pow(color.g,6) 
		- 0.00000000244753003129*pow(color.g,5) 
		+ 0.00000065405100738158*pow(color.g,4) 
		- 0.00007222040740728630*pow(color.g,3) 
		+ 0.00144633215450085000*pow(color.g,2) 
		+ 1.27791283459010000000*pow(color.g,1);
	float B = 
		  0.00000000000491878788*pow(color.b,6) 
		- 0.00000000394859958012*pow(color.b,5) 
		+ 0.00000117626844803320*pow(color.b,4) 
		- 0.00016190261042226000*pow(color.b,3) 
		+ 0.00939849207111365000*pow(color.b,2) 
		+ 1.02038300762433000000*pow(color.b,1);
		
	return float4(R/255,G/255,B/255,A);
}

////////////////////////////////
// Vertex shader
////////////////////////////////
PixelInput VShader(VertexInput IN)
{
	PixelInput OUT;
		
	// Max Skinned

	OUT.normal 		= normalize(mul(float4(IN.normal,0),world).xyz);
	OUT.tangent 	= normalize(mul(float4(IN.tangent,0),world).xyz);
	OUT.binormal 	= normalize(mul(float4(IN.binormal,0),world).xyz);

	OUT.worldPos 	= mul(float4(IN.pos,1),world).xyz;
	OUT.hPos 		= mul(float4(IN.pos,1),worldViewProj);

	float4x2 texCoords = float4x2(IN.texCoord0, IN.texCoord1, IN.texCoord2, IN.texCoord3);

	OUT.texCoord0 = CalcTextureCoord(texCoords[Texture0_Channel],Texture0_Map_uCoord,Texture0_Map_vCoord, Texture0_Map_Anim, AnimationData);
	OUT.texCoord1 = CalcTextureCoord(texCoords[Texture1_Channel],Texture1_Map_uCoord,Texture1_Map_vCoord, Texture1_Map_Anim, AnimationData);
	OUT.texCoord2 = CalcTextureCoord(texCoords[Texture2_Channel],Texture2_Map_uCoord,Texture2_Map_vCoord, Texture2_Map_Anim, AnimationData);
	OUT.texCoord3 = texCoords[Procedural_Channel];
	OUT.texCoord4 = texCoords[Procedural_Channel]; //CalcProceduralCoord(texCoords[Procedural_Channel],Procedural_Factor, 0, AnimationData);
		
	float4 vertexColor = 1;
	if (Use_Vertex_Color)
	{
		vertexColor = 
			#ifdef _3DSMAX_
				float4(IN.ColorRGB,IN.ColorA.r);
			#else
				IN.Color0;
			#endif
		if ((Enable_Adjustments) && (!Adjustment_Type))
		{
			vertexColor.rgb = ColorRGB(vertexColor.rgb);
			vertexColor.rgb = ColorHue(vertexColor.rgb);
			vertexColor.rgb = ColorContrastSaturationBrightness(vertexColor.rgb); 
			if (Clamp_Normalize) vertexColor.rgb = vertexColor.rgb*(ClampMax-ClampMin) + ClampMin;
			else vertexColor.rgb = clamp(vertexColor.rgb,ClampMin,ClampMax);
		}
		vertexColor = saturate(vertexColor);
	}
	OUT.vertexColor = vertexColor;
	return OUT;
}

//static const float PI = 3.14159265f;

float range (float d) { return ((d+1)/2.0); }
float limit (float d) { return (saturate(d)/2.0 + 0.5); }
float getAnimCoord (int type, float rate)
{
	float t = Time*rate*6.25/30.0; //sin(Time*6.25/30
	float t_loop = frac(t); 
	float t_ping = abs(sin(t*PI)); 
	float t_hold = clamp(t,0,1); 
	return float4(0,t_loop,t_ping,t_hold)[type];
}

float4 GetTableMap (sampler2D Sampler, float2 coords)
{
	return tex2D(Sampler,coords);
}
		
float4 GetTextureMap (sampler2D Sampler, float2 coords, float bias)
{
	return tex2Dbias(Sampler,float4(coords.xy,0,bias));
}

float4 GetNormalMap (sampler2D Sampler, float2 coords, float bias, 
						inout float3 normal, in float3 tangent, in float3 binormal, 
						float scale, inout bool used )
{
	float4 tex = GetTextureMap(Sampler,coords.xy,bias);
	if (!used) 
	{
		float4 nm = tex*2 - 1;
		float3 map = (tex*2 - 1).rgb; 
		
		map.xy *= scale;
		float normal_z = sqrt(1-map.x*map.x-map.y*map.y);
		normal = normalize((normal * normal_z) + (tangent * map.y) + (binormal * map.x));
		used = true;
	}
	return tex;
}

float4 GetEnvironmentMap (samplerCUBE Sampler, float bias, 
						float3 view, float3 normal, float factor, inout bool used )
{
	float4 tex = 0;
	if (!used) 
	{
		float3 ref = reflect(-view,normal);
		float3 col = texCUBEbias(Sampler,float4(ref.xzy,bias));
		tex = float4(col*factor,1);
		used = true;
	}
	return tex;
}

void MakeLightTable (float3 lightDir, float3 camDir, float3 halfDir, float3 normal, float3 tangent, out float4 table[6])
{
	float NdotL = dot(normal, lightDir);
	float NdotC = dot(normal, camDir);
	float NdotH = dot(normal, halfDir);
	float CdotH = dot(camDir, halfDir);
	
	float AdotT = dot(tangent,normalize(halfDir - NdotH*normal));	
		
	table[0] = saturate (float4 (range(NdotL), abs(NdotL), limit(NdotL), 1.5-limit(NdotL)));
	table[1] = saturate (float4 (range(NdotC), abs(NdotC), limit(NdotC), 1.5-limit(NdotC)));
	table[2] = saturate (float4 (range(NdotH), abs(NdotH), limit(NdotH), 1.5-limit(NdotH)));
	table[3] = saturate (float4 (range(CdotH), abs(CdotH), limit(CdotH), 1.5-limit(CdotH)));

	table[4] = table[0];
	table[5] = saturate (float4 (range(AdotT), abs(AdotT), limit(AdotT), 1.5-limit(AdotT)));
}			
		
//---------------------------------------------------------------------------------------
// The combine body of the pixel shader, called from the various entry point functions.
//---------------------------------------------------------------------------------------

float2 _HeightMap_TexelSize = {0.1,0.1};
      
float4 GetHeightMap (sampler2D Sampler, float2 coords, float c, float2 texel, float height)
{		
//	float c	= tex2D(Sampler, coords.xy).r;
	float x	= tex2D(Sampler, coords.xy + float2(texel.x, 0)).r;
	float y	= tex2D(Sampler, coords.xy + float2(0,texel.y)).r;

//	x = x*2-1;
//	y = y*2-1;
		
	float3 v_x 	= float3(1, 0, (x - c)*height);
	float3 v_z 	= float3(0, 1, (y - c)*height);
      
    float4 tex = 1;
	tex.xyz = cross(v_x, v_z);
	tex.xyz = normalize(tex.xyz);
 	tex.xy = (tex.xy+1)/2;
    return tex;
}

float4 GetHeightPro (sampler2D Sampler, float2 coords, float c, float2 texel, float height)
{		
	float x	= tex2D(Sampler, coords.xy + float2(texel.x, 0)).r;
		
	float3 v_x 	= float3(1, 0, (x - c)*height);
	float3 v_z 	= float3(0, 1, (x - c)*height);
      
    float4 tex = 1;
	tex.xyz = cross(v_x, v_z);
//	tex.xyz = normalize(tex.xyz);
 	tex.xy = (tex.xy+1)/2;
    return tex;
}
		
float3 MakeNormal (float4 tex, float3 normal, float3 tangent, float3 binormal, float height)
{
	float3 normalMap = tex.xyz; 
	normalMap.xy = (Use_Height_Map) ? tex.xy : (tex.xy*2.0 - 1.0)*height; 
	float normal_z = (!Gen_Normal_Z) ? normalMap.z : sqrt(1-normalMap.x*normalMap.x-normalMap.y*normalMap.y);
	float3 normal_n = (normal * normal_z) + (tangent * normalMap.y) + (binormal * normalMap.x);
	return (Use_Height_Map) ? normal_n : normalize(normal_n);
}		
float4 PixelShaderCombine(PixelInput IN, int maxPointLights, int shadowSample)
{
	float t = currenttime;
		
	float3	normal = normalize(IN.normal);
	float3	binormal = normalize(IN.binormal);
	float3	tangent = normalize(IN.tangent);
	float3	worldPos = IN.worldPos;
	float3 	camPos = viewInv[3].xyz;
	float3 	camDir = normalize(camPos-worldPos);
	float3	lightDir0 = normalize((Light0_Type == 1) ? Light0_Direction.xyz : (Light0_Position.xyz - worldPos.xyz));
	float3 	halfDir0 = normalize(camDir+lightDir0.xyz);
	float	eyeDist = length(worldPos-viewInv[3].xyz);
			
	float3	lightDir1 = normalize((Light1_Type == 1) ? Light1_Direction.xyz : (Light1_Position.xyz - worldPos.xyz));
	float3 	halfDir1 = normalize(camDir+lightDir1.xyz);
	float3	lightDir2 = normalize((Light2_Type == 1) ? Light2_Direction.xyz : (Light2_Position.xyz - worldPos.xyz));
	float3 	halfDir2 = normalize(camDir+lightDir2.xyz);
			
	bool normalUsed = false;
	
	float4 Inputs [10] = 
	{
		{0,0,0,1}, // Previous
		{0,0,0,0}, // Vertex RGBA
		{1,1,1,1}, // Diffuse - Primary Color
		{1,1,1,1}, // Specular - Secondary Color
		{1,1,1,1}, // Texture 0
		{1,1,1,1}, // Texture 1
		{1,1,1,1}, // Texture 2
		{0,0,0,0}, // Procedural
		{0,0,0,1}, // Buffer
		{1,1,1,1}  // Constant
	};

	Inputs[1] = IN.vertexColor;
	
//	float4 diffuse = Diffuse_Color*IN.vertexColor;
	
	float3 refCol = 1;

	if ((Use_Texture0) &&  (Texture0_Type != 3)) {
		float4 tex = GetTextureMap(Texture0_Map_Sampler,IN.texCoord0.xy,Texture0_Bias);
		if (((Texture0_Type == 1) || (Texture0_Type == 2)) && (!normalUsed)) {
			float3 normal_n =  MakeNormal (tex, normal, tangent, binormal, Texture0_Height);
			if (Texture0_Type == 1) normal = normal_n; else tangent = normal_n;
			normalUsed = true;
		}
		Inputs[4] = tex;
	}	

	if (Use_Texture1) {
		float4 tex = GetTextureMap(Texture1_Map_Sampler,IN.texCoord1.xy,Texture1_Bias);
		if (Texture1_Type > 0) 
		{
			if (Texture1_Type == 3) 
			{
				tex = GetHeightMap (Texture1_Map_Sampler,IN.texCoord1.xy, tex, Height_Texel_Size,Texture1_Height);
				float3 normal_n = MakeNormal (tex, normal, tangent, binormal, 1);
				normal = normal_n;
			}
			else if (!normalUsed)
			{
				float3 normal_n = MakeNormal (tex, normal, tangent, binormal, Texture1_Height);
				if (Texture1_Type == 1) normal = normal_n; else tangent = normal_n;
				normalUsed = true;
			}
		}
		Inputs[5] = tex;
	}	
	
	if (Use_Texture2) {
		float4 tex = GetTextureMap(Texture2_Map_Sampler,IN.texCoord2.xy,Texture2_Bias);
		if ((Enable_Adjustments) && (Adjustment_Type == 1))
		{
			tex.rgb = ColorRGB(tex.rgb);
			tex.rgb = ColorHue(tex.rgb);
			tex.rgb = ColorContrastSaturationBrightness(tex.rgb); 
			if (Clamp_Normalize) tex.rgb = tex.rgb*(ClampMax-ClampMin) + ClampMin;
			else tex.rgb = clamp(tex.rgb,ClampMin,ClampMax);
		}
		if (Texture2_Type > 0) 
		{
			if (Texture2_Type == 3) 
			{
				tex = GetHeightMap (Texture2_Map_Sampler,IN.texCoord2.xy, tex, Height_Texel_Size,Texture2_Height);
				float3 normal_n = MakeNormal (tex, normal, tangent, binormal, 1);
				normal = normal_n;
			}
			else if (!normalUsed)
			{
				float3 normal_n = MakeNormal (tex, normal, tangent, binormal, Texture2_Height);
				if (Texture2_Type == 1) normal = normal_n; else tangent = normal_n;
				normalUsed = true;
			}
		}
		Inputs[6] = tex;
	}
	if (Use_Procedural) {
		float4 u = Procedural_Map_uNoise;
		float4 v = Procedural_Map_vNoise;
		float2 tex_coord = IN.texCoord4.xy;
		float2 uv_coords = CalcProceduralCoord(tex_coord, Procedural_Map_uCoord, Procedural_Factor, 0, AnimationData);

		float4 pro = 0;
		if (Use_Procedural_Noise) {
			float2 uv = 2*lerp(fmod(tex_coord, 1), IN.texCoord3.xy, v[0]) + float2(1,-1);

			pro = GetTextureMap(Procedural_Map_Sampler,float2(u.y,v.y)*(uv + float2(u.z,v.z) + float2(u.z,v.z)*Procedural_Map_uCoord.z*t),0);
//			pro = GetTextureMap(Procedural_Map_Sampler,float2(u.y,v.y)*(uv + float2(u.z,v.z) + float2(u.z,v.z)),0);
			pro = (2*pro - 1)*u.x;	
		}

		float4 fun = (Procedural_Function) ? GetTableMap(Procedural_Function_Table_Sampler,uv_coords.xy) : uv_coords.xxxx;
		float2 uva = fun.x + pro.x;
		float4 tex = GetTableMap(Procedural_Color_Table_Sampler,uva);
//		tex.a = (GetTableMap(Procedural_Color_Table_Sampler,uva*Procedural_Map_uCoord.z)).a;
//		tex *= Procedural_Scale;
			
		if (Procedural_Type > 0) 
		{
			if (Procedural_Type == 3) 
			{
				tex = GetHeightPro(Procedural_Color_Table_Sampler, uva, tex, Height_Texel_Size, Procedural_Scale);
				float3 normal_n = MakeNormal (tex, normal, tangent, binormal, 1);
				normal = normal_n;
			}
			else if (!normalUsed)
			{
				float3 normal_n = MakeNormal (tex, normal, tangent, binormal, Procedural_Scale);
				if (Procedural_Type == 1) normal = normal_n; else tangent = normal_n;
				normalUsed = true;
			}
		}
		Inputs[7] = tex;
	}

	if ((Use_Texture0) && (Texture0_Type == 3)) {
		float3 r = reflect(-camDir,normal);
		refCol = texCUBEbias(Reflection_Map_Sampler,float4(r.xzy,Texture0_Bias));
		float4 tex = float4(refCol*Texture0_Reflect,1);
		
		Inputs[4] = tex;
	}
/*				
	Inputs[7] = (float4(normal.xyz,-1)+1)/2;
*/
				
	float4 table0 [6];
	MakeLightTable (lightDir0, camDir, halfDir0, normal, tangent, table0);
	float NdotL0 = saturate(dot(normal, lightDir0));

	float4 table1 [6];
	MakeLightTable (lightDir1, camDir, halfDir1, normal, tangent, table1);
	float NdotL1 = saturate(dot(normal, lightDir1));
		
	float4 table2 [6];
	MakeLightTable (lightDir2, camDir, halfDir2, normal, tangent, table2);
	float NdotL2 = saturate(dot(normal, lightDir2));
			
	float4 fresnel = 1;
	float x,x0,x1,x2,y;
		
	if (Use_Fresnel) 
	{
		x = table0[Fresnel_Type][Fresnel_Factor];
		y = getAnimCoord (Fresnel_Anim, Fresnel_Anim_Rate);
		fresnel = GetTableMap(Fresnel_Table_Sampler, float2(x,y));
		fresnel.rgba = fresnel.rrrr;
	}
		
	float2 primary_alphas 	= float2(fresnel.a, Primary_Alpha_Value);
	float2 secondary_alphas = float2(fresnel.a, Secondary_Alpha_Value);

	float3 ambient = 0; 		
	ambient += (Add_Light0)*Light0_Ambient_Color;		
	ambient += (Add_Light1)*Light1_Ambient_Color;		
	ambient += (Add_Light2)*Light2_Ambient_Color;
	ambient = saturate(ambient*Ambient_Color);			

	float3 diffuse = 0; 		
	diffuse += (Add_Light0)*NdotL0*Light0_Diffuse_Color;		
	diffuse += (Add_Light1)*NdotL1*Light1_Diffuse_Color;		
	diffuse += (Add_Light2)*NdotL2*Light2_Diffuse_Color;		
	diffuse = saturate(diffuse*Diffuse_Color);
		
	float3 primary = saturate(ambient + diffuse);
			
	Inputs[2] = float4(primary.rgb, primary_alphas[Primary_Alpha_Type]);
		
	float4 secondary = 0;
	if (Use_Specular0) 
	{
		x0 = table0[Specular0_Type][Specular0_Factor];
		x1 = table1[Specular0_Type][Specular0_Factor];
		x2 = table2[Specular0_Type][Specular0_Factor];
		y = getAnimCoord (Specular0_Anim, Specular0_Anim_Rate);
		
		float4 texTab0 = (Add_Light0)*GetTableMap(Specular0_Table_Sampler, float2(x0,y));
		float4 texTab1 = (Add_Light1)*GetTableMap(Specular0_Table_Sampler, float2(x1,y));
		float4 texTab2 = (Add_Light2)*GetTableMap(Specular0_Table_Sampler, float2(x2,y));
		secondary += texTab0.r*Light0_Specular_Color*Specular0_Color;
		secondary += texTab1.r*Light1_Specular_Color*Specular0_Color;
		secondary += texTab2.r*Light2_Specular_Color*Specular0_Color;
	}
			
	if (Use_Specular1) 
	{
		x0 = table0[Specular1_Type][Specular1_Factor];
		x1 = table1[Specular1_Type][Specular1_Factor];
		x2 = table2[Specular1_Type][Specular1_Factor];
		y = getAnimCoord (Specular1_Anim, Specular1_Anim_Rate);
			
		float4 texTab0 = (Add_Light0)*GetTableMap(Specular1_Table_Sampler, float2(x0,y));
		float4 texTab1 = (Add_Light1)*GetTableMap(Specular1_Table_Sampler, float2(x1,y));
		float4 texTab2 = (Add_Light2)*GetTableMap(Specular1_Table_Sampler, float2(x2,y));
	
		float4 specCol0 = Specular1_Color;
		float4 specCol1 = Specular1_Color;
		float4 specCol2 = Specular1_Color;
			
		if (Use_Reflection) 
		{
			x0 = table0[Reflection_R_Type][Reflection_R_Factor];
			x1 = table1[Reflection_R_Type][Reflection_R_Factor];
			x2 = table2[Reflection_R_Type][Reflection_R_Factor];
			y = getAnimCoord (Reflection_R_Anim, Reflection_R_Anim_Rate);

			float4 tabR0 = (Add_Light0)*GetTableMap(Reflection_Table_Sampler, float2(x0,y));
			float4 tabR1 = (Add_Light1)*GetTableMap(Reflection_Table_Sampler, float2(x1,y));
			float4 tabR2 = (Add_Light2)*GetTableMap(Reflection_Table_Sampler, float2(x2,y));
			
			if (!Reflection_Only_R)	
			{
				x0 = table0[Reflection_G_Type][Reflection_G_Factor];
				x1 = table1[Reflection_G_Type][Reflection_G_Factor];
				x2 = table2[Reflection_G_Type][Reflection_G_Factor];
				y = getAnimCoord (Reflection_G_Anim, Reflection_G_Anim_Rate);
				float4 tabG0 = (Add_Light0)*GetTableMap(Reflection_Table_Sampler, float2(x0,y));
				float4 tabG1 = (Add_Light1)*GetTableMap(Reflection_Table_Sampler, float2(x1,y));
				float4 tabG2 = (Add_Light2)*GetTableMap(Reflection_Table_Sampler, float2(x2,y));
					
				x0 = table0[Reflection_B_Type][Reflection_B_Factor];
				x1 = table1[Reflection_B_Type][Reflection_B_Factor];
				x2 = table2[Reflection_B_Type][Reflection_B_Factor];
				y = getAnimCoord (Reflection_B_Anim, Reflection_B_Anim_Rate);
				float4 tabB0 = (Add_Light0)*GetTableMap(Reflection_Table_Sampler, float2(x0,y));
				float4 tabB1 = (Add_Light1)*GetTableMap(Reflection_Table_Sampler, float2(x1,y));
				float4 tabB2 = (Add_Light2)*GetTableMap(Reflection_Table_Sampler, float2(x2,y));
					
				specCol0 = float4(tabR0.r,tabG0.g,tabB0.b,1);
				specCol1 = float4(tabR1.r,tabG0.g,tabB1.b,1);
				specCol2 = float4(tabR2.r,tabG0.g,tabB2.b,1);
			}
			else 
			{
				specCol0 = float4(tabR0.r,tabR0.r,tabR0.r,1);
				specCol1 = float4(tabR1.r,tabR1.r,tabR1.r,1);
				specCol2 = float4(tabR2.r,tabR2.r,tabR2.r,1);
			}
		}
		secondary += texTab0.r*Light0_Specular_Color*specCol0;
		secondary += texTab1.r*Light1_Specular_Color*specCol1;
		secondary += texTab2.r*Light2_Specular_Color*specCol2;
	}
	Inputs[3] = float4(secondary.rgb, secondary_alphas[Secondary_Alpha_Type]);
		
	CombinerData COMBO [6];
	COMBO[0] = UnpackCombiner (Use_Combiner0,Combiner0_Input0,Combiner0_Input1,Combiner0_Input2,Combiner0_Color,Combiner0_Color_Output,Combiner0_Alpha_Output);
	COMBO[1] = UnpackCombiner (Use_Combiner1,Combiner1_Input0,Combiner1_Input1,Combiner1_Input2,Combiner1_Color,Combiner1_Color_Output,Combiner1_Alpha_Output);
	COMBO[2] = UnpackCombiner (Use_Combiner2,Combiner2_Input0,Combiner2_Input1,Combiner2_Input2,Combiner2_Color,Combiner2_Color_Output,Combiner2_Alpha_Output);
	COMBO[3] = UnpackCombiner (Use_Combiner3,Combiner3_Input0,Combiner3_Input1,Combiner3_Input2,Combiner3_Color,Combiner3_Color_Output,Combiner3_Alpha_Output);
	COMBO[4] = UnpackCombiner (Use_Combiner4,Combiner4_Input0,Combiner4_Input1,Combiner4_Input2,Combiner4_Color,Combiner4_Color_Output,Combiner4_Alpha_Output);
	COMBO[5] = UnpackCombiner (Use_Combiner5,Combiner5_Input0,Combiner5_Input1,Combiner5_Input2,Combiner5_Color,Combiner5_Color_Output,Combiner5_Alpha_Output);

	Inputs[8] = 0;
	int used_combiners = 6;
	for (int i=0; i < used_combiners; i++)
//	[fastopt] for (int i=0; i < used_combiners; i++)
	{
		CombinerOUT(COMBO[i], Inputs);
	}
	float4 color = saturate(Inputs[0]);
/*	
	if(Add_Fog) 
	{
		float cfog = clamp((eyeDist-Fog_Near)/(Fog_Far-Fog_Near),0,1);
		float dfog = cfog*Fog_Density;
		float4 factor = float4(GetTableMap(Fog_Table_Sampler, float2(cfog,0)).x, cfog, 1-exp(-dfog), 1-exp(-(dfog*dfog)));
	
		color.xyz = lerp(color.xyz,Fog_Color.xyz,factor[Fog_Type]);
	}
*/
//	if (Color_Conversion) color = ColorConversion(color);
/*
	if ((Enable_Adjustments) && (Adjustment_Type == 2))
	{
		color.rgb = ColorRGB(color.rgb);
		color.rgb = ColorHue(color.rgb);
		color.rgb = ColorContrastSaturationBrightness(color.rgb); 
		if (Clamp_Normalize) color.rgb = color.rgb*(ClampMax-ClampMin) + ClampMin;
		else color.rgb = clamp(color.rgb,ClampMin,ClampMax);
	}
*/			
	return color;
}

//-----------------------------------------------------------------------------
// Full pixel shader -- does all lighting
//-----------------------------------------------------------------------------
float4 PShader(PixelInput IN) : COLOR
{
	return PixelShaderCombine(IN, 2, 1);
}

//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------

// Opaque			0
// Knock Out		1
// Normal			2
// Subtractive		3
// Additive			4
// Blend Knock Out	5
// Multiply			6

static const bool ZWriteEnables[] = {
	true,
	true,
	true,
	false,
	false,
	false,
	false,
};

static const bool AlphaBlendEnables[] = {
	false,
	false,
	true,
	true,
	true,
	true,
	true,
};

static const int BlendOpAdd = 1;
static const int BlendOpRevSubtract = 3;

static const int BlendOps[] = {
	BlendOpAdd,
	BlendOpAdd,
	BlendOpAdd,
	BlendOpRevSubtract,
	BlendOpAdd,
	BlendOpAdd,
	BlendOpAdd
};

static const int BlendZero = 1;
static const int BlendOne = 2;
static const int BlendSrcAlpha = 5;
static const int BlendInvSrcAlpha = 6;
static const int BlendDestColor = 9;

static const int SrcBlends[] = {
	BlendOne,
	BlendOne,
	BlendSrcAlpha,
	BlendSrcAlpha,
	BlendSrcAlpha,
	BlendSrcAlpha,
	BlendDestColor
};

static const int DestBlends[] = {
	BlendZero,
	BlendZero,
	BlendInvSrcAlpha,
	BlendOne,
	BlendOne,
	BlendInvSrcAlpha,
	BlendZero
};

static const bool AlphaTestEnables[] = {
	false,
	true,
	true,
	true,
	true,
	true,
	true
};

technique combine
<
	string Script = "" 
	"Pass=p0;";
>
{
	pass p0
	<
		string Script = "Draw=Geometry;"; 
		bool FastPrecision  = true;
		bool TexFormatRGBA8	= true;
		bool NoBColor		= true;
	>
	{
//		CullFaceEnable = <Cull_Face>;
		CullMode = <Cull_Mode>;
		ShadeMode = Gouraud;
		ZWriteEnable = <ZWriteEnables[Blend_Mode]>;
		DepthBias = <Depth_Bias*0.00001>;

		AlphaBlendEnable = <AlphaBlendEnables[Blend_Mode]>;
		BlendOp = <BlendOps[Blend_Mode]>;
		SrcBlend = <SrcBlends[Blend_Mode]>;
		DestBlend = <DestBlends[Blend_Mode]>;
		
//		AlphaTestEnable = <AlphaTestEnables[Blend_Mode]>;
		AlphaTestEnable = <Alpha_Test>;
		AlphaRef = <Alpha_Ref>;
		AlphaFunc = GREATEREQUAL;

		VertexShader = compile vs_3_0 VShader();
		PixelShader = compile ps_3_0 PShader();
	}
}



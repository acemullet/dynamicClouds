//--------------------------------------------------------------------------------------
// File: lecture 8.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
Texture2D txDiffuse : register( t0 );
Texture2D txnormal : register(t1);
SamplerState samLinear : register( s0 );

cbuffer ConstantBuffer : register( b0 )
{
matrix World;
matrix View;
matrix Projection;
float4 info;
};



//--------------------------------------------------------------------------------------
struct VS_INPUT
{
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

struct PS_INPUT
{
    float4 Pos : SV_POSITION;
	
    float2 Tex : TEXCOORD0;
	float3 WorldPos : TEXCOORD1;
};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT input )
{
    PS_INPUT output = (PS_INPUT)0;
    output.Pos = mul( input.Pos, World );
	output.WorldPos = output.Pos;
    output.Pos = mul( output.Pos, View );
    output.Pos = mul( output.Pos, Projection );
    output.Tex = input.Tex;
    
    return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS( PS_INPUT input) : SV_Target
{
	float4 normaltex = txnormal.Sample(samLinear, input.Tex);
	normaltex -= float4(0.5, 0.5, 0.5,0);
	normaltex *= 2.;

    float4 color = txDiffuse.Sample( samLinear, input.Tex );
	float depth = saturate(input.Pos.z / input.Pos.w);

	float2 normal2 = (input.Tex - float2(0.5, 0.5))*2.;
	float3 normal3;
	normal3.xy = normal2.xy;
	normal3.z = sqrt(1 - (normal2.x*normal2.x + normal2.y*normal2.y));
	normal3 = mul(normal3, View);
	normaltex.rgb = mul(normaltex.rgb, View);
	float3 lightposition = float3(30, -200, 90);

		float3 lightdirection = normalize(lightposition - input.WorldPos);

		normal3 = normalize(normal3 + normaltex.rgb*0.3);

		float3 nn = saturate(dot(lightdirection, normal3));
		nn.r += 0.3;
	//return float4(nn.r,0,0, 1);
	color.rgb = float3(1, 1, 1);
	return float4(color.rgb*nn.r, color.a);
	return float4(normal3.xyz,1);
	//depth = pow(depth,0.97);
	//color = depth;// (depth*0.9 + 0.02);
	color.a *=info.x;
	return color;
}

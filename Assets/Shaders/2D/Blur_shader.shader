﻿Shader "LearnToShader/2D/Blur"
{
	Properties
	{
		[PerRendererData]_MainTex("Sprite Texture", 2D) = "white" {}
	
		// 模糊程度
		_Blur("Blur",Range(0,1)) = 0.01
	}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
			}

			Cull Off
			Lighting Off
			ZWrite Off
			Blend One OneMinusSrcAlpha

			Pass
			{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				#include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex   : POSITION;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex   : SV_POSITION;
					float2 texcoord  : TEXCOORD0;
				};

				v2f vert(appdata_t IN)
				{
					v2f OUT;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);
					OUT.texcoord = IN.texcoord;
					
					return OUT;
				}


				fixed4 calcBlur(sampler2D tex, float2 uv, float blur)
				{
					// 1 / 16
					float distance = blur * 0.0625f;

					fixed4 color = tex2D(tex, uv);
					fixed4 leftColor = tex2D(tex, float2(uv.x - distance, uv.y));
					fixed4 rightColor = tex2D(tex, float2(uv.x + distance, uv.y));
					fixed4 topColor = tex2D(tex, float2(uv.x, uv.y + distance));
					fixed4 bottomColor = tex2D(tex, float2(uv.x, uv.y - distance));

					color = color * 4 + leftColor + rightColor + topColor + bottomColor; // 8
					color = color * 0.125; // 1/8

					return color;
				}


				sampler2D _MainTex;
				float _Blur;
				
				fixed4 frag(v2f IN) : SV_Target
				{
					fixed4 c = calcBlur(_MainTex, IN.texcoord, _Blur);
					c.rgb *= c.a;
					return c;
				}
			ENDCG
			}
		}
}

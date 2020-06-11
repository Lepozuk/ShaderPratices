﻿Shader "LearnToShader/2D/EdgeDetectionColor"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
			// 边缘检测的精细度
			_EdgeFactor("EdgeFactor",Range(0,0.25)) = 0.01

			// 边缘颜色
			_EdgeColor("EdgeColor",Color) = (0,0,0,1)

			// 背景颜色
			_BgColor("BgColor",Color) = (1,1,1,1)

			// 显示背景还是贴图
			_BgFactor("BgFactor",Range(0,1)) = 1

			}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"
				"CanUseSpriteAtlas" = "True"
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
                #include "./Utils/ColorHelper.cginc"
                
				struct appdata_t
				{
					float4 vertex   : POSITION;
					float4 color    : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex   : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord  : TEXCOORD0;
				};

				fixed4 _Color;
				sampler2D _MainTex;

				v2f vert(appdata_t IN)
				{
					v2f OUT;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);
					OUT.texcoord = IN.texcoord;
					OUT.color = IN.color * _Color;
					

					return OUT;
				}

				

				float _EdgeFactor;

				float4 _BgColor;
				float4 _EdgeColor;
				float _BgFactor;

				fixed4 frag(v2f IN) : SV_Target
				{
					 half edge = calcEdgeByGrayscale(_MainTex, IN.texcoord, _EdgeFactor);
				    
					float4 texColor = tex2D(_MainTex, IN.texcoord);

					float4 bgColor = lerp(texColor,_BgColor,_BgFactor);

					fixed4 c =  lerp(bgColor,_EdgeColor,edge) * IN.color;
					
					c.rgb *= c.a;
					return c;
				}
			ENDCG
			}
		}
}

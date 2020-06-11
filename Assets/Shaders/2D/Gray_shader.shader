﻿Shader "LearnToShader/2D/Gray"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		// 声明属性，值的范围 0 到 1，默认值为 1
		_GrayFactor("GrayFactor",Range(0,1)) = 1
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
				float _GrayFactor;

				v2f vert(appdata_t IN)
				{
					v2f OUT;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);
					OUT.texcoord = IN.texcoord;
					OUT.color = IN.color * _Color;

					return OUT;
				}


				fixed4 frag(v2f IN) : SV_Target
				{
				
					fixed4 color = tex2D(_MainTex, IN.texcoord);

					float grayValue = grayscale(color);
					
					float4 grayColor = float4(grayValue, grayValue, grayValue, 1.0);
                    
					// 进行插值
					color = lerp(color, grayColor, _GrayFactor);
				
					color *= IN.color;
					color.rgb *= color.a;
					return color;
				}
			ENDCG
			}
		}
}

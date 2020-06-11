﻿Shader "LearnToShader/2D/Line"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

		_Width("Width",Range(0,1)) = 0

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

				v2f vert(appdata_t IN)
				{
					v2f OUT;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);
					OUT.texcoord = IN.texcoord;
					OUT.color = IN.color * _Color;

					return OUT;
				}

				sampler2D _MainTex;
				float _Width;

				float IsInLine(float x,float y)
				{
					return smoothstep(x - _Width, x, y) - smoothstep(x, x + _Width, y);
				}

				fixed4 frag(v2f IN) : SV_Target
				{
                    float2 uv = IN.texcoord;
				    fixed4 color = tex2D(_MainTex, uv);
					float fx = 1 - uv.x;
					color = lerp(color, float4(0.0, 0.0, 0.0, 1.0), IsInLine(uv.x, uv.y)) * lerp(color, float4(0.0, 0.0, 0.0, 1.0), IsInLine(fx, uv.y));
					
					color *= IN.color;
					color.rgb *= color.a;
					return color;
				}
			ENDCG
			}
		}
}

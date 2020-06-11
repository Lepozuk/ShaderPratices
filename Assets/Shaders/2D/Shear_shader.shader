﻿﻿Shader "LearnToShader/2D/Shear"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		_ShearX("ShaerX",Range(0,1)) = 0
		_ShearY("ShaerY", Range(0,1)) = 0
		_ShearTail("ShaerTail",Range(0,1)) = 0

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
				sampler2D _MainTex;
				float _ShearY;
				float _ShearX;
				float _ShearTail;

				v2f vert(appdata_t IN)
				{
					v2f OUT;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);
					OUT.texcoord = IN.texcoord;
					OUT.color = IN.color * _Color;

					return OUT;
				}


				fixed4 SampleSpriteTexture(float2 uv)
				{
					fixed4 color = tex2D(_MainTex, uv) * smoothstep(_ShearTail, _ShearX, uv.x) * smoothstep(_ShearTail, _ShearY, uv.y);
					return color;
				}


				fixed4 frag(v2f IN) : SV_Target
				{
				    float2 uv = IN.texcoord;
				    
				    fixed4 color = tex2D(_MainTex, uv) * smoothstep(_ShearTail, _ShearX, uv.x) * smoothstep(_ShearTail, _ShearY, uv.y);
				    
                    color *= IN.color;
                    color.rgb *= color.a;
                    return color;
				}
			ENDCG
			}
		}
}

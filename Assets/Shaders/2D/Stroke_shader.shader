﻿Shader "LearnToShader/2D/Stroke"
{
	Properties
	{
		[PerRendererData]_MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

        // 描边的颜色
        _OutlineColor("OutlineColor",Color) = (0,0,0,1)

        // 描边的宽度
        _OutlineWidth("OutlineWidth",Range(0,0.25)) = 0.01

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
				
				v2f vert(appdata_t IN)
				{
					v2f OUT;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);
					OUT.texcoord = IN.texcoord;
					OUT.color = IN.color * _Color;

					return OUT;
				}
				
				sampler2D _MainTex;
				float _OutlineWidth;
				float4 _OutlineColor;

				fixed4 frag(v2f IN) : SV_Target
				{
				    fixed edge = calcEdgeByAlpha(_MainTex, IN.texcoord, _OutlineWidth);
				
				    float4 texColor = tex2D(_MainTex, IN.texcoord);

					fixed4 color = lerp(texColor, _OutlineColor, edge) * IN.color;
					
					color.rgb *= color.a;
					
					return color;
				}
			ENDCG
			}
		}
}

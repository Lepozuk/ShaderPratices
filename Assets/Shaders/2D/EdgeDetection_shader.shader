﻿Shader "LearnToShader/2D/EdgeDetection"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		
		// 边缘检测的精细度
		_EdgeFactor("EdgeFactor",Range(0,0.25)) = 0.01
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
            float _EdgeFactor;

            fixed4 frag(v2f IN) : SV_Target
            {
                half edge = calcEdgeByGrayscale(_MainTex, IN.texcoord, _EdgeFactor);
                
                fixed4 color = lerp(float4(1,1,1,1), float4(0,0,0,1), edge);
                
                color *= IN.color;
                
                color.rgb *= color.a;
                
                return color;
            }
        ENDCG
        }
    }
}

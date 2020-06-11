﻿Shader "LearnToShader/2D/Pencil"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

        // 铅笔效果
        _PencilFactor("PencilFactor",Range(0,0.01)) = 0.002

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
            float _PencilFactor;

            fixed4 frag(v2f IN) : SV_Target
            {
                float2 uv = IN.texcoord;
                half edge = 1 - calcEdgeByGrayscale(_MainTex, uv, _PencilFactor);
                fixed4 edgeCol = fixed4(edge,edge,edge,1);
                fixed4 texCol =  tex2D(_MainTex,uv);
                fixed4 color = edgeCol * texCol.a;
                color *= IN.color;
                color.rgb*=color.a;
                return color;
            }
        ENDCG
        }
    }
}

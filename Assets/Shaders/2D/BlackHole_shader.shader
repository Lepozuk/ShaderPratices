﻿Shader "LearnToShader/2D/BlackHole"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

		_Speed("Speed",float) = 1
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
            float _Speed;
            
            fixed4 frag(v2f IN) : SV_Target
            {
                // 定义旋涡半径
                float radius = 0.7;
                
                // 中心点
                float2 center = float2(0.5, 0.5);
                
                fixed4 color = tex2D(_MainTex, calcVortex(IN.texcoord, radius, center, _Speed));
                
                color *= IN.color;
                
                color.rgb *= color.a;
                
                return color;
            }
        ENDCG
        }
    }
}

﻿Shader "LearnToShader/2D/NoiseRising"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
        _Power("Power", Range(0,10)) = 0.25
		_Speed("Speed",float) = 100
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
            float _Power;
            
            fixed4 frag(v2f IN) : SV_Target
            {
                float2 uv = IN.texcoord;
                
                // 基础速度（注意是负的）
                float baseSpeed = -_Time.y * 0.1;

                // 速度较慢的噪声 uv
                float2 noiseUV1 = (0.2 * uv + baseSpeed * float2(0.0, 0.5)) * _Speed;

                // 速度较快的噪声 uv
                float2 noiseUV2 = (0.2 * uv + baseSpeed * float2(0.0, 1.0)) * _Speed;

                // 噪声颜色
                float noiseColor1 = perlin(noiseUV1);
                float noiseColor2 = perlin(noiseUV2);

                float randomValue = pow(noiseColor1 + noiseColor2, _Power);
                
                fixed4 color = float4(randomValue,randomValue,randomValue,1);
                
                color *= IN.color;
                color.rgb *= color.a;
                return color;
            }
        ENDCG
        }
    }
}

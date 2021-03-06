﻿﻿Shader "LearnToShader/2D/Flame"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

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

            fixed4 calcFire(float2 uv)
            {
                // 基础速度（注意是负的）
                float baseSpeed = -_Time.y * 0.1;

                // 速度较慢的噪声 uv
                float2 noiseUV1 = (0.2 * uv + baseSpeed * float2(0.0, 0.5)) * _Speed;

                // 速度较快的噪声 uv
                float2 noiseUV2 = (0.2 * uv + baseSpeed * float2(0.0, 1.0)) * _Speed;

                // 噪声颜色
                float noiseColor1 = perlin(noiseUV1);
                float noiseColor2 = perlin(noiseUV2);

                float noiseColor = noiseColor1 + noiseColor2;

                // 使深色更深
                float fireNoise = pow(noiseColor, 5);

                // 拿到 uv 的 y 值
                float y = uv.y;

                // 将 y 的范围控制在 整体图像的下半部分
                // 写成下边这样的控制的算法，是自己一点点调的
                fireNoise = (2 + fireNoise * 80 * y) * y;

                // 调换火和背景的颜色
                fireNoise = 1 - fireNoise;


                // 让深色部分多一点
                fireNoise = pow(fireNoise, 3);

                // 贴图颜色
                float4 texColor = tex2D(_MainTex, uv);

                // 火的颜色
                // 用差值做渐变
                float4 fireColor = lerp(float4(1, 0, 0, 1), float4(1, 1, 0, 1), fireNoise);

                // 判断是否是火的范围
                float isFireColor = step(0.001, fireNoise);


                // 最终颜色
                float4 resultColor = lerp(texColor, fireColor, isFireColor);

                return resultColor;
            }


            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 c = calcFire(IN.texcoord) * IN.color;
                c.rgb *= c.a;
                return c;
            }
        ENDCG
        }
    }
}

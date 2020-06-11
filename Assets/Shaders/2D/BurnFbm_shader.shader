﻿Shader "LearnToShader/2D/BurnFbm"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		
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

            fixed4 frag(v2f IN) : SV_Target
            {
                float2 uv = IN.texcoord;
            
                float4 fbmNoise = fbm(3.5 * uv);

                // 使用时间的小数部分控制 消融的动画
                float burnFactor = frac(_Time * 10);

                // 只取小数部分
                float fadeoutFactor = frac(burnFactor * 0.9999);

                // 焚烧额时候会有一段焚烧的距离
                float4 color = smoothstep(fadeoutFactor, fadeoutFactor + 0.1, fbmNoise);

                // 通过 burnFactor 控制焚烧的进度
                color = lerp(color, fbmNoise, burnFactor);
                
                color *= IN.color;
                
                color.rgb *= color.a;
                
                return color;
            }
        ENDCG
        }
    }
}

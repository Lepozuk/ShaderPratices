﻿Shader "LearnToShader/2D/Water"
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
            float _Speed;

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
                // 速度
                float speed = _Time * _Speed;
                float2 uv = IN.texcoord;
                uv.x = uv.x + sin(uv.y * 10 + speed) * 0.3 * 0.05;
                uv.y = uv.y + cos(uv.x * 10 + speed) * 0.3 * 0.05;
                
                fixed4 color = tex2D(_MainTex,uv);
                
                color *= IN.color;
                color.rgb *= color.a;
                return color;
            }
        ENDCG
        }
    }
}

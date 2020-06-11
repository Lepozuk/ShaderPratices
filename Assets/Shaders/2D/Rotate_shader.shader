﻿Shader "LearnToShader/2D/Rotate"
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
            // 旋转速度
                float speed = _Speed;
            
                float sinX = sin(speed * _Time);
                float cosX = cos(speed * _Time);

                float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
                
                float2 center = float2(0.5, 0.5);
                
                float2 uv = IN.texcoord;
                uv -= center;//偏移到中心点
                uv.xy = mul(uv, rotationMatrix);//应用旋转
                uv += center;

                fixed4 color = tex2D(_MainTex, uv);
                
                color *= IN.color;
                color.rgb *= color.a;
                return color;
            }
        ENDCG
        }
    }
}

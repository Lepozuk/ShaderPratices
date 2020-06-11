﻿Shader "LearnToShader/2D/NightVision"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_RowCount("RowCount", Int) = 100
		_DeepColor("DeepColor", Color) = (0.9, 1.0, 0.6, 1.0) 
		_NormalColor("NormalColor", Color) = (0.2, 0.5, 0.1, 1.0) 
		_DeepColor("DeepColor", Color) = (0.0, 0.1, 0.0, 1.0) 
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
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 texcoord  : TEXCOORD0;
            };

            sampler2D _MainTex;
            float _RowCount;
            float4 _DeepColor;
            float4 _NormalColor;
            float4 _LightColor;
            
            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                return OUT;
            }
            
             // 减少颜色之间的梯度
            float4 gradient(float i)
            {
                // clamp(value,min,max): 获取三个值中，中间大小的值
                // 比如 clamp(2,1,3) 得到 2
                // 比如 clamp(5,1,2) 得到 2
                // 比如 clamp(1,2,3) 得到 2
                // 此时的 i 是 2倍的颜色
                i = clamp(i, 0.0, 1.0) * 2.0;
            
                if (i < 1.0) 
                {
                    // 深绿 和 亮绿 之间插值
                    return lerp(_DeepColor,_NormalColor,i);
                } 
                else {
                    i -= 1.0;
                    // 亮绿 和 淡绿 之间插值
                    return lerp(_NormalColor,_LightColor,i);
                }
            }
            
            // 是否是栅栏效果
            float IsbarLine(float phase)
            {
                // 扩大范围
                phase *= 2.0;

                // fmod 取余数，返回值的符号同第二个参数
                // fmod（phase,2.0),返回值范围 [0.0f ~ 1.0f] 
                return 1.0 - abs(fmod(phase, 2.0) - 1.0);
            }

            float barLines(float color,float2 uv)
            {   
                // barLineOrNot 的范围为 [0.0f ~ 1.0f] 
                // 100 是指有 100 个 line
                float barLineOrNot = IsbarLine(uv.y * _RowCount);

                // 让越黑的越黑（越接近与 0 的值越接接近于 0)
                barLineOrNot = pow(barLineOrNot, 2 * (1.0 - color) + 0.5f);

                return barLineOrNot * color;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.texcoord;

                float4 color = tex2D(_MainTex,uv);
            
                // 灰度值
                float grayValue = grayscale(color);
                
                // 增加栅栏效果
                grayValue = barLines(grayValue, uv);
            
                // 增加
                float4 greenColor = gradient(grayValue);
                
                //// 简单的噪声
                return gradient(grayValue) * lerp(1, random(saturate(uv+_Time.ww)), 0.3f);;
            }
            ENDCG
        }
    }
}

#ifndef Unity_Shader_Extend_ColorHelper

#define Unity_Shader_Extend_ColorHelper

fixed4 calcSharpColor(sampler2D tex, float2 uv, float offset)
{
    // 左上
    fixed4 color = tex2D(tex, float2(uv.x - offset,uv.y - offset)) * -1;
    // 上
    color += tex2D(tex,float2(uv.x,uv.y - offset)) * -1;
    // 右上
    color += tex2D(tex,float2(uv.x + offset,uv.y + offset)) * -1;
    // 左
    color += tex2D(tex,float2(uv.x - offset,uv.y)) * -1;
    // 中
    color += tex2D(tex,float2(uv.x,uv.y)) * 9;
    // 右
    color += tex2D(tex,float2(uv.x + offset,uv.y)) * -1;
    // 左下
    color += tex2D(tex, float2(uv.x - offset,uv.y + offset)) * -1;
    // 下
    color += tex2D(tex,float2(uv.x,uv.y + offset)) * -1;
    // 右下
    color += tex2D(tex,float2(uv.x + offset,uv.y - offset)) * -1;

    return color;
}

// 求水平、竖直卷积的均值合，透明度边界
float calcEdgeByAlpha(sampler2D tex, float2 uv, float offset)
{
    // sobel 卷积核
    // gx
    // -1 |  0  | 1
    //----|-----|-----
    // -2 |  0  | 2
    //----|-----|-----
    // -1 |  0  |  1
    //gy
    // -1 | -2 | -1
    //----|----|-----
    //  0 |  0 |  0 
    //----|----|-----
    //  1 |  2 |  2
    
    float3x3 gxKernal = float3x3(-1,  0,  1, -2, 0, 2, -1, 0, 1);
    float3x3 gyKernal = float3x3(-1, -2, -1,  0, 0, 0,  1, 2, 1);
    float gx = 0;
    float gy = 0;
    for(int u = 0; u <3; u++) 
    {
        for(int v = 0; v<3; v++) 
        {
            gx += gxKernal[u][v] * tex2D(tex, uv.xy + float2( ( u - 1 ) * offset, ( v - 1 ) * offset)).a;
            gy += gyKernal[u][v] * tex2D(tex, uv.xy + float2( ( u - 1 ) * offset, ( v - 1 ) * offset)).a;
        }
    }
    
    return abs(gx) + abs(gy);
}

// 获取灰度
inline float grayscale(float3 color) {
    return color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
}

// 求水平、竖直对灰度卷积的均值合，灰度边界
float calcEdgeByGrayscale(sampler2D tex, float2 uv, float offset) {
    // sobel 卷积核
    // gx
    // -1 |  0  | 1
    //----|-----|-----
    // -2 |  0  | 2
    //----|-----|-----
    // -1 |  0  |  1
    //gy
    // -1 | -2 | -1
    //----|----|-----
    //  0 |  0 |  0 
    //----|----|-----
    //  1 |  2 |  2
    
    float3x3 gxKernal = float3x3(-1,  0,  1, -2, 0, 2, -1, 0, 1);
    float3x3 gyKernal = float3x3(-1, -2, -1,  0, 0, 0,  1, 2, 1);
    float gx = 0;
    float gy = 0;
    for(int u = 0; u <3; u++) 
    {
        for(int v = 0; v<3; v++) 
        {
            gx += gxKernal[u][v] * grayscale(tex2D(tex, uv.xy + float2( ( u - 1 ) * offset, ( v - 1 ) * offset)));
            gy += gyKernal[u][v] * grayscale(tex2D(tex, uv.xy + float2( ( u - 1 ) * offset, ( v - 1 ) * offset)));
        }
    }
    return abs(gx) + abs(gy);
}

// 随机
inline float random(float2 uv) {
    return frac(sin(dot(uv, float2(12.9898,78.233) * _Time.x)) * 43758.5453123);
}

// 柏林
float perlin(float2 uv) {
    // 获取 uv 的整数部分       
    float2 i = floor(uv);

    // 获取 uv 的小数部分 
    float2 f = frac(uv);

    // 获取 uv 的相邻坐标组成的区块 
    float a = random(i);
    float b = random(i + float2(1.0, 0.0));
    float c = random(i + float2(0.0, 1.0));
    float d = random(i + float2(1.0, 1.0));

    // 对 uv 的小数部分进行 smoothstep
    // 因为是小数部分，所以肯定是小于 1 
    // 所以去掉了对 smoothstep 的 step 操作
    // 只保留了 smooth 的过程 
    float2 u = f * f * (3 - 2 * f);

    // 差值过渡填充区块
    return lerp(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// 分型
float fbm(float2 uv)
{
    float retNoise = 0.0;
    float uvOffset = 2.0;

    for (int i = 0; i < 9; i++)
    {
        retNoise += perlin(uvOffset * uv) / uvOffset;
        uvOffset += uvOffset;
    }

    return retNoise;
}

// 求旋涡UV
float2 calcVortex(float2 uv, float radius, float center, float speed)
{
    
    float sinX = sin(speed * _Time);
    float cosX = cos(speed * _Time);
    
    uv -= center;
    
    //预先做一个旋转
    uv = mul(uv, float2x2(cosX, -sinX, sinX, cosX));
    
    // 取半径
    float curRadius = length(uv);
    
    //小于半径的加速旋转
    if (curRadius < radius)
    {
        // 获取到当前半径在旋涡半径内的占比
        float percent = (radius - curRadius) / radius;

        // 计算出来一个弧度（大概值，半径越小值越大）
        float theta = percent * percent * 16;

        float sinX = sin(theta);
        float cosX = cos(theta);

        // 进行旋转
        uv = mul(uv, float2x2(cosX, -sinX, sinX, cosX));
    }
    
    uv += center;

    return uv;
}

//高斯模糊
fixed4 gauss(sampler2D tex, float2 uv, float offset)
{
    // 1 / 16
    offset *= 0.0625f;
    
    // 左上
    fixed4 color = tex2D(tex, float2(uv.x - offset,uv.y - offset)) * 0.0947416f;
    // 上
    color += tex2D(tex,float2(uv.x,uv.y - offset)) * 0.118318f;
    // 右上
    color += tex2D(tex,float2(uv.x + offset,uv.y + offset)) * 0.0947416f;
    // 左
    color += tex2D(tex,float2(uv.x - offset,uv.y)) * 0.118318f;
    // 中
    color += tex2D(tex,float2(uv.x,uv.y)) * 0.147761f;
    // 右
    color += tex2D(tex,float2(uv.x + offset,uv.y)) * 0.118318f;
    // 左下
    color += tex2D(tex, float2(uv.x - offset,uv.y + offset)) * 0.0947416f;
    // 下
    color += tex2D(tex,float2(uv.x,uv.y + offset)) * 0.118318f;
    // 右下
    color += tex2D(tex,float2(uv.x + offset,uv.y - offset)) * 0.0947416f;
    
    return color;
}

#endif
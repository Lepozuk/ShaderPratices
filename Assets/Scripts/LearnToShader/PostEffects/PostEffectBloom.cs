using System.Collections;
using System.Collections.Generic;
using LearnToShader.FX;
using UnityEngine;

[ExecuteInEditMode]
public class PostEffectBloom : PostEffectBase
{
    
    public Vector2 ScreenSize = new Vector2(512,512);
    [Range(0,1)]
    public float GlowSize = 0.25f;

    [Range(1, 10)] 
    public float Amount = 1f;
    // Start is called before the first frame update
    void Start()
    {
        mMat = new Material(Shader.Find("LearnToShader/2D/Bloom"));
    }
    
    private void OnValidate()
    {
        UpdateMat();
    }

    private void UpdateMat()
    {
        if (mMat)
        {
            mMat.SetFloat("_Glow", GlowSize);
            mMat.SetFloat("_Amount", Amount);
            mMat.SetVector("_ScreenResolution", ScreenSize);
        }
    }
}

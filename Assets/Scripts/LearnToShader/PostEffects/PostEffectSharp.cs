using System.Collections;
using System.Collections.Generic;
using LearnToShader.FX;
using UnityEngine;

[ExecuteInEditMode]
public class PostEffectSharp : PostEffectBase
{
    [Range(0,1)]
    public float SharpFactor = 0.1f;
    
    private void Start()
    {
        mMat = new Material(Shader.Find("LearnToShader/2D/Sharpen"));
        UpdateMat();
    }

    private void OnValidate()
    {
        UpdateMat();
    }

    private void UpdateMat()
    {
        if (mMat)
        {
            mMat.SetFloat("_SharpFactor", SharpFactor*0.25f);
        }
    }
}

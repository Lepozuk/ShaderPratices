using System.Collections;
using System.Collections.Generic;
using LearnToShader.FX;
using UnityEngine;

[ExecuteInEditMode]
public class PostEffectPencil : PostEffectBase
{
    [Range(0,1)]
    public float PencilFactor = 0.1f;
    
    private void Start()
    {
        mMat = new Material(Shader.Find("LearnToShader/2D/Pencil"));
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
            mMat.SetFloat("_PencilFactor", PencilFactor*0.025f);
        }
    }
}

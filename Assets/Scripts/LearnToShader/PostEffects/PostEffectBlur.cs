using System;
using LearnToShader.FX;
using UnityEngine;

namespace LearnToShader.PostEffects
{
    [ExecuteInEditMode]
    public class PostEffectBlur : PostEffectBase
    {
        [SerializeField] private float blurSize = 0.5f;

        private void Start()
        {
            mMat = new Material(Shader.Find("LearnToShader/2D/GaussBlur"));
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
                mMat.SetFloat("_Blur", blurSize);
            }
        }
    }
}
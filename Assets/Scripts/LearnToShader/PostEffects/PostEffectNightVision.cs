using System;
using LearnToShader.FX;
using UnityEngine;

namespace LearnToShader.PostEffects
{
    [ExecuteInEditMode]
    public class PostEffectNightVision : PostEffectBase
    {
        public int Row = 100;
        public Color Light = new Color(0.9f, 1.0f, 0.6f, 1.0f);
        public Color Normal = new Color(0.2f, 0.5f, 0.1f, 1.0f);
        public Color Deep = new Color(0.0f, 0.1f, 0.0f, 1.0f);
        private void Start()
        {
            mMat = new Material(Shader.Find("LearnToShader/2D/NightVision"));
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
                mMat.SetInt("_RowCount", Row);
                mMat.SetColor("_DeepColor", Deep);
                mMat.SetColor("_NormalColor", Normal);
                mMat.SetColor( "_LightColor", Light);
            }
        }
    }
}
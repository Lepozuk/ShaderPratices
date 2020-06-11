
using LearnToShader.FX;
using UnityEngine;

[ExecuteInEditMode]
public class PostEffect4Gradient : PostEffectBase
{
    [SerializeField] [ColorUsage(true)] private Color LeftTopColor = Color.white;
    [SerializeField] [ColorUsage(true)] private Color LeftBottomColor = Color.white;
    [SerializeField] [ColorUsage(true)] private Color RightTopColor = Color.white;
    [SerializeField] [ColorUsage(true)] private Color RightBottomColor = Color.white;

    private void Start()
    {
        mMat = new Material(Shader.Find("LearnToShader/2D/4Gradient"));
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
            mMat.SetVector("_LeftTopColor", LeftTopColor);
            mMat.SetVector("_LeftBottomColor", LeftBottomColor);
            mMat.SetVector("_RightTopColor", RightTopColor);
            mMat.SetVector("_RightBottomColor", RightBottomColor);
        }
    }
}

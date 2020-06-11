using UnityEngine;

namespace LearnToShader.FX
{
    [RequireComponent(typeof(Camera))]
    public class PostEffectBase : MonoBehaviour
    {
        [SerializeField] protected Material mMat;

        void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (mMat == null)
                return;

            Graphics.Blit(src, dest, mMat);
        }
    
    }
}
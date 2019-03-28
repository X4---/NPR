using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffect : MonoBehaviour {

    public Material kPostMat;

    public void OnPostRender()
    {
        
    }

    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(kPostMat != null)
        {
            Graphics.Blit(source, destination, kPostMat);
        }
    }

}


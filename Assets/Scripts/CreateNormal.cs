using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreateNormal : MonoBehaviour {

    public float delta = 1.0f;
    // Use this for initialization
    private void Awake()
    {
        MeshFilter filter = GetComponent<MeshFilter>();

        if(filter != null && filter.mesh != null)
        {
            filter.mesh.RecalculateNormals();
        }

    }



}

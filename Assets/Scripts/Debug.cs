using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Debug : MonoBehaviour {

    private SkinnedMeshRenderer krender;

    private MeshRenderer kmeshrenders;

    private MeshFilter kfilter;
    void Awake()
    {
        krender = GetComponent<SkinnedMeshRenderer>();

        kmeshrenders = GetComponent<MeshRenderer>();

        kfilter = GetComponent<MeshFilter>();
    }

    // Update is called once per frame
    void Update () {
		
        if(krender != null)
        {

            var mesh = krender.sharedMesh;


            for(int i =0,iMax = mesh.uv.Length; i< iMax; ++i)
            {

                var item = mesh.uv[i];

            }


        }

        if(kfilter != null)
        {
            var mesh = kfilter.sharedMesh;

            for (int i = 0, iMax = mesh.uv.Length; i < iMax; ++i)
            {
                var item = mesh.uv[i];


            }

        }

	}
}

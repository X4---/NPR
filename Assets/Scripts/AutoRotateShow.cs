using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


[CustomEditor(typeof(CreateNormal))]
public class AutoRotateShow : Editor
{
    private Transform kCached;
    private CreateNormal kCachedTraget;
    void OnEnable()
    {
        kCachedTraget = (CreateNormal)target;
        kCached = (kCachedTraget).transform;
        EditorApplication.update += Sample;
    }

    void OnDisable()
    {
        EditorApplication.update -= Sample;
    }

    public override void OnInspectorGUI()
    {
        if(kCached != null)
        {
            kCachedTraget.delta = EditorGUILayout.FloatField("Speed",
                kCachedTraget.delta);
        }
    }

    private void Sample()
    {
        kCached.transform.Rotate(0, Time.deltaTime * kCachedTraget.delta, 0);
    }
}
  

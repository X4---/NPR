using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

[ExecuteInEditMode]
public class TextureGen : MonoBehaviour {

    public string TargetDir;
    public string TargetName;
	// Use this for initialization
	
    private void OnEnable()
    {
        CreateAsset();
    }

    //Data From WIKI
    //https://en.wikipedia.org/wiki/Ordered_dithering

    public Texture2D GenDither4()
    {
        Texture2D temp = new Texture2D(2, 2);
        float[] data = new float[]{ 0, 2,
                                    3, 1 };

        for(int i=0,iMax = data.Length; i < iMax; ++i)
        {
            data[i] /= 4f;
        }

        for(int i=0; i < temp.width; ++i)
        {
            for(int j=0; j < temp.height; ++j)
            {
                var f = data[i * 2 + j];
                temp.SetPixel(i, j, new Color(f, f, f));
            }
        }

        temp.Apply();
        return temp;
    }

    public Texture2D GenDither9()
    {
        Texture2D temp = new Texture2D(3, 3);
        float[] data = new float[] { 0, 7, 3,
                                     6, 5, 2,
                                     4, 1, 8};

        for (int i = 0, iMax = data.Length; i < iMax; ++i)
        {
            data[i] /= 9f;
        }

        for (int i = 0; i < temp.width; ++i)
        {
            for (int j = 0; j < temp.height; ++j)
            {
                var f = data[i * 3 + j];
                temp.SetPixel(i, j, new Color(f, f, f));
            }
        }

        temp.Apply();
        return temp;
    }

    public Texture2D GenDither16()
    {
        Texture2D temp = new Texture2D(4, 4);
        float[] data = new float[] { 0, 8, 2, 10,
                                    12, 4,14,  6,
                                     3,11, 1,  9,
                                    15, 7,13,  5 };

        for (int i = 0, iMax = data.Length; i < iMax; ++i)
        {
            data[i] /= 16f;
        }

        for (int i = 0; i < temp.width; ++i)
        {
            for (int j = 0; j < temp.height; ++j)
            {
                var f = data[i * 4 + j];
                temp.SetPixel(i, j, new Color(f, f, f));
            }
        }

        temp.Apply();
        return temp;
    }

    public Texture2D GenDither64()
    {
        Texture2D temp = new Texture2D(8, 8);
        float[] data = new float[] { 0, 48, 12, 60,  3, 51, 15, 63,
                                    32, 16, 44, 28, 35, 19, 47, 31,
                                     8, 56,  4, 52, 11, 59,  7, 55,
                                    40, 24, 36, 20, 43, 27, 39, 23,
                                     2, 50, 14, 62,  1, 49, 13, 61,
                                    34, 18, 46, 30, 33, 17, 45, 29,
                                    10, 58,  6, 54,  9, 57,  5, 53,
                                    42, 26, 38, 22, 41, 25, 37, 21};

        for (int i = 0, iMax = data.Length; i < iMax; ++i)
        {
            data[i] /= 64f;
        }

        for (int i = 0; i < temp.width; ++i)
        {
            for (int j = 0; j < temp.height; ++j)
            {
                var f = data[i * 8 + j];
                temp.SetPixel(i, j, new Color(f, f, f));
            }
        }

        temp.Apply();
        return temp;
    }

    public void CreateAsset()
    {
        var path = AssetDatabase.GetAllAssetPaths();
        for (int i = 0, iMax = path.Length; i < iMax; ++i)
        {
            var p = path[i];
            UnityEngine.Debug.Log(p);
        }


        Texture2D temp = new Texture2D(10, 10);
        string pp = TargetDir;

        if(!Directory.Exists(pp))
        {
            Directory.CreateDirectory(pp);
        }

        if(TargetName.EndsWith(".png"))
        {
            TargetName = TargetName.Replace(".png", "");
        }

        var type4 = TargetName + "4.png";
        var type9 = TargetName + "9.png";
        var type16 = TargetName + "16.png";
        var type64 = TargetName + "64.png";

        var name4 = Path.Combine(TargetDir, type4);
        var name9 = Path.Combine(TargetDir, type9);
        var name16 = Path.Combine(TargetDir, type16);
        var name64 = Path.Combine(TargetDir, type64);

        File.WriteAllBytes(name4, GenDither4().EncodeToPNG());
        File.WriteAllBytes(name9, GenDither9().EncodeToPNG());
        File.WriteAllBytes(name16, GenDither16().EncodeToPNG());
        File.WriteAllBytes(name64, GenDither64().EncodeToPNG());


        //AssetDatabase.CreateAsset(temp, TargetPath);
    }
}

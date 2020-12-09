using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureModifier : MonoBehaviour
{

    [SerializeField] Texture2D texture;
    [SerializeField] Texture2D baseTexture;

    int drawRadius = 8;
    int grassLength = 7;

    public bool clickAllowed = true;

    private void Start()
    {
        Graphics.CopyTexture(baseTexture, texture);
    }

    void DrawCircle(float cutLength)
    {

        RaycastHit2D hit = Physics2D.GetRayIntersection(Camera.main.ScreenPointToRay(Input.mousePosition));
        if (!hit)
        {
            return;
        }

        Vector2 centre;
        centre.x = ((hit.point.x - hit.collider.bounds.min.x) / hit.collider.bounds.size.x) * texture.width;
        centre.y = ((hit.point.y - hit.collider.bounds.min.y) / hit.collider.bounds.size.y) * texture.height;

        for (int i = -drawRadius; i < drawRadius; i++)
        {
            for (int j = -drawRadius; j < drawRadius; j++)
            {
                if (i*i + j*j <= drawRadius * drawRadius)
                {
                    Vector2 pixelPosition = centre + new Vector2(i, j);
                    texture.SetPixel((int) pixelPosition.x, (int) pixelPosition.y, new Color(cutLength/255, 0, 0, 1));
                }
            }
        }

        texture.Apply();
    }

    // Update is called once per frame
    void OnMouseOver()
    {
        if (!clickAllowed) return;

        if (Input.GetMouseButton(0))
        {
            DrawCircle(grassLength);
        }
        else if (Input.GetMouseButton(1))
        {
            DrawCircle(0);
        }
    }

    public void SetGrassLength(int val)
    {
        grassLength = val;
    }

    public int GetGrassLength()
    {
        return grassLength;
    }
}

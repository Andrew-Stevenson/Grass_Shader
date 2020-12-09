using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class SliderManager : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{

    public TextureModifier grass;
    Slider slider;

    private void Start()
    {
        slider = GetComponent<Slider>();
        slider.value = grass.GetGrassLength();
    }

    public void UpdateGrassLength()
    {
        grass.SetGrassLength((int) slider.value);
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        grass.clickAllowed = false;
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        grass.clickAllowed = true;
    }
}

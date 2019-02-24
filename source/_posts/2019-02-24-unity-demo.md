---
title: Unity2D示例
categories:
  - Programming
  - Unity
tags:
  - Programming
  - Unity
  - dotNet
date: 2019-02-24 21:41:53
---

官方Unity2D的UFO示例

<!--more-->

## PlayerController.cs

```cs
using UnityEngine;
using UnityEngine.UI;

public class PlayerController : MonoBehaviour
{
    private Rigidbody2D rbd;
    public int speed;
    public Text countText;
    public Text winText;
    private int count;

    private void Start()
    {
        rbd = GetComponent<Rigidbody2D>();
        count = 0;
        countText.text = "Count: " + count;
        winText.text = "";
    }

    private void FixedUpdate()
    {
        float moveHorizontal = Input.GetAxis("Horizontal");
        float moveVertical = Input.GetAxis("Vertical");
        Vector2 movement = new Vector2(moveHorizontal, moveVertical);
        rbd.AddForce(movement * speed);
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        other.gameObject.SetActive(false);
        count += 1;
        countText.text = "Count: " + count;
        if (count == 8)
        {
            winText.text = "You Win";
        }
    }
}
```

## CameraController.cs

```cs
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public GameObject player;

    private Vector3 offset;

    private void Start()
    {
        offset = transform.position - player.transform.position;
    }

    private void LateUpdate()
    {
        transform.position = player.transform.position + offset;
    }
}
```

## Rotator.cs

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotator : MonoBehaviour
{
    private void Update()
    {
        transform.Rotate(new Vector3(0, 0, 45) * Time.deltaTime);
    }
}
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)

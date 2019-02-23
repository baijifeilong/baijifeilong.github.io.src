---
title: 使用Phaser制作一个简单游戏
categories:
  - Programming
tags:
  - Programming
date: 2019-02-23 23:44:44
---

使用Phaser制作一个简单游戏，主要实现以下功能与规则:

- 有地图，有背景，有平台供玩家跳跃
- 有分数栏用于显示当前玩家的总得分
- 玩家可以行走、跳跃，行走时有动画效果
- 玩家可以通过吃星星获取分数
- 玩家吃完所有星星后，更新新一波星星，并更新出一个敌人
- 玩家碰到敌人后，游戏结束

<!--more-->

## 演示地址

[演示](/raw/phaser/eatstar/app.html)

## 源代码

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>App</title>
    <script src="//cdn.jsdelivr.net/npm/phaser@3.16.2/dist/phaser.js"></script>
</head>
<body>
<script>
    new Phaser.Game({
        type: Phaser.AUTO,
        width: 800,
        height: 600,
        physics: {
            default: 'arcade',
            arcade: {
                gravity: {
                    y: 300
                },
                debug: false
            }
        },
        scene: {
            preload: function () {
                this.load.image('sky', 'assets/sky.png');
                this.load.image('ground', 'assets/platform.png');
                this.load.image('star', 'assets/star.png');
                this.load.image('bomb', 'assets/bomb.png');
                this.load.spritesheet('dude', 'assets/dude.png', {
                    frameWidth: 32,
                    frameHeight: 48
                })
            },
            create: function () {
                this.gameOver = false;
                this.add.image(400, 300, 'sky');
                const platforms = this.physics.add.staticGroup();
                platforms.create(400, 568, 'ground').setScale(2).refreshBody();
                platforms.create(600, 400, 'ground');
                platforms.create(50, 250, 'ground');
                platforms.create(750, 220, 'ground');
                const player = this.physics.add.sprite(100, 450, 'dude');
                this.player = player;
                player.setBounce(0.2);
                player.setCollideWorldBounds(true);
                this.anims.create({
                    key: 'left',
                    frames: this.anims.generateFrameNumbers('dude', {
                        start: 0,
                        end: 3
                    }),
                    frameRate: 10,
                    repeat: -1
                });
                this.anims.create({
                    key: 'right',
                    frames: this.anims.generateFrameNumbers('dude', {
                        start: 5,
                        end: 8
                    }),
                    frameRate: 10,
                    repeat: -1
                });
                this.anims.create({
                    key: 'turn',
                    frames: [
                        {
                            key: 'dude',
                            frame: 4
                        }
                    ]
                });
                this.cursors = this.input.keyboard.createCursorKeys();
                const stars = this.physics.add.group({
                    key: 'star',
                    repeat: 11,
                    setXY: {
                        x: 12,
                        y: 0,
                        stepX: 70
                    }
                });
                stars.children.iterate(function (child) {
                    child.setBounceY(Phaser.Math.FloatBetween(0.4, 0.8));
                });
                const bombs = this.physics.add.group();
                let score = 0;
                const scoreText = this.add.text(16, 16, 'score: 0', {
                    fontSize: '32px',
                    fill: '#000'
                });
                this.physics.add.collider(player, platforms);
                this.physics.add.collider(stars, platforms);
                this.physics.add.collider(bombs, platforms);
                this.physics.add.overlap(player, stars, function (player, star) {
                    star.disableBody(true, true);
                    score += 10;
                    scoreText.setText("Score: " + score);
                    if (stars.countActive(true) !== 0) return;
                    stars.children.iterate(function (child) {
                        child.enableBody(true, child.x, 0, true, true);
                    });
                    const x = (player.x < 400) ? Phaser.Math.Between(400, 800) :
                        Phaser.Math.Between(0, 400);
                    const bomb = bombs.create(x, 16, 'bomb');
                    bomb.setBounce(1);
                    bomb.setCollideWorldBounds(true);
                    bomb.setVelocity(Phaser.Math.Between(-200, 200), 20);
                    bomb.allowGravity = false;
                }, null, this);
                this.physics.add.collider(player, bombs, player => {
                    this.physics.pause();
                    player.setTint(0xff0000);
                    player.anims.play('turn');
                    this.gameOver = true;
                }, null, this);
            },
            update: function () {
                if (this.gameOver) return;
                const cursors = this.cursors;
                const player = this.player;
                if (cursors.left.isDown) {
                    player.setVelocityX(-160);
                    player.anims.play('left', true);
                } else if (cursors.right.isDown) {
                    player.setVelocityX(160);
                    player.anims.play('right', true);
                } else {
                    player.setVelocityX(0);
                    player.anims.play('turn');
                }
                if (cursors.up.isDown && player.body.touching.down) {
                    player.setVelocity(-330);
                }
            }
        }
    });
</script>
</body>
</html>
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)

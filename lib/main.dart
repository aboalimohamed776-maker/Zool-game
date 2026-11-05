import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: GameWidget(game: ZoolGame()))));
}

class ZoolGame extends FlameGame with TapCallbacks {
  late SpriteComponent player;
  late TextComponent scoreText;
  double groundY = 0;
  double score = 0;
  double timer = 0;
  bool gameOver = false;
  double playerVel = 0;
  final rand = Random();

  @override
  Future<void> onLoad() async {
    groundY = size.y - 90;
    await images.load('zool_boy.png');
    await images.load('croc.png');
    
    add(RectangleComponent(size: size, paint: Paint()..color = const Color(0xFFFF9A3C)));
    add(RectangleComponent(position: Vector2(size.x - 110, 45), size: Vector2(75, 75), paint: Paint()..color = const Color(0xFFFFEB3B)));
    add(RectangleComponent(position: Vector2(0, groundY-10), size: Vector2(size.x, 10), paint: Paint()..color = const Color(0xFF4FC3F7)));
    add(RectangleComponent(position: Vector2(0, groundY), size: Vector2(size.x, 90), paint: Paint()..color = const Color(0xFF8D5524)));

    player = SpriteComponent(sprite: Sprite(images.fromCache('zool_boy.png')), size: Vector2(68, 68), position: Vector2(55, groundY-68));
    add(player);
    
    scoreText = TextComponent(text: '0', position: Vector2(size.x/2, 40), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)));
    add(scoreText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameOver) {
      gameOver = false; score = 0; timer = 0; playerVel = 0;
      children.whereType<Croc>().forEach((e) => e.removeFromParent());
      player.position = Vector2(55, groundY-68);
      scoreText.text = '0';
    } else {
      if (player.position.y >= groundY-68) playerVel = -480;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) return;
    playerVel += 1000 * dt;
    player.position.y += playerVel * dt;
    if (player.position.y > groundY-68) { player.position.y = groundY-68; playerVel = 0; }
    
    score += dt * 15;
    scoreText.text = score.toInt().toString();
    timer += dt;
    if (timer > 1.4 + rand.nextDouble()) {
      timer = 0;
      add(Croc(sprite: Sprite(images.fromCache('croc.png')), position: Vector2(size.x+60, groundY-42)));
    }
    for (final c in children.whereType<Croc>()) {
      if (player.toRect().deflate(12).overlaps(c.toRect().deflate(8)) && player.position.y > groundY-75) {
        gameOver = true;
        scoreText.text = 'Game Over ${score.toInt()}\nTap';
      }
      if (c.position.x < -80) c.removeFromParent();
    }
  }
}

class Croc extends SpriteComponent {
  Croc({required Sprite sprite, required Vector2 position}) : super(sprite: sprite, position: position, size: Vector2(70, 38));
  @override
  void update(double dt) { position.x -= 280 * dt; }
  Rect toRect() => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}

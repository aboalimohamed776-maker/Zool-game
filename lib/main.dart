import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: GameWidget(game: ZoolGame()))));
}

class ZoolGame extends FlameGame with TapCallbacks {
  late Player player;
  late TextComponent scoreText;
  double groundY = 0;
  double score = 0;
  double timer = 0;
  bool gameOver = false;
  final rand = Random();

  @override
  Future<void> onLoad() async {
    groundY = size.y - 80;
    add(RectangleComponent(size: size, paint: Paint()..color = const Color(0xFFff9a3c)));
    add(RectangleComponent(position: Vector2(0, groundY), size: Vector2(size.x, 80), paint: Paint()..color = const Color(0xFF8d5524)));
    player = Player(position: Vector2(70, groundY - 50));
    add(player);
    scoreText = TextComponent(text: '0', position: Vector2(size.x/2, 40), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)));
    add(scoreText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameOver) {
      gameOver = false; score = 0; timer = 0;
      children.whereType<Croc>().forEach((e) => e.removeFromParent());
      player.position = Vector2(70, groundY - 50); player.vel = 0;
      scoreText.text = '0';
    } else {
      player.jump();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) return;
    score += dt * 10;
    scoreText.text = score.toInt().toString();
    timer += dt;
    if (timer > 1.6) {
      timer = 0;
      add(Croc(position: Vector2(size.x + 40, groundY - 30)));
    }
    for (final c in children.whereType<Croc>()) {
      if (player.position.x < c.position.x + 50 && player.position.x + 40 > c.position.x && player.position.y + 40 > groundY - 30) {
        gameOver = true;
        scoreText.text = 'Game Over ${score.toInt()}\nTap Retry';
      }
      if (c.position.x < -60) c.removeFromParent();
    }
  }
}

class Player extends PositionComponent {
  double vel = 0;
  Player({required Vector2 position}) : super(position: position, size: Vector2(40, 40));
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 40, 40), const Radius.circular(8)), Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(20, 8), 10, Paint()..color = const Color(0xFFd2a679));
  }
  void jump() { if (position.y >= (parent as ZoolGame).groundY - 50) vel = -400; }
  @override
  void update(double dt) {
    vel += 900 * dt;
    position.y += vel * dt;
    final g = (parent as ZoolGame).groundY;
    if (position.y > g - 50) { position.y = g - 50; vel = 0; }
  }
}

class Croc extends PositionComponent {
  Croc({required Vector2 position}) : super(position: position, size: Vector2(50, 30));
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 50, 25), const Radius.circular(6)), Paint()..color = const Color(0xFF2d7d46));
  }
  @override
  void update(double dt) { position.x -= 250 * dt; }
}

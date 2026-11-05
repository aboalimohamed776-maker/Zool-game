import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:math';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: GameWidget(game: ZoolGame()))));
}

class ZoolGame extends FlameGame with TapCallbacks {
  late ZoolPlayer player;
  late TextComponent scoreText;
  double groundY = 0;
  double score = 0;
  double obstacleTimer = 0;
  bool isGameOver = false;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    groundY = size.y - 90;
    add(RectangleComponent(size: size, paint: Paint()..color = const Color(0xFFff9a3c)));
    add(RectangleComponent(position: Vector2(size.x - 100, 60), size: Vector2(60, 60), paint: Paint()..color = const Color(0xFFFFEB3B)));
    add(RectangleComponent(position: Vector2(0, groundY), size: Vector2(size.x, 90), paint: Paint()..color = const Color(0xFF8d5524)));
    add(RectangleComponent(position: Vector2(0, groundY - 8), size: Vector2(size.x, 8), paint: Paint()..color = const Color(0xFF4FC3F7)));
    player = ZoolPlayer(position: Vector2(80, groundY - 60));
    add(player);
    scoreText = TextComponent(text: '0', position: Vector2(size.x / 2, 50), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)));
    add(scoreText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) { resetGame(); } else { player.jump(); }
  }

  void resetGame() {
    isGameOver = false; score = 0; obstacleTimer = 0;
    children.whereType<Crocodile>().forEach((e) => e.removeFromParent());
    player.position = Vector2(80, groundY - 60); player.velocity = 0;
    scoreText.text = '0';
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;
    score += dt * 15;
    scoreText.text = score.toInt().toString();
    obstacleTimer += dt;
    if (obstacleTimer > 1.4 + random.nextDouble()) {
      obstacleTimer = 0;
      add(Crocodile(position: Vector2(size.x + 60, groundY - 35)));
    }
    for (final croc in children.whereType<Crocodile>()) {
      if (player.toRect().overlaps(croc.toRect()) && player.position.y + 40 > groundY - 35) {
        isGameOver = true;
        scoreText.text = 'Game Over! ${score.toInt()}\nTap Retry';
      }
      if (croc.position.x < -80) croc.removeFromParent();
    }
  }
}

class ZoolPlayer extends PositionComponent {
  double velocity = 0; final double gravity = 1100; bool onGround = true;
  ZoolPlayer({required Vector2 position}) : super(position: position, size: Vector2(48, 58));
  @override
  void render(Canvas canvas) {
    final white = Paint()..color = Colors.white;
    final gold = Paint()..color = const Color(0xFFFFD700);
    final skin = Paint()..color = const Color(0xFFd2a679);
    gold.style = PaintingStyle.stroke; gold.strokeWidth = 2;
    canvas.drawCircle(const Offset(24, 10), 12, skin);
    canvas.drawCircle(const Offset(24, 6), 13, white);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(6, 24, 36, 32), const Radius.circular(8)), white);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(6, 24, 36, 32), const Radius.circular(8)), gold);
  }
  void jump() { if (onGround) { velocity = -480; onGround = false; } }
  @override
  void update(double dt) {
    velocity += gravity * dt; position.y += velocity * dt;
    final game = parent as ZoolGame;
    if (position.y >= game.groundY - 58) { position.y = game.groundY - 58; velocity = 0; onGround = true; }
  }
  Rect toRect() => Rect.fromLTWH(position.x + 8, position.y + 8, 32, 45);
}

class Crocodile extends PositionComponent {
  final double speed = 280;
  Crocodile({required Vector2 position}) : super(position: position, size: Vector2(70, 35));
  @override
  void render(Canvas canvas) {
    final green = Paint()..color = const Color(0xFF2d7d46);
    final dark = Paint()..color = const Color(0xFF1a4d2e);
    final yellow = Paint()..color = Colors.yellow;
    final white = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 10, 60, 18), const Radius.circular(9)), green);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(50, 6, 18, 16), const Radius.circular(4)), green);
    canvas.drawCircle(const Offset(60, 12), 3, yellow);
    for (int i = 0; i < 3; i++) { canvas.drawRect(Rect.fromLTWH(58 + i * 4, 20, 2, 4), white); }
    canvas.drawCircle(const Offset(20, 10), 2, dark);
  }
  @override
  void update(double dt) { position.x -= speed * dt; }
  Rect toRect() => Rect.fromLTWH(position.x + 5, position.y + 10, 55, 15);
}

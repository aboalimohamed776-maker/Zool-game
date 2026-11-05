import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'dart:math';

void main() { runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: GameWidget(game: ZoolGame())))); }

class ZoolGame extends FlameGame with TapDetector {
  late ZoolPlayer player; late TextComponent scoreText;
  double groundY = 0; double score = 0; double obstacleTimer = 0;
  Random random = Random(); bool isGameOver = false;
  @override
  Future<void> onLoad() async {
    groundY = size.y - 80;
    add(RectangleComponent(size: size, paint: Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFff9a3c), Color(0xFFff6a00), Color(0xFFf5d76e)]).createShader(Rect.fromLTWH(0,0,size.x,size.y))));
    add(RectangleComponent(position: Vector2(0, groundY), size: Vector2(size.x, 80), paint: Paint()..color = Color(0xFF8d5524)));
    player = ZoolPlayer(position: Vector2(80, groundY - 50)); add(player);
    scoreText = TextComponent(text: '0', position: Vector2(size.x/2, 50), anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))); add(scoreText);
  }
  @override void onTap() { if(isGameOver){ resetGame(); } else { player.jump(); } }
  void resetGame(){ isGameOver = false; score = 0; children.whereType<Obstacle>().forEach((e)=> e.removeFromParent()); player.position = Vector2(80, groundY - 50); player.velocity = 0; }
  @override void update(double dt){
    super.update(dt); if(isGameOver) return; score += dt * 10; scoreText.text = score.toInt().toString(); obstacleTimer += dt;
    if(obstacleTimer > 1.5 + random.nextDouble()){ obstacleTimer = 0; add(Obstacle(position: Vector2(size.x + 50, groundY - 40 - random.nextInt(20)))); }
    for(final obs in children.whereType<Obstacle>()){ if(player.toRect().overlaps(obs.toRect()) && player.position.y + 45 > groundY - 40){ isGameOver = true; scoreText.text = 'Game Over! ${score.toInt()} - Tap'; } if(obs.position.x < -60) obs.removeFromParent(); }
  }
}
class ZoolPlayer extends PositionComponent {
  double velocity = 0; double gravity = 900; bool onGround = true;
  ZoolPlayer({required Vector2 position}) : super(position: position, size: Vector2(45, 50));
  @override void render(Canvas canvas){ final paint = Paint()..color = Colors.white; final skin = Paint()..color = Color(0xFFd2a679); canvas.drawCircle(Offset(22, 10), 12, skin); canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5, 22, 35, 28), Radius.circular(6)), Radius.circular(6)), paint); }
  void jump(){ if(onGround){ velocity = -380; onGround = false; } }
  @override void update(double dt){ velocity += gravity * dt; position.y += velocity * dt; final game = parent as ZoolGame; if(position.y >= game.groundY - 50){ position.y = game.groundY - 50; velocity = 0; onGround = true; } }
  Rect toRect() => Rect.fromLTWH(position.x+5, position.y+5, 35, 40);
}
class Obstacle extends PositionComponent with HasPaint {
  double speed = 250; Obstacle({required Vector2 position}) : super(position: position, size: Vector2(50, 40));
  @override void onLoad(){ paint = Paint()..color = Color(0xFF2d7d46); }
  @override void render(Canvas canvas){ canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0,10,50,25), Radius.circular(8)), Radius.circular(8)), paint); canvas.drawCircle(Offset(45,15), 6, Paint()..color = Color(0xFF1a4d2e)); }
  @override void update(double dt){ position.x -= speed * dt; }
  Rect toRect() => Rect.fromLTWH(position.x+5, position.y+10, 40, 20);
}

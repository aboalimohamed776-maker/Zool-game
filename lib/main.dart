import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:math';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: GameWidget(game: ZoolGame())),
    ),
  );
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

    // سماء غروب دهبي برتقالي
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFff9a3c),
              Color(0xFFff6a00),
              Color(0xFFffcc70),
              Color(0xFF87CEEB),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
      ),
    );

    // شمس الغروب
    add(
      CircleComponent(
        radius: 40,
        position: Vector2(size.x - 80, 80),
        paint: Paint()..color = const Color(0xFFFFEB3B),
      ),
    );

    // أرض بنية - ضفة النيل
    add(
      RectangleComponent(
        position: Vector2(0, groundY),
        size: Vector2(size.x, 90),
        paint: Paint()..color = const Color(0xFF8d5524),
      ),
    );

    // نيل أزرق صغير فوق الأرض
    add(
      RectangleComponent(
        position: Vector2(0, groundY - 10),
        size: Vector2(size.x, 10),
        paint: Paint()..color = const Color(0xFF4FC3F7).withOpacity(0.6),
      ),
    );

    player = ZoolPlayer(position: Vector2(80, groundY - 60));
    add(player);

    scoreText = TextComponent(
      text: '0',
      position: Vector2(size.x / 2, 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
        ),
      ),
    );
    add(scoreText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) {
      resetGame();
    } else {
      player.jump();
    }
  }

  void resetGame() {
    isGameOver = false;
    score = 0;
    obstacleTimer = 0;
    children.whereType<Crocodile>().forEach((e) => e.removeFromParent());
    player.position = Vector2(80, groundY - 60);
    player.velocity = 0;
    scoreText.text = '0';
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    score += dt * 15;
    scoreText.text = score.toInt().toString();
    obstacleTimer += dt;

    if (obstacleTimer > 1.4 + random.nextDouble() * 1.2) {
      obstacleTimer = 0;
      add(Crocodile(position: Vector2(size.x + 60, groundY - 35)));
    }

    for (final croc in children.whereType<Crocodile>()) {
      if (player.toRect().overlaps(croc.toRect())) {
        if (player.position.y + 45 > groundY - 40) {
          isGameOver = true;
          scoreText.text = 'Game Over! ${score.toInt()}\nTap to Retry';
        }
      }
      if (croc.position.x < -80) {
        croc.removeFromParent();
      }
    }
  }
}

class ZoolPlayer extends PositionComponent {
  double velocity = 0;
  final double gravity = 1100;
  bool onGround = true;

  ZoolPlayer({required Vector2 position})
      : super(position: position, size: Vector2(48, 58));

  @override
  void render(Canvas canvas) {
    // جلابية بيضاء مع تطريز دهبي
    final jalabiyaPaint = Paint()..color = Colors.white;
    final goldPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final skinPaint = Paint()..color = const Color(0xFFd2a679);

    // رأس
    canvas.drawCircle(const Offset(24, 12), 13, skinPaint);
    // طاقية بيضاء
    canvas.drawCircle(const Offset(24, 6), 14, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(24, 6), 14, goldPaint);

    // جسم جلابية
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 24, 36, 32),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, jalabiyaPaint);
    canvas.drawRRect(rect, goldPaint);

    // أيادي
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(2, 28, 8, 18), const Radius.circular(4)),
      jalabiyaPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(38, 28, 8, 18), const Radius.circular(4)),
      jalabiyaPaint,
    );
  }

  void jump() {
    if (onGround) {
      velocity = -480;
      onGround = false;
    }
  }

  @override
  void update(double dt) {
    velocity += gravity * dt;
    position.y += velocity * dt;
    final game = parent as ZoolGame;
    if (position.y >= game.groundY - 58) {
      position.y = game.groundY - 58;
      velocity = 0;
      onGround = true;
    }
  }

  Rect toRect() => Rect.fromLTWH(position.x + 8, position.y + 8, 32, 45);
}

class Crocodile extends PositionComponent {
  final double speed = 280;

  Crocodile({required Vector2 position})
      : super(position: position, size: Vector2(70, 38));

  @override
  void render(Canvas canvas) {
    final bodyPaint = Paint()..color = const Color(0xFF2d7d46);
    final darkPaint = Paint()..color = const Color(0xFF1a4d2e);
    final eyePaint = Paint()..color = Colors.yellow;
    final teethPaint = Paint()..color = Colors.white;

    // جسم التمساح
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 12, 60, 20), const Radius.circular(10)),
      bodyPaint,
    );
    // رأس مع أسنان
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(50, 8, 20, 18), const Radius.circular(5)),
      bodyPaint,
    );
    // عين صفراء
    canvas.drawCircle(const Offset(62, 14), 4, eyePaint);
    canvas.drawCircle(const Offset(63, 14), 1.5, Paint()..color = Colors.black);
    // أسنان بيضاء
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(62 + i * 4, 22, 2, 5), teethPaint);
    }
    // شوك ظهر
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(Offset(15 + i * 12, 12), 3, darkPaint);
    }
  }

  @override
  void update(double dt) {
    position.x -= speed * dt;
  }

  Rect toRect() => Rect.fromLTWH(position.x + 5, position.y + 12, 55, 18);
}

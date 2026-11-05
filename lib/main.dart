import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(game: ZoolGame()),
      ),
    ),
  );
}

class ZoolGame extends FlameGame with TapCallbacks {
  late TextComponent text;
  
  @override
  Future<void> onLoad() async {
    // خلفية برتقالية - غروب
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFFff9a3c),
      ),
    );
    
    // نص في النص
    text = TextComponent(
      text: 'Zool Game\nTap Anywhere!\n\nلعبة زول - النسخة التجريبية',
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(text);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // لما تدوس، غير النص
    text.text = 'Arh ya Zool!\n\nتم! اللعبة شغالة 🔥';
  }
}

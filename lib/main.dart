import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  final game = ScroochesGame();
  runApp(AppRoot(game: game));
}

class ScroochesGame extends FlameGame with HasCollisionDetection, HasTappables {
  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onLoad() async {
    final sprite = await Sprite.load('scrooch1.png');
    add(MyCrate(sprite: sprite, position: size * 0.5));
    add(ScreenHitbox());
  }
}

class AppRoot extends StatelessWidget {
  final ScroochesGame game;

  const AppRoot({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}

class MyCrate extends SpriteComponent
    with CollisionCallbacks, Tappable, HasGameRef<FlameGame> {
  static const double speedMultiplier = 5;

  MyCrate({required super.sprite, required super.position})
      : super(size: Vector2.all(128));

  Vector2 direction = Vector2.zero();
  double speed = 0.0;
  double rotationSpeed = 2;
  double nextUpdate = 0.0;

  @override
  Future<void> onLoad() async {
    size = Vector2.all(128);
    add(RectangleHitbox(size: size));
    scale = Vector2.all(0.01);
    setDirection();
  }

  setDirection() {
    direction = (Vector2.random() - Vector2(0.5, 0.5)) * 2.0;
    speed = ((Random().nextDouble() - 0.5) * 15 + 15) * speedMultiplier;
    nextUpdate = Random().nextDouble() * 5;
    anchor = Anchor.center;
    print("speed = $speed");
    print("direction = $direction");
  }

  @override
  bool onTapDown(TapDownInfo info) {
    print("tap down");
    gameRef.add(MyCrate(sprite: sprite, position: position));
    return true;
  }

  @override
  void update(double dt) {
    if (scale.x < 1) {
      scale += Vector2.all(dt * 0.1);
    }
    position = position + (direction * dt * speed);
    nextUpdate -= dt;
    angle += dt * rotationSpeed;
    if (nextUpdate <= 0) {
      setDirection();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is ScreenHitbox) {
      direction = -direction;
      print('reverse');
    }

    super.onCollision(intersectionPoints, other);
  }
}

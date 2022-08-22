import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

const popSound = 'pop.mp3';

void main() {
  final game = ScroochesGame();
  runApp(AppRoot(game: game));
}

class ScroochesGame extends FlameGame with HasCollisionDetection, HasTappables {
  @override
  Color backgroundColor() => Colors.white;

  final startingScrooches = 10;

  @override
  Future<void> onLoad() async {
    await FlameAudio.audioCache.load(popSound);
    await FlameAudio.createPool(popSound, maxPlayers: 20, minPlayers: 0);
    final sprites = await Future.wait([
      'scrooch1.png',
      'scrooch2.png',
      'scrooch3.png',
      'scrooch4.png',
      'scrooch5.png'
    ].map((e) => Sprite.load(e)));
    for (var i = 0; i < startingScrooches; i++) {
      add(Scrooch(
          sprites: sprites,
          position: Vector2(
              Random().nextDouble() * size.x, Random().nextDouble() * size.y)));
    }
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

enum ScroochState { comingAlive, alive }

class Scrooch extends SpriteComponent
    with CollisionCallbacks, Tappable, HasGameRef<FlameGame> {
  static const double speedMultiplier = 5;

  final List<Sprite> sprites;

  Scrooch({required this.sprites, required super.position})
      : super(size: Vector2.all(128));

  Vector2 direction = Vector2.zero();
  double speed = 0.0;
  double rotationSpeed = 2;
  double nextUpdate = 0.0;
  ScroochState state = ScroochState.comingAlive;
  double age = 0.0;

  @override
  Future<void> onLoad() async {
    sprite = sprites[Random().nextInt(sprites.length)];
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
  }

  @override
  bool onTapDown(TapDownInfo info) {
    print("tap down");
    gameRef.add(Scrooch(sprites: sprites, position: position));
    FlameAudio.play(popSound);
    gameRef.remove(this);
    return true;
  }

  @override
  void update(double dt) {
    age += dt;
    const oldAge = 10.0;
    if (age > oldAge) {
      final secondsOld = age - oldAge;
      final opacity = 1.0 - secondsOld / 4;
      if (opacity < 0.0) {
        gameRef.remove(this);
        gameRef.add(Scrooch(sprites: sprites, position: position));
      } else {
        setOpacity(opacity);
      }
    }
    if (state == ScroochState.comingAlive) {
      if (scale.x < 1) {
        scale += Vector2.all(dt * 0.1);
      } else {
        state = ScroochState.alive;
      }
    } else if (state == ScroochState.alive) {
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

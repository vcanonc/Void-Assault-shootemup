class PatternShooter {

    Game game;

    PatternShooter(Game game) {
        this.game = game;
    }

    void radial(PVector position, int numOfBullets, float speed, BulletType type) {
        for (int i = 0; i < numOfBullets; ++i) {
            float angle = TWO_PI * i / numOfBullets;

            PVector vel = new PVector(cos(angle) * speed, sin(angle) * speed);
            game.addBullet(position.x, position.y, vel, type);
        }
    }

    void halfRadial(PVector position, int numOfBullets, float speed, BulletType type) {
        for (int i = 0; i < numOfBullets; ++i) {
            float angle = PI * i / numOfBullets;

            PVector vel = new PVector(cos(angle) * speed, sin(angle) * speed);
            game.addBullet(position.x, position.y, vel, type);
        }
    }

    void spiral(PVector position, int lines, float baseAngle, float speed) {
        for (int i = 0; i < lines; i++) {
            float angle = baseAngle + TWO_PI * i / lines;
            BulletType type = (random(0, 1) < 0.5) ? BulletType.TANK_ENEMY : BulletType.BOSS_ENEMY;

            PVector vel = new PVector(cos(angle) * speed, sin(angle) * speed);
            game.addBullet(position.x, position.y, vel, type);
        }
    }

    void spiral(PVector position, int lines, float baseAngle, float speed, BulletType type) {
        for (int i = 0; i < lines; i++) {
            float angle = baseAngle + TWO_PI * i / lines;

            PVector vel = new PVector(cos(angle) * speed, sin(angle) * speed);
            game.addBullet(position.x, position.y, vel, type);
        }
    }

    void flower(PVector position, int numOfPetals, int numOfBullets, float baseSpeed, BulletType type) {
        for (int i = 0; i < numOfBullets; ++i) {
            float angle = TWO_PI * i / numOfBullets;
            float speed = baseSpeed - abs(sin(numOfPetals * angle));

            PVector vel = new PVector(cos(angle) * speed, sin(angle) * speed);
            game.addBullet(position.x, position.y, vel, type);
        }
    }
}
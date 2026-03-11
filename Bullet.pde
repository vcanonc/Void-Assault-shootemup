enum BulletType {
    PLAYER,
    BASIC_ENEMY,
    TANK_ENEMY,
    BOSS_ENEMY,
    BOSS2_ENEMY
}

class Bullet {

    Game game;
    PVector position;
    PVector velocity;
    float radius;
    boolean isActive;
    BulletType type;
    int damage;
    private float lastMillis;
    private PImage sprite;
    private int spriteWidth;
    private int spriteHeight;

    Bullet(float x, float y, PVector vel, BulletType t) {
        position = new PVector(x, y);
        velocity = vel.copy();
        isActive = true;
        type = t;
        lastMillis = millis();

        switch (type) {
            case PLAYER:
                sprite = playerBullet;
                radius = 6;
                spriteWidth = 7;
                spriteHeight = 19;
                damage = 1;
                break;
            case BASIC_ENEMY:
                sprite = basicEnemyBullet;
                radius = 6;
                spriteWidth = 16;
                spriteHeight = 16;
                damage = 1;
                break;
            case TANK_ENEMY:
                sprite = tankBullet;
                radius = 6;
                spriteWidth = 16;
                spriteHeight = 16;
                damage = 2;
                break;
            case BOSS_ENEMY:
                sprite = bossBullet;
                radius = 6;
                spriteWidth = 7;
                spriteHeight = 19;
                damage = 2;
                break;
            case BOSS2_ENEMY:
                sprite = boss2Bullet;
                radius = 6;
                spriteWidth = 8;
                spriteHeight = 16;
                damage = 3;
                break;
        }
    }

    void update() {
        position.add(velocity);

        if (position.y < -radius || position.y > HEIGHT + radius) {
            isActive = false;
        }

        if (millis() - lastMillis > 6000) {
            isActive = false;
        }
    }

    void show() {
        pushMatrix();

        translate(position.x, position.y);
        
        noStroke();
        fill(255, 30);
        circle(0, 0, radius * 5);

        rotate(velocity.heading() + HALF_PI);
        image(sprite, 0, 0, spriteWidth, spriteHeight);

        popMatrix();
    }
}

enum EnemyType {
    BASIC,
    FAST,
    TANK,
    BOSS
}

enum FastState {
    GET_CLOSE,
    AIMING,
    CHARGING
}

enum BossAttacks {
    ENTERING,
    RADIAL,
    SPIRAL,
    FLOWER
}

class Enemy {

    Game game;
    EnemyType type;
    PVector position;
    PVector velocity;
    float radius;
    int health;
    int maxHealth;
    boolean isActive;
    private int shootDelay;
    private int shootCounter;
    private FastState fastState;    // Atributo únicamente utilizado cuando type == EnemyType.FAST
    private int aimTimer;           // Atributo de apuntado de enemigos tipo FAST
    private boolean isPatrolling;   // Usado en enemigos tipo TANK
    private BossAttacks phase;      // Usado para coordinar los diferentes ataques de BOSS
    private float spiralAngle;      // Se usa para generar los patrones spiral con la clase PatternShooter

    private PImage sprite;          // Sprite del enemigo, se asigna dependiendo del tipo
    private int frameWidth;         // Ancho de cada frame de propulsionEnemySprite
    private int frameHeight;        // Alto de cada frame de propulsionEnemySprite
    private int currentFrame;
    private int animCounter;
    private int animSpeed;
    boolean dyingAnimationFinished;
    private int hitFlashTimer;      // Temporizador para el efecto de parpadeo al recibir daño
    private int hitFlashDuration;   // Duración del efecto de parpadeo al recibir daño

    Enemy(Game game, float x, float y, EnemyType type) {
        this.game = game;
        this.type = type;
        isActive = true;

        position = new PVector(x, y);

        frameWidth = 16;
        frameHeight = 19;
        animCounter = 0;
        animSpeed = 8;
        currentFrame = 0;
        
        dyingAnimationFinished = false;
        hitFlashTimer = 0;
        hitFlashDuration = 2;
        configureByType();
        
        shootCounter = floor(random(shootDelay));
    }

    void update() {
        if (!isActive) {
            if (!dyingAnimationFinished) {
                animateDeath();
                if (currentFrame <= 0) {
                    dyingAnimationFinished = true;
                }
            }
            return;
        }

        if (hitFlashTimer > 0) {
            --hitFlashTimer;
        }

        movePattern();

        position.add(velocity);

        if (type == EnemyType.BOSS) {

            if (health < 250 && phase == BossAttacks.RADIAL) {
                phase = BossAttacks.SPIRAL;
                shootDelay = 27;
            }

            if (health < 150 && phase == BossAttacks.SPIRAL) {
                phase = BossAttacks.FLOWER;
                shootDelay = 50;
            }

        }

        // En el caso de que el enemigo sale de la pantalla
        if (position.x < -radius || position.x > WIDTH + radius || position.y > HEIGHT + radius) {
            isActive = false;
        }

        // Lógica para el disparo de balas
        --shootCounter;
        if (shootCounter <= 0) {
            shoot();
            shootCounter = shootDelay;
        }

        animatePropulsion();
    }

    void show() {
        if (!isActive) {
            if (!dyingAnimationFinished) {
                showDeathAnimation();
                return;
            }
        }

        showPropulsionAnimation();

        if (hitFlashTimer > 0) {
            tint(255, 180, 180); // Aplica un tinte rojo para el efecto de parpadeo
            game.setShakeAmount(0.6);
        }

        image(sprite, position.x, position.y, sprite.width, sprite.height); // Sprite del enemigo
        
        noTint(); // Elimina cualquier tinte aplicado
        
        if (type == EnemyType.FAST && fastState == FastState.AIMING) {
            stroke(255, 0, 0);
            line(position.x, position.y, game.getPlayerPosition().x, game.getPlayerPosition().y);
            noStroke();
        }
    }

    private void animatePropulsion() {
        ++animCounter;
        if (animCounter >= animSpeed) {
            animCounter = 0;
            currentFrame = (currentFrame + 1) % 4;;
        }
    }

    void startDeathAnimation() {
        isActive = false;
        animCounter = 0;
        currentFrame = 7;
        animSpeed = 2;
        frameWidth = 64;
        frameHeight = 64;
    }
    
    private void animateDeath() {
        ++animCounter;
        if (animCounter >= animSpeed) {
            animCounter = 0;
            --currentFrame;
        }
    }

    /**
    Muestra la animación de propulsión del enemigo dependiendo del tipo.
    */
    private void showPropulsionAnimation() {
        int x1 = currentFrame * frameWidth;
        int y1 = 0;
        int x2 = x1 + frameWidth;
        int y2 = frameHeight;

        switch(type) {
            case BASIC:
                image(propulsionEnemySprite, position.x - 8, position.y - 22, frameWidth, frameHeight, x1, y1, x2, y2);
                image(propulsionEnemySprite, position.x + 8, position.y - 22, frameWidth, frameHeight, x1, y1, x2, y2);
                break;
            case FAST:
                image(propulsionEnemySprite, position.x, position.y - 20, frameWidth, frameHeight, x1, y1, x2, y2);
                break;
            case TANK:
                image(propulsionEnemySprite, position.x, position.y - 50, frameWidth, frameHeight, x1, y1, x2, y2);
                break;
            case BOSS:
                int padding = 120;

                // Bajando
                if (velocity.y > 0) {
                    image(propulsionBossSprite, position.x, position.y - padding, frameWidth, frameHeight, x1, y1, x2, y2);
                }

                // Subiendo
                if (velocity.y < 0) {
                    pushMatrix();

                    translate(position.x, position.y);
                    rotate(PI);
                    image(propulsionBossSprite, 0, -padding, frameWidth, frameHeight, x1, y1, x2, y2);
                    
                    popMatrix();
                }

                // Yendo a la izquierda
                if (velocity.x < 0) {
                    pushMatrix();

                    translate(position.x, position.y);
                    rotate(HALF_PI);
                    
                    image(propulsionBossSprite, 0, -padding, frameWidth, frameHeight, x1, y1, x2, y2);
                    popMatrix();
                }

                // Yendo a la derecha
                if (velocity.x > 0) {
                    pushMatrix();

                    translate(position.x, position.y);
                    rotate(-HALF_PI);
                    
                    image(propulsionBossSprite, 0, -padding, frameWidth, frameHeight, x1, y1, x2, y2);
                    popMatrix();
                }
                break;
        }
    }

    /**
    Muestra la animación de muerte del enemigo.
    */
    private void showDeathAnimation() {
        int x1 = currentFrame * frameWidth;
        int y1 = 0;
        int x2 = x1 + frameWidth;
        int y2 = frameHeight;

        image(explosionSprite, position.x, position.y, frameWidth, frameHeight, x1, y1, x2, y2);
    }

    /**
    Función que hace que el enemigo dispare.
    */
    void shoot() {
        if (type == EnemyType.BASIC) {
            PVector vel = new PVector(velocity.x, velocity.y + 5);
            game.addBullet(position.x, position.y, vel, BulletType.BASIC_ENEMY);
        }

        if (type == EnemyType.TANK) {
            game.ps.halfRadial(position.copy(), 12, 3, BulletType.TANK_ENEMY);
        }

        if (type == EnemyType.BOSS) {
            if (phase == BossAttacks.RADIAL) {
                game.ps.radial(position.copy(), 20, 4, BulletType.BASIC_ENEMY);
                game.ps.spiral(position.copy(), 6, spiralAngle, 4, BulletType.BOSS_ENEMY);
                spiralAngle += 0.15;
            }

            if (phase == BossAttacks.SPIRAL) {;
                game.ps.spiral(position.copy(), 7, spiralAngle, 3, BulletType.TANK_ENEMY);
                game.ps.spiral(position.copy(), 7, -spiralAngle, 3, BulletType.TANK_ENEMY);
                game.ps.spiral(position.copy(), 4, spiralAngle, 4, BulletType.BOSS_ENEMY);
                game.ps.spiral(position.copy(), 4, PI + spiralAngle, 4, BulletType.BOSS_ENEMY);
                spiralAngle += 0.12;
            }

            if (phase == BossAttacks.FLOWER) {
                BulletType type = (random(0, 1) < 0.5) ? BulletType.BASIC_ENEMY : BulletType.BOSS2_ENEMY;
                game.ps.flower(position.copy(), 7, 28, 5, BulletType.BOSS_ENEMY);
                game.ps.radial(position.copy(), 9, 3, type);
            }
        }
    }

    /**
    Función que hace que el enemigo reciba daño.
    @param amount Cantidad de daño a recibir.
     */
    void takeDamage(int amount) {
        if (type == EnemyType.BOSS && phase == BossAttacks.ENTERING) {
            return;
        }

        health -= amount;

        hitFlashTimer = hitFlashDuration; // Reiniciar el temporizador de parpadeo al recibir daño

        if (health <= 0) {
            gs.playSfxExplosion();
            startDeathAnimation();
        } else if (type != EnemyType.BOSS && type != EnemyType.TANK) {
            gs.playSfxHit();
        }
    }

    /**
    Establece patrones de movimiento para enemigos de algunos tipos específicos.
    */
    void movePattern() {
        if (type == EnemyType.FAST) {
            moveFastEnemy();
        }

        if (type == EnemyType.BOSS) {
            moveBossEnemy();
        }

        if (type == EnemyType.TANK) {
            moveTankEnemy();
        }
    }

    /**
    Función que establece el patrón de movimiento del enemigo tipo FAST.
    Tiene un comportamiento similar a un enemigo del tipo kamikaze: 
    primero se acerca al jugador, luego apunta hacia él durante un segundo
    y finalmente carga en su dirección a gran velocidad.
    */
    private void moveFastEnemy() {
        if (fastState == FastState.GET_CLOSE) {
            int padding = 25;
            if (position.x > padding && position.x < WIDTH - padding) {
                velocity.x = 0;
            }
            if (position.y > radius + padding) {
                velocity.y = 0;
            }
            if (velocity.x == 0 && velocity.y == 0) {
                fastState = FastState.AIMING;
            }
        }

        if (fastState == FastState.AIMING) {
            gs.playSfxScan();
            --aimTimer;
            velocity.x = cos(frameCount * 0.2) * 0.5;
            velocity.y = sin(frameCount * 0.2) * 0.5;

            if (aimTimer <= 0) {
                PVector.sub(game.getPlayerPosition(), position, velocity);
                velocity.normalize();
                velocity.mult(16);
                fastState = FastState.CHARGING;
            }
        }
    }

    /**
    Función que establece el patrón de movimiento del enemigo tipo TANK.
    */
    private void moveTankEnemy() {
        if (!isPatrolling) {
            if (position.y >= HEIGHT / 3) {
                velocity.y = 0;
                velocity.x = 1;
                isPatrolling = true;
            }
            return;
        }
        
        if (position.x < radius || position.x > WIDTH - radius) {
            velocity.x *= -1;
        }
    }

    /**
    Función que establece el patrón de movimiento del enemigo tipo BOSS dependiendo
    de la fase en la que se encuentre.
    */
    private void moveBossEnemy() {
        switch(phase) {
            case ENTERING:
                if (position.y >= HEIGHT / 3) {
                    velocity.y = 0;
                    velocity.x = 2;
                    phase = BossAttacks.RADIAL;
                }
                break;
            case RADIAL:
                if (position.x < radius || position.x > WIDTH - radius) {
                    velocity.x *= -1;
                }
                velocity.y = sin(frameCount * 0.05) * 0.3;
                break;
            case SPIRAL:
                float targetX = WIDTH * 0.5;
                float dx = targetX - position.x;
                velocity.x = dx * 0.05;
                if (abs(dx) < 1) {
                    velocity.x = 0;
                }
                velocity.y = sin(frameCount * 0.05) * 0.5;
                break;
            case FLOWER:
                velocity.x = cos(frameCount * 0.05) * 0.5;
                velocity.y = sin(frameCount * 0.05) * 0.5;
                break;
        }
    }

    /**
    Esta función inicializa todas los atributos del enemigo dependiendo
    de su tipo.
    */
    private void configureByType() {
        switch(type) {
            case BASIC:
                velocity = new PVector(0, 4);
                radius = 18;
                maxHealth = 1;
                health = maxHealth;
                shootDelay = 60;

                sprite = basicEnemySprite;
                break;

            case FAST:
                velocity = new PVector();
                PVector.sub(game.getPlayerPosition(), position, velocity);
                velocity.normalize();
                velocity.mult(2);
                radius = 10;
                maxHealth = 1;
                health = maxHealth;
                fastState = FastState.GET_CLOSE;
                aimTimer = 66;  // 1 segundo de espera apuntando al jugador

                sprite = fastEnemySprite;
                break;

            case TANK:
                velocity = new PVector(0, 1.5);
                radius = 40;
                maxHealth = 30;
                health = maxHealth;
                shootDelay = 120;
                isPatrolling = false;

                sprite = tankEnemySprite;
                break;

            case BOSS:
                velocity = new PVector(0, 1);
                radius = 90;
                maxHealth = 350;
                health = maxHealth;
                shootDelay = 60;
                phase = BossAttacks.ENTERING;

                sprite = bossEnemySprite;
                frameWidth = 32;
                frameHeight = 38;
                break;
        }
    }
}

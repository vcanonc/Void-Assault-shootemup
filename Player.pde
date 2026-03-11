class Player {

    Game game;
    PVector position;
    PVector velocity;
    float acceleration;
    private float radius;             // Radio de la circunferencia que define el collider del player
    private int health;               // Verdadero atributo de nivel de salud
    private int maxHealth;            // Atributo utilizado para la GUI
    boolean isActive;                 // Esta variable sirve para definir cuando mostrar el jugador
    boolean isDead;                   // Para verificar cuando el jugador ha muerto
    boolean deathAnimationFinished;
    private boolean isSpawning;
    private boolean isDespawning;
    boolean spawnAnimationFinished;
    boolean despawnAnimationFinished;
    private boolean invulnerable;
    private int invulnerableCounter;  // Contador para el control de tiempo de invulnerabilidad
    private int invulnerableDuration; // Intervalo de tiempo de invulnerabilidad
    private int shootDelay;           // Intervalo entre cada bala disparada
    private int shootCounter;         // Contador para el control de disparo

    private PImage spriteSheet;       // Guarda los sprites del jugador
    private int animCounter;
    private int animSpeed;            // Entre mayor sea más lento será la animación
    private int currentRow;           // Numero de fila del sprite
    private int currentCol;           // Numero de columna del sprite
    private int frameSize;            // Número de pixeles de ancho y alto del sprite

    Player(Game game) {
        this.game = game;
        position = new PVector(WIDTH / 2, 32);
        velocity = new PVector();
        acceleration = 4.5;
        radius = 12;
        maxHealth = 10;
        health = maxHealth;
        isActive = true;
        isDead = false;
        deathAnimationFinished = false;
        invulnerable = false;
        invulnerableCounter = 0;
        invulnerableDuration = 60;
        shootDelay = 18;
        shootCounter = shootDelay;

        spriteSheet = loadImage("images/player_sprites.png");
        animCounter = 0;
        animSpeed = 10;
        currentCol = 0;
        currentRow = 0;
        frameSize = 64;
        isSpawning = false;
        isDespawning = false;
        spawnAnimationFinished = false;
        despawnAnimationFinished = false;
    }

    void update() {
        if (isSpawning) {
            if (position.y < HEIGHT * 3/4) {
                position.y += 4;
            }
            animateSpawn();
            if (spawnAnimationFinished && position.y >= HEIGHT * 3/4) {
                isSpawning = false;
            }
            return;
        }

        if (isDespawning) {
            animateDespawn();
            if (despawnAnimationFinished) {
                isDespawning = false;
            }
            return;
        }

        if (isDead) {
            animateDeath();
            return;
        }

        move();

        if (invulnerable) {
            invulnerableCounter--;
            if (invulnerableCounter <= 0) {
            invulnerable = false;
            }
        }

        // Para disparar usando una tecla
        if (shootCounter > 0) {
            --shootCounter;
        }

        if (shooting && shootCounter == 0) {
            shoot();
            shootCounter = shootDelay;
        }

        animate();
    }

    void show() {
        // Para el parpadeo cuando es invulnerable
        if (!invulnerable || frameCount % 10 < 5) {
            int x1 = currentCol * frameSize;
            int y1 = currentRow * frameSize;
            int x2 = x1 + frameSize;
            int y2 = y1 + frameSize;
            image(spriteSheet, position.x, position.y, frameSize, frameSize, x1, y1, x2, y2);
        }
    }

    private void shoot() {
        PVector velocity = new PVector(0, -8);
        game.addBullet(position.x - 15, position.y, velocity, BulletType.PLAYER);
        game.addBullet(position.x + 15, position.y, velocity, BulletType.PLAYER);
        gs.playSfxShot();
    }

    /**
    Lee las variables booleanas que señalan a donde quiere
    moverse el usuario para modificar las variables de velocidad
    y posteriormente la posición del jugador.
    */
    private void move() {
        velocity.set(0, 0);

        if (dirUp) {
            velocity.y = -acceleration;
        }
        if (dirDown) {
            velocity.y = acceleration;
        }
        if (dirLeft) {
            velocity.x = -acceleration;
        }
        if (dirRight) {
            velocity.x = acceleration;
        }
        position.add(velocity);

        position.x = constrain(position.x, radius, WIDTH - radius);
        position.y = constrain(position.y, radius, HEIGHT - radius);
    }

    /**
    En caso de que el jugador reciba daño se hace invulnerable por un
    tiempo, se agista la pantalla y se le decrementa su salud. 
    En caso de llegar a ser nula el jugador pasa a estar inactivo.
    */
    void takeDamage(int amount) {
        if (invulnerable) {
            return;
        }

        health -= amount;

        invulnerable = true;
        invulnerableCounter = invulnerableDuration;
        game.setShakeAmount(3.5);

        if (health <= 0) {
            gs.playSfxExplosion();
            isDead = true;
            health = 0;
            animCounter = 0;
            currentCol = 0;
        } else {
            gs.playSfxHit();
        }
    }

    /**
    Esta función gestiona los atributos currentRow y currentCol para
    que se tome diferentes subsecciones del set de sprites del jugador.
    */
    private void animate() {
        // Cambia la fila según la dirección a la que se dirige la nave
        if (dirLeft) {
            currentRow = 2;
        } else if (dirRight) {
            currentRow = 1;
        } else {
            currentRow = 0;
        }

        ++animCounter;
        // Si la nave está quieta
        if (currentRow == 0 && !dirUp && animCounter >= animSpeed) {
            int n = floor(random(0, 101));
            if (n % 2 == 0) {
                currentCol = 1;
            } else {
                currentCol = 2;
            }
            animCounter = 0;
        }

        // Si la nave está volando hacía adelante
        if (currentRow == 0 && dirUp) {
            currentCol = 3;
        }

        // Si la nave se dirige a la izquierda o derecha
        if (currentRow == 1 || currentRow == 2) {
            if (dirUp) {  // Si se dirige hacía adelante en diagonal
                currentCol = 2;
            } else if (dirDown) {  // Si la nave se dirige hacía atrás en diagonal
                currentCol = 0;
            } else {  // Si la nave solo se mueve a un lado
                currentCol = 1;
            }
        }

        // Si la nave está retrocediendo
        if (currentRow == 0 && dirDown) {
            currentCol = 0;
        }
    }


    private void animateDeath() {
        currentRow = 3; // fila de explosión

        ++animCounter;

        if (animCounter >= animSpeed) {
            animCounter = 0;

            currentCol++;
            if (currentCol > 10) {   // último frame
                currentCol = 10;
                deathAnimationFinished = true;
                isActive = false;
            }
        }
    }

    void startDespawnAnimation() {
        isDespawning = true;
        despawnAnimationFinished = false;
        animCounter = 0;
        currentRow = 4;
        currentCol = 0;
    }

    void startSpawnAnimation() {
        isSpawning = true;
        spawnAnimationFinished = false;
        animCounter = 0;
        currentRow = 4;
        currentCol = 11;
    }

    private void animateDespawn() {
        animCounter++;
        if (animCounter >= animSpeed) {
            ++currentCol;
            animCounter = 0;
            if (currentCol > 10) {
                currentCol = 10;
                isDespawning = false;
                despawnAnimationFinished = true;
                isActive = false;
            }
        }
    }

    private void animateSpawn() {
        animCounter++;
        if (animCounter >= animSpeed) {
            --currentCol;
            animCounter = 0;
            if (currentCol <= 0) {
                currentCol = 0;
                isSpawning = false;
                spawnAnimationFinished = true;
            }
        }
    }
}

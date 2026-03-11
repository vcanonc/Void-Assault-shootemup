import java.util.List;
import java.util.ArrayList;

class Game {

    int score;

    private Background bg;
    private Player player;
    private List<Bullet> bullets;
    private List<Enemy> enemies;
    private List<HitParticle> hitParticles;
    PatternShooter ps;

    private float shakeAmount;          // Cantidad de shake para la pantalla, se reduce gradualmente a 0

    private boolean isBossActive;
    private Enemy bossRef;              // Referencia al enemigo jefe activo, para mostrar su barra de salud

    private List<LevelEvent> events;    // Lista de eventos que contiene el juego
    private int currentEvent;           // Índice del evento activo en ejecución
    private int eventTimer;             // Realiza un conteo de tiempo mientras un evento está activo
    private boolean warningActive;      // Variable para mostrar un mensaje antes de la aparición del BOSS
    private int warningTimer;
    private boolean flashActive;
    private int flashTimer;
    private boolean hudFlashing;
    private int hudTimer;

    Game() {
        bg = new Background();
        player = new Player(this);
        bullets = new ArrayList();
        enemies = new ArrayList();
        hitParticles = new ArrayList();
        events = new ArrayList();
        ps = new PatternShooter(this);
        currentEvent = 0;
        eventTimer = 0;
        warningActive = false;
        warningTimer = 0;
        flashActive = false;
        flashTimer = 0;
        hudFlashing = false;
        hudTimer = 0;
        score = 0;

        buildLevel();
    }

    void update() {
        shakeAmount *= 0.95;  // Reduce gradualmente el shake
        updateBackground();
        
        if (player.isDespawning || player.isSpawning) {
            player.update();
            return;
        }

        if (player.isDead && player.deathAnimationFinished) {
            gm.setGameState(GameState.GAME_OVER);
        }

        updateLevel();
        if (gm.getGameState() == GameState.PLAYING) {
            gs.updateMusic();
        }
        
        isBossActive = false;
        for (Enemy e : enemies) {
            if (e.isActive && e.type == EnemyType.BOSS) {
                isBossActive = true;
                bossRef = e;
                break;
            }
        }

        hitParticles.forEach(p -> p.update());
        hitParticles.removeIf(HitParticle::isDead);
        bullets.forEach(b -> b.update());
        bullets.removeIf(b -> (!b.isActive));
        enemies.forEach(e -> e.update());
        enemies.removeIf(e -> (e.dyingAnimationFinished && !e.isActive));

        player.update();

        checkCollisions();
    }

    void show() {
        pushMatrix();

        float shakeX = random(-shakeAmount, shakeAmount);
        float shakeY = random(-shakeAmount, shakeAmount);
        translate(shakeX, shakeY);
        bg.show();
        
        hitParticles.forEach(p -> p.show());
        bullets.forEach(b -> b.show());
        enemies.forEach(e -> e.show());

        if (player.isActive) {
            player.show();
        }

        popMatrix();
        
        // Muestra un destello blanco antes de la aparición del BOSS
        if (flashActive) {
            fill(255);
            rect(0, 0, WIDTH, HEIGHT);

            --flashTimer;
            if (flashTimer <= 0) {
                flashActive = false;
            }
        }

        if (isBossActive) {
            drawBossHealthBar(bossRef);
        }

        drawScore();
        drawWarning();

        if (hudFlashing) {
            --hudTimer;
            if (hudTimer <= 0) {
                hudTimer = 0;
                hudFlashing = false;
            }
            if (frameCount % 30 < 15) {
                return;
            }
        }
        
        drawPlayerHealthBar();
    }

    // ========== Verifica y opera con el estado del juego ==========

    private void updateLevel() {

        if (currentEvent >= events.size()) {
            return;
        }

        LevelEvent e = events.get(currentEvent);

        if (e.waitClear && !enemies.isEmpty()) {
            return;
        }

        ++eventTimer;

        if (eventTimer >= e.delay) {
            e.execute();
            
            eventTimer = 0;
            ++currentEvent;
        }
    }



    PVector getPlayerPosition() {
        return player.position;
    }

    void buildLevel() {
        events.add(new LevelEvent(0, () -> gs.playBgmStage()));
        events.add(new LevelEvent(0, () -> player.startSpawnAnimation()));

        waitClear(180);

        events.add(new LevelEvent(0, () -> spawnLine(4)));
        events.add(new LevelEvent(80, () -> spawnLine(3)));
        events.add(new LevelEvent(80, () -> spawnLine(4)));

        events.add(new LevelEvent(100, () -> spawnFastSwarm(2)));

        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(80, () -> spawnLine(3)));
        events.add(new LevelEvent(80, () -> spawnLine(4)));

        events.add(new LevelEvent(100, () -> spawnFastSwarm(2)));

        waitClear();

        events.add(new LevelEvent(50, () -> spawnFastPair()));
        events.add(new LevelEvent(60, () -> spawnLine(1)));
        events.add(new LevelEvent(40, () -> spawnLine(2)));
        events.add(new LevelEvent(40, () -> spawnLine(3)));
        events.add(new LevelEvent(40, () -> spawnLine(4)));
        events.add(new LevelEvent(40, () -> spawnLine(5)));

        waitClear();

        events.add(new LevelEvent(60, () -> spawnLine(5)));
        events.add(new LevelEvent(40, () -> spawnLine(4)));
        events.add(new LevelEvent(40, () -> spawnLine(3)));
        events.add(new LevelEvent(40, () -> spawnLine(2)));
        events.add(new LevelEvent(40, () -> spawnLine(1)));
        events.add(new LevelEvent(50, () -> spawnFastPair()));

        waitClear();

        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(60, () -> spawnLine(3)));
        events.add(new LevelEvent(120, () -> spawnFastPair()));
        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(60, () -> spawnLine(3)));

        
        events.add(new LevelEvent(100, () -> spawnFastPairLeft()));
        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(100, () -> spawnFastPairRight()));
        
        events.add(new LevelEvent(60, () -> spawnTank(WIDTH * 0.5)));
        
        events.add(new LevelEvent(100, () -> spawnFastPairLeft()));
        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(100, () -> spawnFastPairRight()));

        waitClear();

        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(60, () -> spawnLine(3)));
        events.add(new LevelEvent(90, () -> spawnFastPair()));
        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(60, () -> spawnLine(3)));
        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(60, () -> spawnLine(3)));
        events.add(new LevelEvent(90, () -> spawnFastPair()));
        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(60, () -> spawnLine(3)));

        waitClear();

        events.add(new LevelEvent(60, () -> spawnTank(WIDTH * 0.25)));
        events.add(new LevelEvent(0, () -> spawnTank(WIDTH * 0.75)));
        events.add(new LevelEvent(120, () -> spawnLine(4)));
        events.add(new LevelEvent(360, () -> spawnFastSwarm(2)));
        events.add(new LevelEvent(360, () -> spawnFastSwarm(2)));
        events.add(new LevelEvent(120, () -> spawnLine(4)));
        events.add(new LevelEvent(360, () -> spawnFastSwarm(2)));
        events.add(new LevelEvent(360, () -> spawnFastSwarm(2)));

        waitClear();

        events.add(new LevelEvent(60, () -> spawnLine(4)));

        events.add(new LevelEvent(60, () -> spawnBasicAt(WIDTH*0.2)));
        events.add(new LevelEvent(12, () -> spawnBasicAt(WIDTH*0.35)));
        events.add(new LevelEvent(12, () -> spawnBasicAt(WIDTH*0.5)));
        events.add(new LevelEvent(12, () -> spawnBasicAt(WIDTH*0.65)));
        events.add(new LevelEvent(12, () -> spawnBasicAt(WIDTH*0.8)));
        events.add(new LevelEvent(120, () -> spawnFastPair()));

        events.add(new LevelEvent(60, () -> spawnBasicAt(WIDTH*0.8)));
        events.add(new LevelEvent(12, () -> spawnBasicAt(WIDTH*0.65)));
        events.add(new LevelEvent(12, () -> spawnBasicAt(WIDTH*0.5)));
        events.add(new LevelEvent(12, () -> spawnBasicAt(WIDTH*0.35)));
        events.add(new LevelEvent(12, () -> spawnBasicAt(WIDTH*0.2)));
        events.add(new LevelEvent(120, () -> spawnFastPair()));

        waitClear();

        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(60, () -> spawnLine(8)));
        events.add(new LevelEvent(60, () -> spawnLine(7)));
        events.add(new LevelEvent(60, () -> spawnLine(8)));
        events.add(new LevelEvent(60, () -> spawnLine(7)));
        events.add(new LevelEvent(60, () -> spawnLine(4)));
        events.add(new LevelEvent(60, () -> spawnLine(8)));
        events.add(new LevelEvent(60, () -> spawnLine(7)));
        events.add(new LevelEvent(60, () -> spawnLine(8)));
        events.add(new LevelEvent(60, () -> spawnLine(7)));

        waitClear();

        events.add(new LevelEvent(100, () -> gs.fadeOut(gs.getStageLoop(), 0.005)));
        events.add(new LevelEvent(240, () -> triggerBossWarning()));
        events.add(new LevelEvent(0, () -> gs.playSfxAlarm()));

        waitClear();

        events.add(new LevelEvent(240, () -> triggerFlashHealthBar()));
        events.add(new LevelEvent(0, () -> recoverPlayerHealth()));

        events.add(new LevelEvent(120, () -> gs.playBgmBoss()));

        waitClear(240);

        events.add(new LevelEvent(180, () -> spawnBoss()));

        waitClear(180);

        events.add(new LevelEvent(60, () -> gs.fadeOut(gs.getBossLoop(), 0.005)));
        events.add(new LevelEvent(0, () -> player.startDespawnAnimation()));

        events.add(new LevelEvent(200, () -> gm.setGameState(GameState.VICTORY)));
    }

    private void spawnBasicAt(float x) {
        enemies.add(new Enemy(this, x, -20, EnemyType.BASIC));
    }

    /**
    Genera una línea de enemigos BASIC espacidos uniformemente en el ancho de pantalla
    */
    private void spawnLine(int count) {
        float spacing = WIDTH / (count + 1);

        for (int i = 1; i <= count; ++i) {
            enemies.add(new Enemy(this, spacing * i, -20, EnemyType.BASIC));
        }
    }

    private void spawnFastPair() {
        enemies.add(new Enemy(this, random(50, WIDTH / 2), - 20, EnemyType.FAST));
        enemies.add(new Enemy(this, random(WIDTH / 2, WIDTH - 50), -20, EnemyType.FAST));
    }

    
    private void spawnFastPairLeft() {
        enemies.add(new Enemy(this, WIDTH * 0.2, -20, EnemyType.FAST));
        enemies.add(new Enemy(this, WIDTH * 0.4, -20, EnemyType.FAST));
    }

    private void spawnFastPairRight() {
        enemies.add(new Enemy(this, WIDTH * 0.6, -20, EnemyType.FAST));
        enemies.add(new Enemy(this, WIDTH * 0.8, -20, EnemyType.FAST));
    }

    private void spawnTank(float x) {
        enemies.add(new Enemy(this, x, -40, EnemyType.TANK));
    }

    private void spawnFastSwarm(int count) {
        for (int i = 0; i < count; i++) {
            enemies.add(new Enemy(this, random(40, WIDTH - 40), -20, EnemyType.FAST));
        }
    }

    private void spawnBoss() {
        enemies.add(new Enemy(this, WIDTH / 2, -100, EnemyType.BOSS));
    }

    private void waitClear() {
        events.add(new LevelEvent(0, () -> {}, true));
    }

    private void waitClear(int delay) {
        events.add(new LevelEvent(delay, () -> {}, true));
    }
    // ==============================================================

    // ========== Lógica de juego ==========
    public void addBullet(float x, float y, PVector velocity, BulletType type) {
        bullets.add(new Bullet(x, y, velocity, type));
    }

    private void recoverPlayerHealth() {
        player.health = player.maxHealth;
        gs.playSfxRecovery();

    }

    /**
    Verifica colisiones que existen entre las balas del jugador y los enemigos,
    y entre las balas enemigas y el jugador
    */
    private void checkCollisions() {

        for (Bullet b : bullets) {

            // Interacción Balas - Enemigos
            if (b.type == BulletType.PLAYER) {
                for (Enemy e : enemies) {
                if (PVector.dist(b.position, e.position) < b.radius + e.radius) {
                        b.isActive = false;
                        addHitParticles(b.position);
                        e.takeDamage(b.damage);
                    if (!e.isActive) {  // En caso de eliminar al enemigo
                        if (e.type == EnemyType.BOSS) {
                            score += 1000;
                        } else if (e.type == EnemyType.TANK) {
                            score += 250;
                        } else {
                            score += 100;
                        }
                    }
                }
                }
            }

            // Interacción Balas - Jugador
            if (!(b.type == BulletType.PLAYER)) {
                if (PVector.dist(player.position, b.position) < player.radius + b.radius) {
                    b.isActive = false;
                    addHitParticles(b.position);
                    player.takeDamage(b.damage);
                }
            }
        } // Terminación del ciclo for

        // Interacción Jugador - Enemigo de tipo FAST (Kamikaze)
        for (Enemy e: enemies) {
            if (e.type == EnemyType.FAST && PVector.dist(player.position, e.position) < player.radius + e.radius) {
                player.takeDamage(2);
                addHitParticles(e.position);
                e.isActive = false;
            }
        }
    }

    private void updateBackground() {
        bg.update();
        if (dirUp) {
            bg.modifyVelocity(2);
        }
        if (dirDown) {
            bg.modifyVelocity(0.5);
        }
        if (!dirUp&& !dirDown) {
            bg.modifyVelocity(1.2);
        }
    }

    void setShakeAmount(float amount) {
        shakeAmount = amount;
    }

    void addHitParticles(PVector position) {
        for (int i = 0; i < round(random(5, 13)); ++i) {
            hitParticles.add(new HitParticle(position));
        }
    }
    // ===============================================

    // ========== Muestra de estadísticas de juego ==========
    void drawScore() {
        textSize(28);
        textAlign(LEFT, TOP);
        String scoreText = nf(score, 6);
        fill(255);
        text("Score: " + scoreText, 20, 20);
    }

    void drawPlayerHealthBar() {
        float barWidth = 200;
        float barHeight = 20;
        float posX = 20;
        float posY = HEIGHT - 40;

        float healthRadio = (float) player.health / player.maxHealth;

        // Borde blanco para la barra de salud
        stroke(255);
        noFill();
        rect(posX, posY, barWidth, barHeight);

        noStroke();

        // Cambia el color de la barra dependiendo de la salud restante
        if (healthRadio > 0.5) {
            fill(83, 200, 114); // Color verde
        } else if (healthRadio > 0.25) {
            fill(240, 123, 60); // Color naranja
        } else {
            fill(200, 83, 83);  // Color rojo
        }

        rect(posX + 1, posY + 1, barWidth * healthRadio - 1, barHeight - 1);
    }

    private void triggerFlashHealthBar() {
        hudFlashing = true;
        hudTimer = 120;
    }

    private void drawBossHealthBar(Enemy boss) {

        float barWidth = 400;
        float barHeight = 20;
        float posX = (WIDTH - barWidth) / 2;
        float posY = 20;

        float healthRadio = (float) boss.health / boss.maxHealth;

        // Borde blanco para la barra de salud
        stroke(255);
        noFill();
        rect(posX, posY, barWidth, barHeight);

        noStroke();

        // Cambia el color de la barra dependiendo de la salud restante
        if (healthRadio > 0.5) {
            fill(83, 200, 114); // Color verde
        } else if (healthRadio > 0.25) {
            fill(240, 123, 60); // Color naranja
        } else {
            fill(200, 83, 83);  // Color rojo
        }

        rect(posX + 1, posY + 1, barWidth * healthRadio - 1, barHeight - 1);
    }

    private void triggerBossWarning() {
        warningActive = true;
        warningTimer = 180;

        flashActive = true;
        flashTimer = 12;
    }

    private void drawWarning() {
        if (!warningActive) {
            return;
        }

        fill(255, 0, 0);
        textAlign(CENTER);
        textSize(60);
        
        if (frameCount % 30 < 20) {
            text("WARNING", WIDTH / 2, HEIGHT / 2);
        }

        --warningTimer;
        if (warningTimer <= 0) {
            warningActive = false;
        }
    }
    // ========================================================
}

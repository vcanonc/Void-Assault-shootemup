static final int WIDTH = 1024;
static final int HEIGHT = 768;

boolean dirUp = false;
boolean dirDown = false;
boolean dirLeft = false;
boolean dirRight = false;
boolean shooting = false;

PFont gameFont;
PImage titleBarIcon;

GameManager gm;
PatternShooter ps;
GameSound gs;

// Enemies sprites
PImage propulsionEnemySprite;
PImage propulsionBossSprite;
PImage explosionSprite;

PImage basicEnemySprite;
PImage fastEnemySprite;
PImage tankEnemySprite;
PImage bossEnemySprite;

// Bullets sprites
PImage playerBullet;
PImage basicEnemyBullet;
PImage tankBullet;
PImage bossBullet;
PImage boss2Bullet;

void setup() {
    frameRate(60);
    size(1024, 768);
    titleBarIcon = loadImage("data/myicon.png");
    surface.setIcon(titleBarIcon);
    windowTitle("Void Assault");

    imageMode(CENTER);
    
    propulsionEnemySprite = loadImage("images/propulsion_enemy.png");
    propulsionBossSprite = loadImage("images/propulsion_boss.png");
    explosionSprite = loadImage("images/explosion.png");

    basicEnemySprite = loadImage("images/basic_enemy.png");
    fastEnemySprite = loadImage("images/fast_enemy.png");
    tankEnemySprite = loadImage("images/tank_enemy.png");
    bossEnemySprite = loadImage("images/boss_enemy.png");

    playerBullet = loadImage("images/blue_bullet.png");
    basicEnemyBullet = loadImage("images/orange_bullet.png");
    tankBullet = loadImage("images/pink_bullet.png");
    bossBullet = loadImage("images/white_bullet.png");
    boss2Bullet = loadImage("images/red_bullet.png");

    gameFont = createFont("font/m6x11.ttf", 64);
    textFont(gameFont);

    gs = new GameSound(this);
    gm = new GameManager();
}

void draw() {
    background(0);
    gm.update();
    gm.show();
}

void keyPressed() {

    if (gm.getGameState() == GameState.MENU) {
        if (keyCode == ' ') {
            gm.startGame();
        }
    }

    if (gm.getGameState() == GameState.GAME_OVER && keyCode == ' ') {
        gm.startGame();
    }

    if (gm.getGameState() == GameState.VICTORY && keyCode == ' ') {
        gm.setGameState(GameState.MENU);
    }

    if (gm.getGameState() == GameState.PLAYING) {
        switch(keyCode) {
            case UP:
                dirUp = true;
                break;
            case DOWN:
                dirDown = true;
                break;
            case LEFT:
                dirLeft = true;
                break;
            case RIGHT:
                dirRight = true;
                break;
            case ' ':
                shooting = true;
                break;
        }
    }

    if (key == 'p' || key == 'P') {
        if (gm.getGameState() == GameState.PLAYING) {
            gm.setGameState(GameState.PAUSE);
            gs.pauseMusic();
        } else if (gm.getGameState() == GameState.PAUSE) {
            gm.setGameState(GameState.PLAYING);
            gs.resumeMusic();
        }
    }
}

void keyReleased() {
    switch(keyCode) {
        case UP:
            dirUp = false;
            break;
        case DOWN:
            dirDown = false;
            break;
        case LEFT:
            dirLeft = false;
            break;
        case RIGHT:
            dirRight = false;
            break;
        case ' ':
            shooting = false;
            break;
    }
}

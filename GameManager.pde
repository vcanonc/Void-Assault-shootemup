enum GameState {
    MENU,
    PLAYING,
    PAUSE,
    GAME_OVER,
    VICTORY
}

class GameManager {

    private GameState state;
    private Game game;
    private Background bg;
    private int highScore;
    private boolean newHighScore;

    GameManager() {
        state = GameState.MENU;
        bg = new Background();
        newHighScore = false;
        loadHighScore();
    }

    void startGame() {
        game = new Game();
        newHighScore = false;
        state = GameState.PLAYING;
    }
    
    private void loadHighScore() {
        String[] lines = loadStrings("data/highscore.txt");
        
        if (lines != null && lines.length > 0) {
            highScore = int(lines[0]);
        }
    }
    
    private void saveHighScore() {
        String[] lines = {str(highScore)};
        saveStrings("data/highscore.txt", lines);
    }

    GameState getGameState() {
        return state;
    }

    void setGameState(GameState state) {
        this.state = state;
        if (state == GameState.GAME_OVER || state == GameState.VICTORY) {
            if (highScore < game.score) {
                highScore = game.score;
                newHighScore = true;
                saveHighScore();
            }
        }
    }

    void update() {
        if (state == GameState.MENU) {
            bg.update();
        }
        
        if (state == GameState.PLAYING) {
            game.update();
        }
    }

    void show() {
        switch(state) {

            case MENU:
                drawMenu();
                break;
            
            case PLAYING:
                game.show();
                break;
            
            case PAUSE:
                game.show();
                drawPause();
                break;
            
            case GAME_OVER:
                game.show();
                drawGameOver();
                gs.stopAllBgm();
                break;
            
            case VICTORY:
                game.show();
                drawVictory();
                break;

        }
    }

    void drawMenu() {
        bg.show();

        fill(255);
        textAlign(CENTER);

        float s = 85 + sin(frameCount * 0.1) * 2;
        textSize(s);
        text("VOID ASSAULT", WIDTH / 2, HEIGHT / 3);
        
        textSize(20);
        text("HIGH SCORE: " + nf(highScore, 6), WIDTH/2, HEIGHT * 0.45);
        
        textSize(30);
        if (frameCount % 60 < 30) {
            text("PRESS SPACE TO START", WIDTH / 2, HEIGHT / 2);
        }

        fill(255);
        textSize(16);
        text("By Vicecamo", WIDTH / 2, HEIGHT - 40);
    }

    void drawGameOver() {

        fill(0, 180);
        rectMode(CORNER);
        rect(0, 0, WIDTH, HEIGHT);

        fill(200, 83, 83);
        textAlign(CENTER);

        textSize(80);
        text("GAME OVER", WIDTH / 2, HEIGHT / 2);
        
        
        if (newHighScore) {
            float s = 20 + sin(frameCount * 0.1) * 2;
            textSize(s);
            text("¡NEW HIGH SCORE! : " + nf(game.score, 6), WIDTH/2, HEIGHT * 0.55);
        } else {
            textSize(20);
            text("YOUR SCORE: " + nf(game.score, 6), WIDTH/2, HEIGHT * 0.55);
        }
        

        textSize(30);
        if (frameCount % 60 < 30) {
            text("PRESS SPACE TO RESTART", WIDTH / 2, HEIGHT / 2 + 120);
        }
    }

    void drawPause() {

        fill(0, 180);
        rectMode(CORNER);
        rect(0, 0, WIDTH, HEIGHT);

        textAlign(CENTER);

        fill(255);
        textSize(80);
        text("PAUSE", WIDTH / 2, HEIGHT / 2);

        textSize(28);

        if (frameCount % 60 < 30) {
            text("PRESS P TO CONTINUE", WIDTH / 2, HEIGHT / 2 + 120);
        }
    }

    void drawVictory() {

        fill(0, 200);
        rectMode(CORNER);
        rect(0, 0, WIDTH, HEIGHT);

        textAlign(CENTER);

        fill(83, 200, 114);
        textSize(80);
        text("YOU WIN", WIDTH / 2, HEIGHT / 2);
        
        textSize(20);
        text("YOUR SCORE: " + nf(game.score, 6), WIDTH/2, HEIGHT*0.55);

        textSize(28);
        if (frameCount % 60 < 30) {
            text("PRESS SPACE TO CONTINUE", WIDTH / 2, HEIGHT / 2 + 120);
        }
    }
}

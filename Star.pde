class Star {

    float x;
    float y;
    float speed;
    float size;
    boolean isActive;

    Star(float x, float y, float speed, float size) {
        this.x = x;
        this.y = y;
        this.speed = speed;
        this.size = size;
    }

    void update(float multiplier) {
        y += speed * multiplier;
        
        if (y > HEIGHT) {
            y = 0;
            x = random(WIDTH);
        }
    }

    void show() {
        noStroke();
        fill(255);
        circle(x, y, size);
    }
}

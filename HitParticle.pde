class HitParticle {
    
    PVector position;
    PVector velocity;
    int lifespan;

    HitParticle(PVector pos) {
        position = pos.copy();
        velocity = PVector.random2D().mult(random(1, 3));
        lifespan = round(random(25, 40));
    }

    void update() {
        position.add(velocity);
        --lifespan;
    }

    void show() {
        noStroke();
        fill(255, 200, 200, lifespan * 10);
        circle(position.x, position.y, round(random(3, 5)));
    }

    boolean isDead() {
        return lifespan <= 0;
    }
}

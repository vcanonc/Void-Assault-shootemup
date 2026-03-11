
class Background {

    private List<Star> farStars;
    private List<Star> midStars;
    private List<Star> nearStars;
    private float speedMultiplier;

    Background() {
        farStars = new ArrayList();
        midStars = new ArrayList();
        nearStars = new ArrayList();
        speedMultiplier = 1.0;

        for (int i = 0; i < 60; ++i) {
            farStars.add(new Star(random(WIDTH), random(HEIGHT), 0.5, 1));
        }

        for (int i = 0; i < 40; ++i) {
            midStars.add(new Star(random(WIDTH), random(HEIGHT), 1.2, 2));
        }

        for (int i = 0; i < 20; ++i) {
            nearStars.add(new Star(random(WIDTH), random(HEIGHT), 2, 4));
        }
        
    }

    void update() {
        farStars.forEach(s -> s.update(speedMultiplier));
        midStars.forEach(s -> s.update(speedMultiplier));
        nearStars.forEach(s -> s.update(speedMultiplier));
    }

    void show() {
        fill(0);
        rect(0, 0, WIDTH, HEIGHT);
        farStars.forEach(s -> s.show());
        midStars.forEach(s -> s.show());
        nearStars.forEach(s -> s.show());
    }

    void modifyVelocity(float multiplier) {
        speedMultiplier = multiplier;
    }
}
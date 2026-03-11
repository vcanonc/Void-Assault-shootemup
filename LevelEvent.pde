class LevelEvent {

    int delay;          // Tiempo a esperar desde el evento anterior
    boolean waitClear;  // Indica si debe esperar a que se limpie la pantalla
    Runnable action;

    LevelEvent(int delay, Runnable action) {
        this.delay = delay;
        this.action = action;
        waitClear = false;
    }

    LevelEvent(int delay, Runnable action, boolean waitClear) {
        this.delay = delay;
        this.action = action;
        this.waitClear = waitClear;
    }

    void execute() {
        action.run();
    }

}

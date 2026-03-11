import processing.sound.*;

static final float BGM_VOLUME = 0.4;
static final float SFX_VOLUME = 1.0;

class GameSound {

    private List<SoundFile> sfxExplosion;
    private List<SoundFile> sfxHit;
    private List<SoundFile> sfxShot;
    private SoundFile sfxScan;
    private SoundFile sfxRecovery;
    private SoundFile sfxAlarm;

    private SoundFile bgmStageIntro;
    private SoundFile bgmStageLoop;
    private SoundFile bgmBossIntro;
    private SoundFile bgmBossLoop;

    private SoundFile currentIntro;
    private SoundFile currentLoop;

    private boolean transitioning;
    private SoundFile fadingSound;
    private float fadeVolume;
    private float fadeSpeed;
    private boolean fading;
    
    GameSound(PApplet parent) {
        initSfxSounds(parent);
        initBgmSounds(parent);
        transitioning = false;
    }

    private void initSfxSounds(PApplet parent) {
        sfxExplosion = new ArrayList();
        sfxHit = new ArrayList();
        sfxShot = new ArrayList();

        // Inicializando todos los sonidos de explosión
        for (int i = 0; i < 8; ++i) {
            sfxExplosion.add(new SoundFile(parent, "audio/sfx/sfx_explosion" + i + ".wav"));
        }

        for (int i = 0; i < 3; ++i) {
            sfxHit.add(new SoundFile(parent, "audio/sfx/sfx_hit" + i + ".wav"));
        }

        for (int i = 0; i < 3; ++i) {
            sfxShot.add(new SoundFile(parent, "audio/sfx/sfx_shot" + i + ".wav"));
        }

        sfxScan = new SoundFile(parent, "audio/sfx/sfx_scan.wav");
        sfxRecovery = new SoundFile(parent, "audio/sfx/sfx_recovery.wav");
        sfxAlarm = new SoundFile(parent, "audio/sfx/sfx_alarm.wav");
    }

    private void initBgmSounds(PApplet parent) {
        bgmStageIntro = new SoundFile(parent, "audio/bgm/bgm_stage_intro.wav");
        bgmStageLoop = new SoundFile(parent, "audio/bgm/bgm_stage_loop.wav");
        bgmBossIntro = new SoundFile(parent, "audio/bgm/bgm_boss_intro.wav");
        bgmBossLoop = new SoundFile(parent, "audio/bgm/bgm_boss_loop.wav");

        bgmStageIntro.amp(BGM_VOLUME);
        bgmStageLoop.amp(BGM_VOLUME);
        bgmBossIntro.amp(BGM_VOLUME);
        bgmBossLoop.amp(BGM_VOLUME);
    }

    /**
    Reproduce un sonido de explosión de los disponibles al azar
    */
    void playSfxExplosion() {
        int i = floor(random(0, sfxExplosion.size()));
        sfxExplosion.get(i).amp(SFX_VOLUME);
        sfxExplosion.get(i).play();
    }

    /**
    Reproduce un sonido de golpe de los disponibles al azar
    */
    void playSfxHit() {
        int i = floor(random(0, sfxHit.size()));
        sfxHit.get(i).amp(SFX_VOLUME);
        sfxHit.get(i).play();
    }

    /**
    Sonido de disparo de los disponibles al azar
    */
    void playSfxShot() {
        int i = floor(random(0, sfxShot.size()));
        sfxShot.get(i).amp(SFX_VOLUME);
        sfxShot.get(i).play();
    }

    /**
    Sonido especial de los enemigos FAST
    */
    void playSfxScan() {
        if (!sfxScan.isPlaying()) {
            sfxScan.amp(SFX_VOLUME);
            sfxScan.play();
        }
    }

    /**
    Reproduce un sonido especial para cuando se recupera vida
    */
    void playSfxRecovery() {
        sfxRecovery.amp(SFX_VOLUME);
        sfxRecovery.play();
    }

    /**
    Reproduce un sonido especial para una alarma
    */
    void playSfxAlarm() {
        sfxAlarm.amp(SFX_VOLUME);
        sfxAlarm.play();
    }

    void updateMusic() {
        if (transitioning && currentIntro != null) {

            if (!currentIntro.isPlaying()) {

                transitioning = false;
                currentIntro = null;

                if (currentLoop != null) {
                    currentLoop.loop();
                }
            }
        }

        if (fading && fadingSound != null) {

            fadeVolume -= fadeSpeed;

            if (fadeVolume <= 0) {
                fadeVolume = 0;
                fadingSound.stop();
                fading = false;
            }

            fadingSound.amp(fadeVolume);
        }
    }

    void stopAllBgm() {
        if (bgmStageIntro.isPlaying()) {
            bgmStageIntro.stop();
        }
        if (bgmStageLoop.isPlaying()) {
            bgmStageLoop.stop();
        }
        if (bgmBossIntro.isPlaying()) {
            bgmBossIntro.stop();
        }
        if (bgmBossLoop.isPlaying()) {
            bgmBossLoop.stop();
        }
    }

    void playBgmStage() {
        stopAllBgm();

        currentIntro = bgmStageIntro;
        currentLoop = bgmStageLoop;
        transitioning = true;

        currentIntro.play();
    }

    void playBgmBoss() {
        stopAllBgm();

        currentIntro = bgmBossIntro;
        currentLoop = bgmBossLoop;
        transitioning = true;

        currentIntro.play();
    }

    void fadeOut(SoundFile sound, float speed) {
        fadingSound = sound;
        fadeVolume = BGM_VOLUME;
        fadeSpeed = speed;
        fading = true;
    }

    SoundFile getStageLoop() {
        return bgmStageLoop;
    }

    SoundFile getBossLoop() {
        return bgmBossLoop;
    }

    void pauseMusic() {

        if (bgmStageIntro.isPlaying()) {
            bgmStageIntro.pause();
        }

        if (bgmStageLoop.isPlaying()) {
            bgmStageLoop.pause();
        }

        if (bgmBossIntro.isPlaying()) {
            bgmBossIntro.pause();
        }

        if (bgmBossLoop.isPlaying()) {
            bgmBossLoop.pause();
        }
    }

    void resumeMusic() {
        
        if (bgmStageIntro.position() > 0 && !bgmStageIntro.isPlaying()) {
            bgmStageIntro.play();
        }
        
        if (bgmStageLoop.position() > 0 && !bgmStageLoop.isPlaying()) {
            bgmStageLoop.loop();
        }
        
        if (bgmBossIntro.position() > 0 && !bgmBossIntro.isPlaying()) {
            bgmBossIntro.play();
        }
        
        if (bgmBossLoop.position() > 0 && !bgmBossLoop.isPlaying()) {
            bgmBossLoop.loop();
        }

    }
}
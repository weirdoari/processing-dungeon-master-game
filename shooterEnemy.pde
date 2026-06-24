class ShooterEnemy extends Enemy {
  int shootCooldown = 1500;
  int lastShotTime = 0;
  Gif alertedGif;
  boolean usingAlerted = false;

  ShooterEnemy(float x, float y, float w, float h, int health, PApplet sketch) {
    this(x, y, w, h, health, sketch, false);
  }

  ShooterEnemy(float x, float y, float w, float h, int health, PApplet sketch, boolean stickToBlocks) {
    this(x, y, w, h, health, sketch, "data/shooterEnemy_idle.gif", "data/shooterEnemy_alerted.gif", stickToBlocks);
  }

  ShooterEnemy(float x, float y, float w, float h, int health, PApplet sketch, String idleGifPath, String alertedGifPath, boolean stickToBlocks) {
    super(x, y, w, h, health, sketch, idleGifPath, stickToBlocks);
    alertedGif = new Gif(sketch, alertedGifPath);
    alertedGif.loop();
    speed = 1.5; // Adjust speed for shooter enemy
  }

  @Override
  void update(Player player) {
    super.update(player);

    if (shouldBeAlerted(player, 800, 400)) {
      alerted = true;
    } else {
      alerted = false;
    }

    // Check if player is close and on similar y level
    if (alerted && millis() - lastShotTime > shootCooldown && !stunned) {
      float dir = player.x + player.w/2 < x + w/2 ? -1 : 1;
      float px = x + w/2;
      float py = y + h/5*4;
      // Only add one projectile per cooldown
      projectiles.add(new Projectile(px, py, dir * 6, 0, 20, true, color(0, 255, 0))); // Green projectile for enemy
      lastShotTime = millis();
    }
    
    drawHealthBar();
    
    // Update damage texts for ShooterEnemy too
    updateDamageTexts();
  }

  @Override
  void draw(Player player) {
    pushMatrix();

    Gif toDraw = alerted ? alertedGif : myGif;
    translate(x + w / 2, y + h / 2);

    if (player.x > x) {
      scale(-1, 1);
      image(toDraw, -w / 2, -h/2.5, w, h);
    } else {
      image(toDraw, -w / 2, -h/2.5, w, h);
    }

    popMatrix();
    drawDamageTexts();
  }
}

class DamageText {
  float x, y;
  int damage;
  int startTime;
  int duration = 60; // 1 second at 60fps
  float vy = -1; // Float upward
  
  DamageText(float x, float y, int damage) {
    this.x = x;
    this.y = y;
    this.damage = damage;
    this.startTime = millis();
  }
  
  void update() {
    y += vy; // Move upward
  }
  
  void draw() {
    int elapsed = millis() - startTime;
    float alpha = map(elapsed, 0, duration * 16.67, 255, 0); // Fade out over duration
    
    pushStyle();
    fill(255, 100, 100, alpha); // Red color with fading alpha
    textAlign(CENTER, CENTER);
    textSize(20);
    text("-" + damage, x, y);
    popStyle();
  }
  
  boolean shouldRemove() {
    return millis() - startTime > duration * 16.67; // Remove after duration
  }
}
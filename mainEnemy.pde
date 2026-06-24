class Enemy {
  float x, y, w, h;
  float speed = 1.0;
  float vy = 0; 
  boolean onGround = false;
  int health,initialHealth;
  Gif myGif;
  int lastHitTime = 0;
  int hitCooldown = 1000; 
  boolean stunned = false;
  int stunDuration = 600;
  int stunnedAt = 0;
  boolean facingLeft = true;
  boolean deadHandled = false;
  boolean alerted = false; 
  boolean stickToBlocks = false;
  Block currentBlock = null;
  int damage = 10;
  
  // Damage display variables
  ArrayList<DamageText> damageTexts = new ArrayList<DamageText>();

  Enemy(float x, float y, float w, float h, int health, PApplet sketch) {
    this(x, y, w, h, health, sketch, false);
  }

  Enemy(float x, float y, float w, float h, int health, PApplet sketch, boolean stickToBlocks) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.health = health;
    this.initialHealth = health;
    this.stickToBlocks = stickToBlocks;
    myGif = new Gif(sketch, "data/enemy_GIF.gif");
    myGif.loop();
  }

  Enemy(float x, float y, float w, float h, int health, PApplet sketch, String gifPath) {
    this(x, y, w, h, health, sketch, gifPath, false);
  }

  Enemy(float x, float y, float w, float h, int health, PApplet sketch, String gifPath, boolean stickToBlocks) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.health = health;
    this.initialHealth = health;
    this.stickToBlocks = stickToBlocks;
    myGif = new Gif(sketch, gifPath);
    myGif.loop();
  }

  void update(Player player) {
    vy += 0.5;
    y += vy;
    onGround = false;
    currentBlock = null;
    
    for (Block b : rects) {
      // Skip passable blocks - enemies should fall through them
      if (b.passable) continue;
      
      if (y + h > b.y && y < b.y + b.h &&
          x + w > b.x && x < b.x + b.w) {
        y = b.y - h;
        vy = 0;
        onGround = true;
        currentBlock = b;
        break;
      }
    }

    if (stunned) {
      if (millis() - stunnedAt > stunDuration) {
        stunned = false;
        speed = abs(speed); 
      } else {
        if (stickToBlocks && currentBlock != null) {
          float intendedX = x + speed;
          if (canMoveToPosition(intendedX)) {
            x = intendedX;
          }
        } else {
          x += speed;
        }
        return;
      }
    }

    if (shouldBeAlerted(player, 600, 200)) {
      alerted = true;
    } else {
      alerted = false;
    }

    if (!alerted) {return;}

    float intendedX = x;
    if (player.x < x) {
      intendedX = x - speed;
    } else if (player.x > x) {
      intendedX = x + speed;
    }

    if (stickToBlocks && currentBlock != null) {
      if (canMoveToPosition(intendedX)) {
        x = intendedX;
      }
    } else {
      x = intendedX;
    }

    if (enemyCollision(this, player) && millis() - lastHitTime > hitCooldown) {
      player.hit(5);

      speed = -abs(speed); 
      stunned = true;
      stunnedAt = millis();
      lastHitTime = millis();
    }

    facingLeft = speed < 0;
    
    // Update damage texts
    updateDamageTexts();
  }

  boolean canMoveToPosition(float newX) {
    if (currentBlock == null) return true;
    
    float leftEdge = newX;
    float rightEdge = newX + w;
    
    return (leftEdge >= currentBlock.x && rightEdge <= currentBlock.x + currentBlock.w);
  }

  void draw(Player player) {
    pushMatrix();
    translate(x + w / 2, y + h / 2);

    if (player.x < x) {
      scale(-1, 1);
      image(myGif, -w / 2 - 50, -h / 2 - 45, w + 100, h + 50);
    } else {
      image(myGif, -w / 2 - 50, -h / 2 - 45, w + 100, h + 50);
    }
    popMatrix();

    drawHealthBar();
    drawDamageTexts();
  }

  void drawHealthBar() {
    pushStyle();
    fill(255, 0, 0);
    rect(x, y - 50, w, 5);
    fill(0, 255, 0);
    float healthWidth = map(health, 0, initialHealth, 0, w);
    rect(x, y - 50, healthWidth, 5);
    popStyle();
  }

  boolean shouldBeAlerted(Player player, float distThresh, float yThresh) {
    float distance = abs((x + w/2) - (player.x + player.w/2));
    float yDiff = abs((y + h/2) - (player.y + player.h/2));
    return (distance < distThresh && yDiff < yThresh);
  }
  
  void takeDamage(int damageAmount) {
    health -= damageAmount;
    // Create floating damage text
    damageTexts.add(new DamageText(x + w/2, y - 10, damageAmount));
  }
  
  void updateDamageTexts() {
    for (int i = damageTexts.size() - 1; i >= 0; i--) {
      DamageText dt = damageTexts.get(i);
      dt.update();
      if (dt.shouldRemove()) {
        damageTexts.remove(i);
      }
    }
  }
  
  void drawDamageTexts() {
    for (DamageText dt : damageTexts) {
      dt.draw();
    }
  }
}

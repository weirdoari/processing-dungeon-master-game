class Player {
  float x, y, w, h;
  float vx = 0, vy = 0, mana = 100, health = 100;
  boolean onGround = false;
  boolean colliding = false;
  boolean jump = false;
  String anticipate = "FLOOR";
  ArrayList<String> equippedPerks = new ArrayList<String>();
  Gif myGif;
  PImage myChar,myCharAtk;
  int lastLooked = RIGHT;
  int hitTintTimer = 0, attackAnimTimer = 0;
  boolean isTalking = false;
  float strength = 1.5;
  int underWaterTimer = 0, shards = 0;
  boolean inWater = false; // Timer for underwater effect
  
  // Trail effect variables for adrenaline perk
  ArrayList<PVector> trailPositions = new ArrayList<PVector>();
  int maxTrailLength = 8;

  Player(float x, float y, float w, float h, PApplet sketch) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    myGif = new Gif(sketch,"data/mainchar.gif");
    myGif.loop();
    myChar = loadImage("data/mainchar.png");
    myCharAtk = loadImage("data/mainchar_attack.png");
    
    for (int i = 0; i < 3; i++) {
      equippedPerks.add(null);
    }
  }

  void draw() {
    // Draw trail first (behind character) if adrenaline is active
    if (isEquipped("ayna") && health < 50) {
      drawTrail();
    }
    
    pushMatrix(); 
    pushStyle();
    fill(255, 0, 0, 100);
    
    if (leftHeld) {
      lastLooked = LEFT;
    } else if (rightHeld) {
      lastLooked = RIGHT;
    }
  
    if (hitTintTimer > 0) {
      tint(255, 50, 50);  // Red tint
      hitTintTimer--;
    } else {
      noTint();
    }
  
    boolean walking = leftHeld || rightHeld;
    boolean facingLeft = leftHeld || lastLooked == LEFT;
  
    if (attackAnimTimer > 0) {
      attackAnimTimer--; 
    }
  
    if (facingLeft) {
      translate(x + w / 2, y + h / 2); 
      scale(-1, 1);  
  
      if (attackAnimTimer > 0) {
        image(myCharAtk, -w / 2 - 50, -h / 2 - 85, w + 100, h + 100);
      } else if (walking) {
        image(myGif, -w / 2 - 50, -h / 2 - 85, w + 100, h + 100);
      } else {
        image(myChar, -w / 2 - 50, -h / 2 - 85, w + 100, h + 100);
      }
  
    } else {
      translate(x, y); 
  
      if (attackAnimTimer > 0) {
        image(myCharAtk, -50, -85, w + 100, h + 100);
      } else if (walking) {
        image(myGif, -50, -85, w + 100, h + 100);
      } else {
        image(myChar, -50, -85, w + 100, h + 100);
      }
    }
  
    popMatrix();
    popStyle();
  }

  void update() {
    if (health <= 0) {
      gameState = STATE_GAME_OVER;
      return;
    }


    // Check for adrenaline speed boost
    float speedMultiplier = 1.0;
    if (isEquipped("ayna") && health < 50) {
      speedMultiplier = 1.5;
    }

    if (!onGround) {
      vy += 0.3;
      if (leftHeld) vx -= 0.3 * speedMultiplier;
      if (rightHeld) vx += 0.3 * speedMultiplier;
      vx *= 0.95;
    } else {
      vy = 0;
      if (leftHeld) vx -= 1.2 * speedMultiplier;
      if (rightHeld) vx += 1.2 * speedMultiplier;
      if (keyPressed && keyCode == UP && jumpPressed) jump = true;
      if (jump) {
        vy = -10;
        jump = false;
        onGround = false;
      }
      vx *= 0.8;
      if (inWater) {
        vx *= 0.8; // Slow down in water
      }
    }

    y += vy;
    x += vx;

    if (mana < 100) { 
      mana += 0.04; 
      if (isEquipped("kitapkurtu")) {
        mana += 0.06; // Regenerate mana faster if perk is equipped
      }
    }

    if (isEquipped("regen")) {
      if (health < 100) {
        health += 0.02; // Regenerate health if perk is equipped
      }
    }

    if (inWater) {
      underWaterTimer++;
      if (underWaterTimer > 360) {
        health -= 0.1; // Drain health over time if underwater
      }
      if (isEquipped("icgudu")) {
        underWaterTimer = 0; 
        if (health < 100) {
          health += 0.1; 
        }
      }
    } else {
      underWaterTimer = 0; // Reset timer when not underwater
    }
    
    // Update trail positions for adrenaline effect
    updateTrail();
  }
  
  void hit(int damage) {
    health -= damage;
    hitTintTimer = 5; 
    damageSound.rewind(); // Reset sound to beginning
    damageSound.play();   // Then play it
  }

  boolean isEquipped(String perkID) {
    for (String equippedPerk : p.equippedPerks) {
      if (equippedPerk != null && equippedPerk.equals(perkID)) {
        return true;
      }
    }
    return false;
  }
  
  float getTotalStrength() {
    float totalStrength = strength;
    
    // Companion perk: +0.05 strength for each enemy on the level
    if (isEquipped("dost")) {
      int aliveEnemies = 0;
      for (Enemy e : enemies) {
        if (e.health > 0) {
          aliveEnemies++;
        }
      }
      totalStrength += aliveEnemies * 0.05;
    }
    
    return totalStrength;
  }
  
  void updateTrail() {
    // Only update trail if adrenaline is active and player is moving
    if (isEquipped("ayna") && health < 50 && (abs(vx) > 0.5 || abs(vy) > 0.5)) {
      // Add current position to trail
      trailPositions.add(0, new PVector(x + w/2, y + h/2));
      
      // Remove old positions if trail is too long
      while (trailPositions.size() > maxTrailLength) {
        trailPositions.remove(trailPositions.size() - 1);
      }
    } else {
      // Clear trail when adrenaline is not active or not moving
      trailPositions.clear();
    }
  }
  
  void drawTrail() {
    pushStyle();
    noFill();
    
    for (int i = 0; i < trailPositions.size() - 1; i++) {
      PVector pos = trailPositions.get(i);
      PVector nextPos = trailPositions.get(i + 1);
      
      // Calculate alpha based on position in trail (newer = more opaque)
      float alpha = map(i, 0, maxTrailLength - 1, 255, 0);
      
      // Draw trail segments with decreasing opacity and size
      stroke(255, 100, 100, alpha);
      strokeWeight(map(i, 0, maxTrailLength - 1, 8, 2));
      line(pos.x, pos.y, nextPos.x, nextPos.y);
      
      // Add some glow effect
      stroke(255, 200, 200, alpha * 0.3);
      strokeWeight(map(i, 0, maxTrailLength - 1, 15, 5));
      line(pos.x, pos.y, nextPos.x, nextPos.y);
    }
    
    popStyle();
  }
}

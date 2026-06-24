class Door {
  float x, y, w, h;
  int targetLevel;
  boolean isActive;
  PImage doorImage;
  
  Door(float x, float y, float w, float h, int targetLevel) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.targetLevel = targetLevel;
    this.isActive = true;
    // Load door image or use default
    try {
      doorImage = loadImage("data/door.png");
    } catch (Exception e) {
      doorImage = null;
    }
  }
  
  void draw() {
    if (!isActive) return;
    
    pushStyle();
    if (doorImage != null) {
      image(doorImage, x, y, w, h);
    } else {
      // Default door appearance
      fill(139, 69, 19); // Brown
      rect(x, y, w, h);
      fill(255, 215, 0); // Gold handle
      ellipse(x + w - 15, y + h/2, 8, 8);
    }
    popStyle();
  }
  
  boolean isPlayerOn(Player p) {
    return (p.x + p.w > x && p.x < x + w &&
            p.y + p.h > y && p.y < y + h);
  }
  
  boolean isPlayerNear(Player p, float distance) {
    float doorCenterX = x + w/2;
    float doorCenterY = y + h/2;
    float playerCenterX = p.x + p.w/2;
    float playerCenterY = p.y + p.h/2;
    
    float dx = doorCenterX - playerCenterX;
    float dy = doorCenterY - playerCenterY;
    return (dx*dx + dy*dy) < (distance*distance);
  }
  
  void drawPrompt() {
    if (!isActive) return;
    
    pushStyle();
    fill(255, 255, 255, 200);
    rect(x + w/2 - 40, y - 30, 80, 20, 5);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(12);
    text("Press E", x + w/2, y - 20);
    popStyle();
  }
}
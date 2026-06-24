class Projectile {
  float x, y, vx, vy, size;
  boolean active = true;
  boolean isEnemy; // true if fired by enemy, false if by player
  color projectileColor;
  int damage = 10; // Default damage value

  Projectile(float x, float y, float vx, float vy, boolean isEnemy) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.size = 12;
    this.isEnemy = isEnemy;
    this.projectileColor = color(255, 150, 0); // Default orange color

    if (!isEnemy) {
      // Play attack sound for player projectiles
      attackSound.rewind(); // Reset sound to beginning
      attackSound.play();   // Then play it
    } 
  }

  Projectile(float x, float y, float vx, float vy, int size, boolean isEnemy) {
    this(x, y, vx, vy, isEnemy);
    this.size = size;
  }

  Projectile(float x, float y, float vx, float vy, boolean isEnemy, color c) {
    this(x, y, vx, vy, isEnemy);
    this.projectileColor = c;
  }

  Projectile(float x, float y, float vx, float vy, int size, boolean isEnemy, color c) {
    this(x, y, vx, vy, size, isEnemy);
    this.projectileColor = c;
  }

  Projectile(float x, float y, float vx, float vy, int size, boolean isEnemy, color c, int damage) {
    this(x, y, vx, vy, size, isEnemy,c);
    this.damage = damage; // Set custom damage value
  }


  void update() {
    x += vx;
    y += vy;

    // Check block collision only if passableBlocks is false
    for (Block b : rects) {
      // Only collide with non-passable blocks
      if (!b.passable && x < b.x + b.w && x + size > b.x &&
          y < b.y + b.h && y + size > b.y) {
        active = false; // Deactivate on block collision
        return;
      }
    }

    // Camera boundaries
    float camLeft = center.x - origin.x;
    float camRight = center.x - origin.x + width;
    float camTop = center.y - origin.y;
    float camBottom = center.y - origin.y + height;

    // Deactivate if out of camera view
    if (x + size < camLeft || x > camRight || y + size < camTop || y > camBottom) {
      active = false;
    }
  }

  void draw() {
    pushStyle();
    fill(projectileColor);
    circle(x + size / 2, y + size / 2, size);
    popStyle();
  }

  boolean hits(Enemy e) {
    return (x < e.x + e.w && x + size > e.x &&
            y < e.y + e.h && y + size > e.y);
  }

  boolean hits(Player p) {
    //print("Checking collision with player at (" + p.x + ", " + p.y + ")\n Procectile at (" + x + ", " + y + ")\n");
    // Defensive: skip collision if not active
    if (!active) return false;
    return (x < p.x + p.w && x + size > p.x &&
            y < p.y + p.h && y + size > p.y);
  }
}

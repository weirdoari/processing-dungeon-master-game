class collectible {
  float x, y;
  boolean collected = false;
  float speedY = -2;

  collectible(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update(ArrayList<Block> blocks) {
    y += speedY;
    speedY += 0.1; // gravity
  
    for (Block b : blocks) {
      if (b.passable) continue; // Skip passable blocks
      boolean colliding = x > b.x && x < b.x + b.w && y + 25 > b.y && y + 25 < b.y + b.h;
      if (colliding && speedY >= 0) {
        y = b.y - 25;
        speedY = 0;
        break;
      }
    }
  }


  void draw() {
    fill(0, 255, 255);
    ellipse(x, y, 25, 25); 
  }

  boolean isCollected(Player p) {
    return dist(x, y, p.x + p.w / 2, p.y + p.h / 2) < 30;
  }
}

class soulShard extends collectible {
   Gif myGif;
  
  soulShard(float x, float y, PApplet sketch) {
    super(x,y);
    myGif = new Gif(sketch, "data/soul_shard.gif");
    myGif.loop();
  }
  
  void draw() {
    image(myGif, x - 8, y - 8,40,30); 
  }
}

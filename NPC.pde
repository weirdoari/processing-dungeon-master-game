class NPC {
  float x, y, w, h;
  String name;
  String[] dialogue;
  int currentLine = 0;
  boolean isTalking = false;
  boolean finishedTalking = false;
  boolean hasTalked = false; // Track if the NPC has been talked to
  color c;
  PImage img;
  Player player;
  PGraphics[] cachedDialogue;
  boolean dialogueCached = false;

  NPC(float x, float y, float w, float h, String name, String[] dialogue, PImage img, Player p) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.name = name;
    this.dialogue = dialogue;
    this.c = color(180, 180, 255);
    this.img = img;
    this.player = p;
    cacheDialogue();
  }

  void cacheDialogue() {
    cachedDialogue = new PGraphics[dialogue.length];
    for (int i = 0; i < dialogue.length; i++) {
      cachedDialogue[i] = createGraphics(400, 60);
      cachedDialogue[i].beginDraw();
      cachedDialogue[i].background(255, 255, 200, 230);
      cachedDialogue[i].fill(0);
      cachedDialogue[i].textAlign(CENTER, CENTER);
      cachedDialogue[i].textFont(myFont);
      cachedDialogue[i].textSize(16);
      cachedDialogue[i].text(dialogue[i], 200, 30);
      cachedDialogue[i].endDraw();
    }
    dialogueCached = true;
  }

  void draw() {
    pushStyle();
        if (img != null) {
        image(img, x, y, w, h);
        } else {
        fill(c);
        rect(x, y, w, h, 10);
        }
        fill(255);
        textAlign(CENTER, BOTTOM);
        textSize(18);
        text(name, x + w/2, y - 5);
    popStyle();
  }

  boolean isNear(Player p, float dist) {
    float px = p.x + p.w/2;
    float py = p.y + p.h/2;
    float nx = x + w/2;
    float ny = y + h/2;
    return dist(px, py, nx, ny) < dist;
  }

  void startTalking() {
    if (!isTalking && !finishedTalking) {
      isTalking = true;
      currentLine = 0;
      p.isTalking = true;
    } 
  }

  void stopTalking() {
    isTalking = false;
    finishedTalking = false;
    p.isTalking = false;
  }

  void nextLine() {
    if (currentLine < dialogue.length - 1) {
      currentLine++;
    } else {
      isTalking = false;
      p.isTalking = false;
      finishedTalking = true;
    }
  }

  void drawDialogue() {
    if (isTalking && dialogueCached) {
      float boxX = x + w/2 - 200; // Adjust for top-left positioning
      float boxY = y - 70;
      image(cachedDialogue[currentLine], boxX, boxY);
    }
  }
}

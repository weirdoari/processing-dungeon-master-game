import gifAnimation.*; 
import ddf.minim.*;

Player p;
ArrayList<Block> rects = new ArrayList<Block>();
ArrayList<Door> doors = new ArrayList<Door>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<PerkButton> perkButtons = new ArrayList<PerkButton>();
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
ArrayList<soulShard> soulShards = new ArrayList<soulShard>();
ArrayList<Text> texts = new ArrayList<Text>();
ArrayList<NPC> npcs = new ArrayList<NPC>();
ArrayList<Decoration> decorations = new ArrayList<Decoration>();

PFont myFont, myFontOrnaments;
PVector origin, center;
boolean leftHeld = false, rightHeld = false, jumpPressed = false;

AudioPlayer bgLoopSound, damageSound, attackSound, killSound;

final int STATE_GAME = 0;
final int STATE_PERK_SHOP = 1;
final int STATE_START_MENU = 2;
final int STATE_GAME_OVER = 3;
final int STATE_GAME_WON = 4;
int gameState = STATE_START_MENU; // current state tracker
int currentLevel = 1;

int lastFogFrame = -10;
PImage sb,sb_f,lock,healthbar,gb,character,perk_slot,perk_close,perk_bag,ibutton,bubbles;
PGraphics hudLayer, brLayer,sagalt,start_menu,fogLeft,fogRight;
PImage[] levelBackgrounds = new PImage[5]; // Supports levels 1, 2, 3, and 4
PGraphics[] cachedLevelBackgrounds = new PGraphics[5]; // For levels 1, 2, 3, and 4
Minim minim;

void setup() {
  size(1288,747);
  frameRate(60);
  noSmooth();
  cacheImages();

  levelBackgrounds[1] = loadImage("data/level1_bg.png");
  levelBackgrounds[2] = loadImage("data/gameBack_t.png");
  levelBackgrounds[3] = loadImage("data/level3bg.png");
  levelBackgrounds[4] = loadImage("data/level4bg.png");

  minim = new Minim(this);
  bgLoopSound = minim.loadFile("data/loop.mp3");
  bgLoopSound.setGain(-15);
  damageSound = minim.loadFile("data/damage.mp3");
  damageSound.setGain(-15);
  attackSound = minim.loadFile("data/attack.mp3");
  killSound = minim.loadFile("data/killed.wav");

  // Cache backgrounds as PGraphics for fast blitting
  for (int i = 1; i <= 4; i++) {
    if (levelBackgrounds[i] != null) {
      cachedLevelBackgrounds[i] = createGraphics(width, height);
      cachedLevelBackgrounds[i].beginDraw();
      cachedLevelBackgrounds[i].image(levelBackgrounds[i], 0, 0, width, height);
      cachedLevelBackgrounds[i].endDraw();
    }
  }

  // Center camera on player at start
  p = new Player(100, 100, 30, 30, this);
  origin = new PVector(width / 2, height / 2);
  center = new PVector(p.x + p.w/2, p.y + p.h/2);
  
  sb = loadImage("data/perkshopyeni12_3.png");
  sb_f = loadImage("data/perkshopyeni12_3_2.png");
  lock = loadImage("data/perkmenulock.png");
  healthbar = loadImage("data/healthbar.png");
  gb = loadImage("data/gameBack.png");
  character = loadImage("data/character.png");
  perk_slot = loadImage("data/empty.png");
  perk_close = loadImage("data/perkshop_kapa.png");
  perk_bag = loadImage("data/perkbag.png");
  bubbles = loadImage("data/bubble.png");
  ibutton = loadImage("data/button_i.png");
  myFont = createFont("P22MorrisGoldenRegular.ttf", 32);
  myFontOrnaments = createFont("P22MorrisOrnaments.ttf", 32);

  loadPerks();
  
  fogLeft = createGraphics(400, height);
  fogRight = createGraphics(400, height);
}

void draw() {
  switch(gameState) {
    case STATE_GAME:
      drawGame();
      break;
    case STATE_PERK_SHOP:
      drawPerkShop();
      break;
    case STATE_START_MENU:
      drawStartMenu();
      break;
    case STATE_GAME_OVER:
      drawDeadScreen();
      break;
    case STATE_GAME_WON:
      drawWinScreen();
      break;
  }
}

void keyPressed() {

  if ((keyCode == UP || key == ' ' || key == 'w' || key == 'W') && p.onGround && !p.isTalking) { p.jump = true; }
  if ((keyCode == LEFT || key == 'a' || key == 'A') && !p.isTalking) leftHeld = true;
  if ((keyCode == RIGHT|| key == 'd' || key == 'D') && !p.isTalking) rightHeld = true;
  if ((key == 'i' || key == 'I') && !p.isTalking) {
    gameState = (gameState == STATE_GAME) ? STATE_PERK_SHOP : STATE_GAME;
  }

  if (key == 'E' || key == 'e') { //Interact (doors and NPCs)
    for (Door door : doors) {
      if (door.isPlayerOn(p) && isLevelCleared())  {
        currentLevel = door.targetLevel;
        loadLevel(currentLevel);
        break;
      } 
    }

    for (NPC npc : npcs) {
      if (npc.isNear(p, 100)) {
        if (npc.isTalking) {npc.nextLine();} else if(npc.name == "Last Perkmaster"){gameState = STATE_PERK_SHOP;}
      } 
    }
  }
}

void keyReleased() {
  if (keyCode == LEFT || key == 'a' || key == 'A') leftHeld = false;
  if (keyCode == RIGHT|| key == 'd' || key == 'D') rightHeld = false;
}

boolean rectCollision(Block r1, Player r2) {
  return (r1.x < r2.x + r2.w &&
          r1.x + r1.w > r2.x &&
          r1.y < r2.y + r2.h &&
          r1.y + r1.h > r2.y);
}

boolean rectCollision(Player r1, Block r2) {
  return rectCollision(r2, r1); 
}

boolean enemyCollision(Enemy r1, Player r2) {
  return (r1.x < r2.x + r2.w &&
          r1.x + r1.w > r2.x &&
          r1.y < r2.y + r2.h &&
          r1.y + r1.h > r2.y);
}


void drawPerkShop() {
  pushStyle();
    fill(50, 50, 50, 200);
    image(sb,0,0);
    fill(255);
    textSize(24);
    textAlign(CENTER);
    for (PerkButton pb : perkButtons) {
      pb.draw();
    }
  popStyle();
  
  pushStyle();
  image(sb_f,0,0);
  tint(255,100);
  image(perk_close,width-100,100,25,25);
  popStyle();
  
  for (int i = 0; i < 3; i++) {
   if (p.equippedPerks.get(i) == null) {
      image(perk_slot, 500 + i * 75, 75, 75, 75);
    } else {
      image(getCachedPerkImage(p.equippedPerks.get(i)),  500 + i * 75, 75, 75, 75);
    }
  }
  
  pushStyle();
    fill(255, 255, 255);
    textFont(myFontOrnaments);
    textSize(50);
    textAlign(RIGHT);
    text("0",width-125,125);
    textFont(myFont);
    textSize(50);
    text(p.shards,width-175,125);
  popStyle();
}

void drawPerkButton(String label, float x, float y, float w, float h, String perkID) {
  fill(180);
  image(getCachedPerkImage(perkID),x,y,w,h);
  fill(255,255,255);
  textSize(16);
  textAlign(CENTER, TOP);
  text(label, x + w/2, y + h);
}

int lastFired = 0;
int fireDelay = 200;

void mousePressed() {
   if (gameState == STATE_PERK_SHOP) { 
      if (mouseX >= width - 100 && mouseX <= width - 100 + 25 && mouseY >= 100 && mouseY <= 100 + 25) {
        gameState = STATE_GAME;
      }
     
      for (int i = 0; i < perkButtons.size(); i++) {
        PerkButton perk = perkButtons.get(i);
        if (perk.isHovered() && !perk.isLocked) {
          selectPerk(perk);
          break;
        } else if (perk.isHovered()) {
          if (p.shards >= perk.price) {
            p.shards -= perk.price;
            perk.isLocked = false;
          }
        }
      }
  } else if (gameState == STATE_GAME) { //if pressed in game shoot fire
    if (millis() - lastFired >= fireDelay && p.mana >= 10) {
      p.mana -= 10;
      float speed = 10;
      float worldMouseX = center.x - origin.x + mouseX;
      float dir = (worldMouseX > p.x + p.w / 2) ? 1 : -1;
      projectiles.add(new Projectile(p.x + p.w / 2, p.y-7, speed * dir, 0,false));
      if (dir == -1) p.lastLooked = LEFT;
      if (dir == 1) p.lastLooked = RIGHT;
      lastFired = millis();
      p.attackAnimTimer = 30;
    }
  } else if (gameState == STATE_START_MENU) {
    if (mouseX >= 645 && mouseX <= 845 && mouseY >= 415 && mouseY <= 515) {
      gameState = STATE_GAME;
      loadLevel(currentLevel);
    }
  } else if (gameState == STATE_GAME_OVER) {
    gameState = STATE_START_MENU;
  }
}

void selectPerk(PerkButton perk) {
  println("Selected Perk ID: " + perk.perkID);
  
  if (!perk.isInUse) {
    for (int i = 0; i < 3; i++) {
      if (p.equippedPerks.get(i) == null) 
      {
        p.equippedPerks.set(i,perk.perkID);
        perk.isInUse = true;
        break;
      }
    }
  } else {
     p.equippedPerks.set(p.equippedPerks.indexOf(perk.perkID),null);
     perk.isInUse = false;
  }
}

void drawGame() {
  // Use cached background for the current level
  if (cachedLevelBackgrounds[currentLevel] != null) {
    image(cachedLevelBackgrounds[currentLevel], 0, 0);
  } else {
    background(220);
  }

  float dx = center.x - p.x;
  float dy = center.y - p.y;

  if (abs(dx) > 100) center.x -= dx - 100 * dx / abs(dx);
  if (abs(dy) > 100) center.y -= dy - 100 * dy / abs(dy);

  pushMatrix();
  translate(origin.x - center.x, origin.y - center.y);

  for (Door door : doors) {
    if (isInView(door.x, door.y, door.w, door.h)) {
      door.draw();
      if (door.isPlayerNear(p, 80)) {
        door.drawPrompt();
      }
    }
  }

  for (Decoration decoration : decorations) {
    if (isInView(decoration.x, decoration.y, decoration.w, decoration.h)) {
      decoration.draw();
    }
  }

  // --- Move onGround/collision calculation to here ---
  p.colliding = false;
  p.inWater = false;
  // Only check blocks near the player
  for (Block r : rects) {
    if (r.passable) continue;
    
    // Quick distance check before expensive collision
    if (abs(r.x - p.x) > r.w + 100 || abs(r.y - p.y) > r.h + 100) continue;

    // Sides
    float topY = r.y - 10;
    float btmY = r.y + r.h;
    float ltX = r.x - 10;
    float rtX = r.x + r.w;

    // Anticipation check
    if (p.vx > 0 && p.y + p.h - 10 > topY + 10 &&  // moving right
        p.x + p.w > ltX && p.x < ltX + 10 &&
        p.y + p.h > r.y && p.y < r.y + r.h) {
      p.anticipate = "LEFT";
    }
    if (p.vx < 0 && p.y + p.h - 10 > topY + 10 &&
        p.x < rtX + 10 && p.x + p.w > rtX &&
        p.y + p.h > r.y && p.y < r.y + r.h) {
      p.anticipate = "RIGHT";
    }
    if (p.y < btmY + 10 && p.y + p.h > btmY &&
        p.x + p.w > r.x && p.x < r.x + r.w) {
      p.anticipate = "CEILING";
    }
    if (p.vy > 0 && p.y + p.h - 5 < topY + 10 &&
        p.y + p.h > topY && p.y < topY + 10 &&
        p.x + p.w > r.x && p.x < r.x + r.w) {
      p.anticipate = "FLOOR";
    }

    // Main collision check
    if (rectCollision(p, r) && !r.passable) {
      switch(p.anticipate) {
        case "FLOOR":
          p.vy = 0;
          p.y = r.y - p.h;
          p.onGround = true;
          p.colliding = true;
          break;
        case "CEILING":
          if (p.vy < 0) {
            p.vy = 0;
            p.y = r.y + r.h;
          }
          p.colliding = true;
          break;
        case "RIGHT":
          p.vx = 0;
          p.x = r.x + r.w;
          p.colliding = true;
          break;
        case "LEFT":
          p.vx = 0;
          p.x = r.x - p.w;
          p.colliding = true;
          break;
      }
    } 
  }
  if (!p.colliding) p.onGround = false;

  for (Block r : rects) {
    if (r.passable && rectCollision(p, r)) {
      p.inWater = true;
    } 
  }
  // --- End of move section ---

  trackProjectiles();

  for (int i = soulShards.size() - 1; i >= 0; i--) {
    soulShard s = soulShards.get(i);
    // Only update/draw if visible in viewport
    if (isInView(s.x, s.y, 40, 40)) {
      s.update(rects);
      s.draw();
    }
    if (s.isCollected(p)) {
      p.shards += 5;
      soulShards.remove(i);
    }
  }
  
  for (Text a : texts) {
    if (isInView(a.x, a.y, 100, 50)) a.draw();
  }

  float viewX = center.x - origin.x;
  float viewY = center.y - origin.y;
  for (Block r : rects) {
    if (isInView(r.x, r.y, r.w, r.h) && !r.passable) {
      r.draw();
    }
  }

  for (Enemy e : enemies) {
    if (isInView(e.x, e.y, e.w, e.h)) {
      e.update(p);
      e.draw(p);
    }
  }

  for (NPC npc : npcs) {
    if (isInView(npc.x, npc.y, npc.w, npc.h)) {
      npc.draw();
      if (npc.isNear(p, 100)) {
        if (!npc.isTalking && !npc.finishedTalking && !npc.hasTalked) {
          npc.startTalking();
        }
        npc.drawDialogue();
      } else {
        if (npc.isTalking) {
          npc.stopTalking();
          npc.hasTalked = true;
        }
      }
    }
  }

  p.update();
  p.draw();

  for (Block r : rects) {
    if (isInView(r.x, r.y, r.w, r.h) && r.passable) {
      r.draw();
    }
  }
  
  // Remove dead enemies efficiently
  enemies.removeIf(e -> e.health <= 0);
  popMatrix();

  // --- Optimized cached fog ---
  pushStyle();
  int fogWidth = 400;
  float fogOsc = 0.5 + 0.5 * sin(frameCount * 0.02);
  if (frameCount - lastFogFrame > 5) { // Only update every 5 frames
    fogLeft.beginDraw();
    fogLeft.clear();
    for (int x = 0; x < fogWidth; x++) {
      float baseAlpha = map(x, 0, fogWidth, 180, 0);
      float alpha = baseAlpha * (0.7 + 0.3 * fogOsc);
      fogLeft.noStroke();
      fogLeft.fill(80, 80, 120, alpha);
      fogLeft.rect(x, 0, 1, height);
    }
    fogLeft.endDraw();

    fogRight.beginDraw();
    fogRight.clear();
    for (int x = 0; x < fogWidth; x++) {
      float baseAlpha = map(x, 0, fogWidth, 180, 0);
      float alpha = baseAlpha * (0.7 + 0.3 * fogOsc);
      fogRight.noStroke();
      fogRight.fill(80, 80, 120, alpha);
      fogRight.rect(fogWidth - x - 1, 0, 1, height);
    }
    fogRight.endDraw();

    lastFogFrame = frameCount;
  }
  image(fogLeft, 0, 0);
  image(fogRight, width - fogWidth, 0);
  popStyle();
  // --- End cached fog ---

  if (p.y > 2000) loadLevel(currentLevel);

  drawHUD();
}

// Utility function to check if an object is in the current viewport
boolean isInView(float x, float y, float w, float h) {
  float viewX = center.x - origin.x;
  float viewY = center.y - origin.y;
  return (x + w > viewX && x < viewX + width &&
          y + h > viewY && y < viewY + height);
}

void loadPerks() {
  
  String[] names = { "Black Mirror", "Final Say", "Perfect Balance" ,"Plasma Explosion","Natures Will","Bloodthirsty", "Fish Ancestors" ,"Ghost Step", "Companion", "Book Worm","Adrenaline","ttt1","ttt2","ttt3","Helping Hand" };
  String[] ids = { "aynaxdxd","elveda","hayvani", "tutulma" , "patlartohum","kanicen","icgudu","zipzip", "dost", "kitapkurtu","ayna","lutuf","saglam","hormonlu","regen" };
  int[] costs = { 100, 100, 100, 75, 75, 20, 20, 20, 20, 20, 5, 20, 20, 20, 5 };

  int cols = 5;
  int xStart = 175, yStart = 200;
  int xSpacing = 200, ySpacing = 175;
  
  for (int i = 0; i < names.length; i++) {
    int x = xStart + (i % cols) * xSpacing;
    int y = yStart + (i / cols) * ySpacing;
    perkButtons.add(new PerkButton(names[i], ids[i], x, y, costs[i]));
  }

}

void drawHUD() {
  if (p.isTalking) return;
   image(hudLayer, 0, 0);
    pushStyle();
      noStroke();
      fill(map(p.health,0,100,200,255),65,55);
      rect(120,655,map(p.health,0,100,0,200),25);
      
      fill(43,110,242);
      rect(120,685,map(p.mana,0,100,0,200),20);
  popStyle();
  
  image(healthbar, 120,655,200,25);
  image(healthbar, 120,685,200,20);
  image(character, 20, 610, 98,98);
  
  image(sagalt,width-200,height-200,200,200);
  image(perk_bag,width-200,height-125,100,100);
  image(ibutton,width-135,height-65,50,50);
   
  for (int i = 0; i < 3; i++) {
    if (p.equippedPerks.get(i) == null) {
      image(perk_slot, width - 100, height - 100 - i * 75, 75, 75);
    } else {
      image(getCachedPerkImage(p.equippedPerks.get(i)), width - 100, height - 100 - i * 75, 75, 75);
    }
  }
  
  pushStyle();
  fill(255,255,255);
  textFont(myFontOrnaments);
  textSize(50);
  text("0",350,height-50);
  textFont(myFont);
  textSize(50);
  text(p.shards,400,height-50);
  popStyle();

  if (p.inWater) {
    for (int i = 0; i < 5-int(p.underWaterTimer/72); ++i) {
      // Draw underwater effect
      image(bubbles, 80 + i * 50, height - 140, 40, 40);
    }

    if (p.underWaterTimer > 360) {
      tint(0, 0, 255, 100);
    } 
  }

  if (!p.inWater) {
    noTint();
  }
}

void cacheImages() {
  hudLayer = createGraphics(width, height);
  hudLayer.beginDraw();
  hudLayer.background(0, 0); // transparent
  hudLayer.image(loadImage("data/HUD_1.png"), 0, 0, width, height);
  hudLayer.endDraw();
  
  sagalt = createGraphics(400, 400);
  sagalt.beginDraw();
  sagalt.background(0, 0);
  sagalt.image(loadImage("data/sagust6.png"), 0, 0);
  sagalt.endDraw();
  
  brLayer = createGraphics(width, height);
  brLayer.beginDraw();
  brLayer.image(loadImage("data/gameBack.png"), 0, 0, width, height);
  brLayer.endDraw();

  start_menu = createGraphics(width, height);
  start_menu.beginDraw();
  start_menu.image(loadImage("data/start_menu.png"), 0, 0, width, height);
  start_menu.endDraw();
}

void loadLevel(int level) {
  if (level == 100) {
    gameState = STATE_GAME_WON;
    return;
  }

  rects.clear();
  npcs.clear();
  enemies.clear();
  texts.clear();
  soulShards.clear();
  projectiles.clear();
  doors.clear();
  decorations.clear();

  p.x = 100;
  p.y = 100;
  p.vx = 0;
  p.vy = 0;

  bgLoopSound.loop();

  switch(level) {
    case 1:
      rects.add(new Block(-1390, -400, 1000, 1450,true)); //level bounding box
      rects.add(new Block(-390, 100, 900, 390,true)); // initial floor
      decorate(14,55, -390, 500); // flower decoration on initial floor

      texts.add(new Text(120,-40,20,"Welcome to \nPerkMaster's Dungeon!"));
      texts.add(new Text(-110, -40, 20, "Use 'W' to jump,\n'A' and 'D' to move,\nand 'E' to interact."));
      texts.add(new Text(350, -40, 20, "Left click to shoot, \ncollect soul flowers \nto unlock Perks!"));

      addStairs(510, 100, 200, 200, 5,true); // first set of stairs
      rects.add(new Block(710, 300, 200, 40,true)); // platform after stairs
      decorate(5,255, 710, 860); // flower decoration on first platform
      enemies.add(new Enemy(800, 200, 30, 30,50,this)); // enemy on first platform
      texts.add(new Text(850, 100, 20, "Watch out for enemies! \nThey can drop soul flowers."));
      texts.add(new Text(1000, 200, 20, "TIP: Book worm perk\nincreases your mana regeneration."));


      addStairs(910, 340, 160, 160, 4,true); // second set of stairs
      rects.add(new Block(1070, 500, 240, 40,true)); // platform after second stairs
      decorate(6,455, 1070, 1220); // flower decoration on second platform
      npcs.add(new NPC(1200, 330, 120, 185, "Last Perkmaster",
      new String[] {
        "The others… they didn’t make it. \n(Press E to continue.)",
        "I’m the last Perkmaster left—been binding\nsoul flowers to Perks ever since the fall.",
        "This place is alive. It shifts,\nit punishes, and it remembers.",
        "Kill what you must. Gather soul flowers.\nUnlock Perks to survive.",
        "You can open the Perk Shop anytime\nby pressing 'I'.",
        "Don’t wait too long…\nthis dungeon shows no mercy.",
        "Now, go ahead and craft your first Perk\nfrom the shop—it's called 'Helping Hand'.",
        "You should have enough soul flowers\nby now to afford it.",
        "'Helping Hand' will grant you\nregeneration throughout your journey.",
        "It may just be the thing that\nkeeps you alive in here.",
        "After crafting it, click on it\nto equip and activate its power."
      }, loadImage("data/perkmaster.png"),p)); // NPC on second platform

      addStairs(1310, 500, 400, 400, 10,true); // third set of stairs
      rects.add(new Block(1700, 900, 400, 40+500,true)); // platform after third stairs
      rects.add(new Block(2100, 500, 100, 440+500,true)); // ambiance adding platform after third stairs
      enemies.add(new ShooterEnemy(1850, 690, 440*.8, 350*.8, 200, this, "data/shooterEnemy_forestSkin_idle.gif", "data/shooterEnemy_forestSkin.gif", false)); // enemy on third platform - guarding the door.
      texts.add(new Text(1650, 450, 20, "This door leads to the next level.\nSomethings guarding it!"));
      texts.add(new Text(1800, 550, 20, "All enemies must be defeated\nbefore you can pass through."));

      doors.add(new Door(1850, 740, 120, 160, 2)); // door to level 2

      rects.add(new Block(2200, 0, 1000, 1450,true)); //level bounding box
      break;

    case 2:
      p.x = 100;
      p.y = height-100;
      rects.add(new Block(-550, height-1000, 550, 2000,false)); //level bounding box

      rects.add(new Block(0, height - 40, 900, 40));
      rects.add(new Block(250, height - 100, 100, 20));
      rects.add(new Block(450, height - 180, 100, 20));
      rects.add(new Block(650, height - 260, 100, 20));
      rects.add(new Block(-200, 2000, 500, 50)); 

      enemies.add(new Enemy(700, height - 300, 30, 30,50,this,true));
      enemies.add(new Enemy(500, height - 150, 30, 30,50,this,false));

      texts.add(new Text(300, height - 300, 20, "Pool Party:\nSecond Level"));
      texts.add(new Text(600, height - 400, 20, "TIP: companion perk\nincreases you strength based on \nhow many enemies there are on the level\n (max 5)"));

      addStairs(900, height, 200, 200, 5,false); // first set of stairs
      rects.add(new Block(1100, height + 200, 1440, 40,false)); // platform after stairs for pool
      rects.add(new Block(1060, height+120, 40, 40,color(45, 120, 255), 150, true)); // stair offset
      rects.add(new Block(1020, height+80, 80, 40,color(45, 120, 255), 150, true)); // stair offset
      rects.add(new Block(980, height+40, 120, 40,color(45, 120, 255), 150, true)); // stair offset
      rects.add(new Block(940, height, 160, 40,color(45, 120, 255), 150, true)); // stair offset
      rects.add(new Block(900, height-40, 200, 40,color(45, 120, 255), 150, true)); // stair offset
      rects.add(new Block(1100, height-40, 1400, 240,color(45, 120, 255), 150, true)); // main body pool water
      enemies.add(new ShooterEnemy(1700, height + 100, 200, 165, 200, this, false)); // pool enemy
      enemies.add(new ShooterEnemy(2050, height + 100, 200, 165, 200, this, false));
      rects.add(new Block(1600, height+100, 100, 20));// breathing spot for water water
      enemies.add(new Enemy(1300, height + 100, 30, 30,50,this,false));
      rects.add(new Block(2500, height-40, 40, 160, false)); //block bounding edge of pool
      addStairs(2540, height+240, 200, 200, 5,false); // second set of stairs
      rects.add(new Block(2740, height+440, 200, 40, false)); //block to have the door on top
      doors.add(new Door(2800, height+300, 120, 160, 3)); // door to level 3

      rects.add(new Block(2940, height-1000, 550, 2000,false)); //level bounding box

      npcs.add(new NPC(800, height-165, 140, 140, "The Lifeguard",
      new String[] {
          "You're heading into the pool, huh?\nBetter listen close.",
          "I'm giving you a water tank,\nbut it only lasts five seconds.",
          "After that, you start drowning—\nfast and painful.",
          "You need to come out to the surface to breathe.",
          "Don't think that's all.\nThere's a Guardian of the Seat beyond that door.",
          "It's ancient, merciless, and it protects\nthe path to the deeper dungeon.",
          "If you're going in, be ready to fight.\nAnd don't waste your breath—literally.",
          "Good luck.\nYou'll need more than just lungs down there."
      }, loadImage("data/lifeguard.png"),p)); // NPC on first platform
      break;
    case 3:
      p.x = 240;
      p.y = height - 100;

      rects.add(new Block(-500, height-1000, 500, 2000, false)); // bounding box left

      // Starting ground
      rects.add(new Block(0, height - 40, 800, 40, true));
      decorate(8, height - 86, 0, 800);
      texts.add(new Text(250, height - 200, 20, "Level 3: Ashen Furnace"));

      // Platform with enemy and hint
      rects.add(new Block(900, height - 120, 200, 40, true));
      enemies.add(new Enemy(950, height - 150, 50, 40, 100, this, "data/l3enemy.gif" ,true));
      texts.add(new Text(700, height - 200, 20, "TIP: adrenaline perk\ncan help you move faster in dire situations!\n (health below 50)"));

      // Second enemy and narrow jump
      rects.add(new Block(1150, height - 200, 120, 20, true));
      enemies.add(new ShooterEnemy(1200, height - 250, 120, 100, 200, this,"data/l3shooter.gif","data/l3shooter.gif", false));
      decorate(4, height - 240, 1150, 1250);

      // Add collapsed bridge look
      rects.add(new Block(1350, height - 120, 60, 20, true)); // left piece
      rects.add(new Block(1450, height - 120, 60, 20, true)); // right piece
      texts.add(new Text(1370, height - 180, 20, "Careful...\nThe path looks unstable."));

      // Vertical movement
      addStairs(1510, height - 120, 200, 200, 5, true);
      rects.add(new Block(1710, height + 80, 300, 40, true));
      enemies.add(new Enemy(1750, height + 10, 30, 30, 100, this, "data/l3enemy.gif" ,true));

      // Final area
      addStairs(2070, height + 80, 200, 200, 5, true);
      rects.add(new Block(2270, height + 280, 240, 40, true));
      doors.add(new Door(2300, height + 140, 120, 160, 4)); // next level

      rects.add(new Block(2600, height-1000, 550, 2000, false)); // bounding box right
      break;
    case 4:
      p.x = 100;
      p.y = height - 100;

      // Left bounding box
      rects.add(new Block(-600, height - 1000, 600, 2000, false));

      texts.add(new Text(280, height - 200, 20, "Level 4: Sunken Sanctum"));

      texts.add(new Text(600, height - 300, 20, "TIP: fish ancestors perk\ncan help you breathe underwater!\n it also regenerates your health!"));

      // Start platform and descent
      rects.add(new Block(0, height - 40, 900, 40, false));
      decorate(15, height - 84, 0, 700);
      enemies.add(new Enemy(750, height - 150, 30, 30, 100, this, "data/l4enemy.gif", false));

      // Descent stairs
      addStairs(900, height, 200, 200, 5, false);
      rects.add(new Block(1100, height + 200, 1500, 40, false)); // main water platform
      rects.add(new Block(1060, height + 120, 40, 40, color(45, 120, 255), 150, true));
      rects.add(new Block(1020, height + 80, 80, 40, color(45, 120, 255), 150, true));
      rects.add(new Block(980, height + 40, 120, 40, color(45, 120, 255), 150, true));
      rects.add(new Block(940, height, 160, 40, color(45, 120, 255), 150, true));
      rects.add(new Block(900, height - 40, 200, 40, color(45, 120, 255), 150, true));

      // Water body
      rects.add(new Block(1100, height - 40, 1600, 240, color(45, 120, 255), 150, true));
      rects.add(new Block(2700, height - 40, 40, 200, false)); // far right boundary of water

      // Enemies in the water
      enemies.add(new ShooterEnemy(1300, height + 80, 200, 165, 200, this, false));
      enemies.add(new ShooterEnemy(1600, height + 80, 200, 165, 200, this, false));
      enemies.add(new Enemy(1850, height + 100, 30, 30, 100, this, "data/l4enemy.gif", false));
      enemies.add(new Enemy(2200, height + 120, 30, 30, 100, this, "data/l4enemy.gif", false));

      // Air pockets
      rects.add(new Block(1400, height + 80, 80, 20)); // air spot 1
      rects.add(new Block(2000, height + 90, 80, 20)); // air spot 2

      // NPC warning
      npcs.add(new NPC(700, height - 170, 140, 140, "Deep Diver",
        new String[] {
          "Not many make it this far...",
          "The sanctum ahead is fully submerged.",
          "Your tank gives you 4 seconds.\nCome up for air often.",
          "And watch the jellyfish—they aren’t dumb.",
          "They wait.\nThen strike when you're breathless.",
          "Go in prepared. Or don’t go in at all."
        }, loadImage("data/miner.png"), p));

      // Exit stairs + platform
      addStairs(2600, height + 200, 280, 280, 7, false);
      rects.add(new Block(2940, height + 460, 200, 40, false));
      doors.add(new Door(2980, height + 300, 120, 160, 100)); // goes to game win or next world

      // Right bounding box
      rects.add(new Block(3200, height - 1000, 600, 2000, false));
      break;


  }
  center.x = p.x + p.w/2;
  center.y = p.y + p.h/2;
}

void trackProjectiles() {
  for (int i = projectiles.size() - 1; i >= 0; i--) {
    Projectile proj = projectiles.get(i);
    // Only update/draw if visible
    if (isInView(proj.x, proj.y, 20, 20)) {
      proj.update();
      proj.draw();
    }

    for (Enemy e : enemies) {
      if (!proj.isEnemy && proj.hits(e)) {
        int damageDealt = (int)(20 * p.getTotalStrength());
        e.takeDamage(damageDealt);
        proj.active = false;
      }
      if (e.health <= 0 && !e.deadHandled) {
        killSound.rewind();
        killSound.play();
        
        int numShards = (int)random(1, 5);
        for (int randomTimes = 0; randomTimes < numShards; randomTimes++) {
          soulShards.add(new soulShard(e.x + random(-15, 15) + e.w/2, e.y + e.h/2, this));
        }
        e.deadHandled = true;
      }
    }

    if (proj.isEnemy && proj.hits(p)) {
      p.hit(proj.damage);
      proj.active = false;
    }

    if (!proj.active) {
      projectiles.remove(i);
    }
  }
}

void drawStartMenu() {
  image(start_menu, 0, 0);

  pushStyle();
    textAlign(CENTER, CENTER);
    textFont(myFont);
    fill(255);
    textSize(100);
    text("Perkmaster's \nDungeon", width/2, 160);
    fill(255,255,255,40);
    text("Perkmaster's \nDungeon", width/2-10, 170);

    textFont(myFont);
    fill(255);
    textSize(90);
    text("Start!", 745, 465);
  popStyle();
}

void drawDeadScreen() {
  background(0);
  pushStyle();
    textAlign(CENTER, CENTER);
    textFont(myFont);
    fill(255);
    textSize(100);
    text("You Died", width/2, height/2);
  popStyle();
}

void addStairs(int startX, int startY,int howLong, int howTall, int steps, boolean hasGrass) {
  for (int i = 0; i < steps; i++) {
    int x = startX + i * (howLong / steps);
    int y = startY + i * (howTall / steps);
    rects.add(new Block(x, y, howLong / steps, howTall / steps, hasGrass));
  }
}

void addStairs(int startX, int startY,int howLong, int howTall, int steps) {
  addStairs(startX, startY, howLong, howTall, steps, false);
}

// Add to class variables
HashMap<String, PImage> perkImageCache = new HashMap<String, PImage>();

PImage getCachedPerkImage(String perkID) {
  if (!perkImageCache.containsKey(perkID)) {
    perkImageCache.put(perkID, loadImage("data/perk_" + perkID + ".png"));
  }
  return perkImageCache.get(perkID);
}

boolean isLevelCleared() {
  boolean allEnemiesDead = true;
  for (Enemy e : enemies) {
    if (e.health > 0) {
      allEnemiesDead = false;
      return false; // If any enemy is alive, level is not cleared
    }
  }

  return allEnemiesDead;
}

void decorate(int count, int floorY, int leftX, int rightX) {
  for (int i = 0; i < count; i++) {
    float x = random(leftX, rightX);
    float y = floorY;
    decorations.add(new Decoration(x, y, currentLevel));
  }
}

void drawWinScreen() {
  background(0);
  pushStyle();
    textAlign(CENTER, CENTER);
    textFont(myFont);
    fill(255);
    textSize(100);
    text("You Won!", width/2, height/2);
  popStyle();
}

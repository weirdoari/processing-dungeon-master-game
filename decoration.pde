class Decoration {
  float x, y;
  float w = 50, h = 50; // Fixed size
  PImage sprite;
  String[] spriteNames;
  
  // Different decoration sets for each level
  String[] level1Decorations = {
    "decoration1.png", 
    "decoration2.png", 
    "decoration3.png", 
    "decoration4.png",
    "decoration5.png",
    "decoration6.png",
    "decoration7.png",
    "decoration8.png",
    "decoration9.png",
    "decoration10.png",
  };
  
  String[] level2Decorations = {    
    "decoration1.png", 
    "decoration2.png", 
    "decoration3.png", 
    "decoration4.png",
    "decoration5.png",
    "decoration6.png",
    "decoration7.png",
    "decoration8.png",
    "decoration9.png",
    "decoration10.png",
  };
  
  String[] level3Decorations = {
    "decoration2.png", 
    "decoration3.png", 
    "decoration4.png",
    "decoration5.png",
    "decoration6.png",
    "decoration7.png",
    "decoration8.png",
    "decoration9.png",
    "decoration10.png",
  };

  String[] level4Decorations = {
    "cdecor1.png", 
    "cdecor2.png",
    "cdecor3.png",
    "cdecor4.png",
    "cdecor5.png",
    "decoration8.png",
    "decoration9.png",
    "decoration10.png",
  };
  
  Decoration(float x, float y, int level) {
    this.x = x;
    this.y = y;
    
    // Choose sprite array based on level
    switch(level) {
      case 1:
        spriteNames = level1Decorations;
        break;
      case 2:
        spriteNames = level2Decorations;
        break;
      case 3:
        spriteNames = level3Decorations;
        break;
      case 4:
        spriteNames = level4Decorations;
        break;
      default:
        spriteNames = level1Decorations; // Default fallback
        break;
    }
    
    // Pick a random sprite from the level-specific array
    String randomSprite = spriteNames[int(random(spriteNames.length))];
    sprite = loadImage("data/" + randomSprite);
  }
  
  Decoration(float x, float y, String specificSprite) {
    this.x = x;
    this.y = y;
    // Use a specific sprite
    sprite = loadImage("data/" + specificSprite);
  }
  
  void draw() {
    pushStyle();
    if (sprite != null) {
      image(sprite, x, y, w, h);
    } else {
      // Fallback if image doesn't load
      fill(100, 150, 100);
      rect(x, y, w, h);
      fill(255);
      textAlign(CENTER, CENTER);
      text("DECOR", x + w/2, y + h/2);
    }
    popStyle();
  }
}
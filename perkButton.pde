class PerkButton {
  float x, y, wh = 125;
  String label;
  String perkID;
  PImage icon;
  boolean isLocked;
  boolean isInUse;
  int price;

  PerkButton(String label, String perkID, float x, float y, int price) {
    this.label = label;
    this.perkID = perkID;
    this.x = x;
    this.y = y;
    //this.w = w;
    //this.h = h;
    this.icon = loadImage("data/perk_" + perkID + ".png");
    this.isLocked = true;
    this.price = price;
    isInUse = false;
  }

  void draw() {
    if (isInUse) {
      image(perk_slot, x-2.5, y-2.5, wh+5, wh+5);
    }
    
    pushStyle();
      if (isLocked) { tint(255, 75); }
      image(icon, x, y, wh, wh);
      fill(255);
      textSize(16);
      textAlign(CENTER, TOP);
      text(label, x + wh / 2, y + wh);
    popStyle();
    
    pushStyle();
      if (isLocked) {image(lock,x+10, y+10, wh-20, wh-20); 
      textAlign(CENTER, TOP);
      textFont(myFontOrnaments);
      textSize(20);
      text("0", x + wh / 2 - 25, y + wh * 1.15);
      textFont(myFont);
      textSize(20);
      text(price, x + wh / 2, y + wh * 1.15);
    }
    popStyle();
  }

  boolean isHovered() {
    return mouseX > x && mouseX < x + wh &&
           mouseY > y && mouseY < y + wh;
  }
}

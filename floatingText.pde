class Text {
  float x, y;
  String text;
  int tSize;
  
  Text(float x, float y, int tSize ,String text) {
    this.x = x;
    this.y = y;
    this.tSize = tSize;
    this.text = text;
  }
  
  void draw() {
  pushMatrix();
  pushStyle();
      textFont(myFont);
      fill(255,255,255);
      translate(x,y);
      textAlign(CENTER);
      textSize(tSize);
      text(text,0,0);
   popMatrix();
   popStyle();
  }
}

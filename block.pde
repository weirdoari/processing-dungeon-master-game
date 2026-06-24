class Block {
  float x, y, w, h;
  color c;
  ArrayList<Crack> cracks;
  boolean hasGrass = false;
  ArrayList<PVector> grassBlades = null; // Store grass blade positions
  boolean passable = false; // If true, projectiles and entities can pass through

  Block(float x, float y, float w, float h) {
    this(x, y, w, h, color(200,100,100,100));
  }

  Block(float x, float y, float w, float h, color c) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
    cracks = null;
  }

  // New constructor: takes opacity as int (0-255)
  Block(float x, float y, float w, float h, color c, int opacity) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    // Set color with specified alpha
    this.c = color(
      red(c),
      green(c),
      blue(c),
      constrain(opacity, 0, 255)
    );
    cracks = null;
  }

  // New constructor: dirt block with grass
  Block(float x, float y, float w, float h, boolean grassOnTop) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.hasGrass = grassOnTop;
    // Use brown color only if grass is on top, otherwise use default pinkish color
    this.c = grassOnTop ? color(120, 72, 24, 255) : color(200, 100, 100, 255);
    cracks = null;
    grassBlades = null;
  }

  // New constructor: passable block
  Block(float x, float y, float w, float h, color c, boolean passable) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
    this.passable = passable;
    cracks = null;
  }

  // New constructor: passable block with opacity
  Block(float x, float y, float w, float h, color c, int opacity, boolean passable) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    // Set color with specified alpha
    this.c = color(
      red(c),
      green(c),
      blue(c),
      constrain(opacity, 0, 255)
    );
    this.passable = passable;
    cracks = null;
  }

  void draw() {
    pushStyle();
    // Optimize for large blocks
    boolean isLarge = w > 1400 || h > 1400;
    if (isLarge) {
      // For very large blocks, just draw solid color, skip details
      noStroke();
      fill(c); // Use the block's color, not a hardcoded one
      rect(x, y, w, h);
    } else {
      // For small/medium blocks, use gradient and details
      int gradSteps = max(6, int(h / 8)); // fewer steps for performance
      float stepH = h / gradSteps;
      for (int i = 0; i < gradSteps; i++) {
        float inter = map(i, 0, gradSteps, 0.85, 1.0);
        // If grass block, don't use yellowish gradient, keep brown
        color grad = hasGrass
          ? lerpColor(c, color(80, 48, 16, 255), inter)
          : lerpColor(c, color(red(c) * 1.2, green(c) * 1.2, blue(c) * 1.2, 200), inter);
        noStroke();
        fill(grad);
        rect(x, y + i * stepH, w, stepH + 1);
      }

      // Edge highlight (top)
      fill(255, 255, 255, 90); // more visible highlight, still transparent
      rect(x, y, w, 6, 3, 3, 0, 0);

      // Edge shadow (bottom)
      fill(20,20,20, 80); // yellowish shadow, transparent
      rect(x, y + h - 6, w, 6, 0, 0, 3, 3);

      // Draw grass if this is a dirt block with grass
      if (hasGrass) {
        fill(60, 180, 60, 255); // solid green grass
        rect(x, y - 4, w, 12, 6, 6, 2, 2);
        // Store grass blade positions for consistency
        if (grassBlades == null) {
          grassBlades = new ArrayList<PVector>();
          int bladeCount = int(w/12);
          for (int i = 0; i < bladeCount; i++) {
            float gx = x + 4 + i * 12 + random(-2, 2);
            float gy = y - 4 + random(0, 4);
            grassBlades.add(new PVector(gx, gy));
          }
        }
        for (PVector blade : grassBlades) {
          stroke(40, 140, 40);
          strokeWeight(2);
          line(blade.x, blade.y, blade.x, blade.y - 2);
        }
        noStroke();
      }

      // Cracks/spots for small/medium blocks (persistent)
      if (cracks == null) {
        cracks = new ArrayList<Crack>();
        int detailCount = int(random(2, 4)); // fewer details for perf
        for (int i = 0; i < detailCount; i++) {
          float cx = x + random(8, w - 8);
          float cy = y + random(8, h - 8);
          float len = random(14, 28);
          boolean isCrack = random(1) < 0.5;
          float dx = len * random(-0.7, 0.7);
          float dy = len * random(-0.3, 0.3);
          float ew = random(3, 7);
          float eh = random(3, 7);
          cracks.add(new Crack(cx, cy, dx, dy, isCrack, ew, eh));
        }
      }
      for (Crack cr : cracks) {
        if (cr.isCrack) {
          stroke(255,255,255, 120);
          strokeWeight(2);
          line(cr.cx, cr.cy, cr.cx + cr.dx, cr.cy + cr.dy);
        } else {
          noStroke();
          fill(255,255,255, 100);
          ellipse(cr.cx, cr.cy, cr.ew, cr.eh);
        }
      }
    }
    noStroke();
    popStyle();
  }

// Helper class for cracks/spots
class Crack {
  float cx, cy, dx, dy, ew, eh;
  boolean isCrack;
  Crack(float cx, float cy, float dx, float dy, boolean isCrack, float ew, float eh) {
    this.cx = cx;
    this.cy = cy;
    this.dx = dx;
    this.dy = dy;
    this.isCrack = isCrack;
    this.ew = ew;
    this.eh = eh;
  }
}
}
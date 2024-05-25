float angle = 0;
float orbitRadius = 100;
float tamanho = 0.7;

void setup() {
  size(400, 400);
  frameRate(60);
}

void draw() {
  background(0);
  
  drawPlanet();

  float x = width / 2 + cos(angle) * orbitRadius;
  float y = height / 2 + sin(angle) * orbitRadius;

  
  pushMatrix();
  translate(x, y);
  rotate(atan2(height / 2 - y, width / 2 - x));
  drawRocket();
  popMatrix();

  angle += 0.02;
}

void drawRocket(){
  // Área do foguete
  fill(0);
  stroke(0);
  ellipse(0, 0, 80 * tamanho, 150 * tamanho);

  // Janela
  fill(105, 208, 247);
  ellipse(0, -19 * tamanho, 28 * tamanho, 25 * tamanho);
  
  // Propulsores
  fill(121,121,121);
  rect(-35 * tamanho, 8 * tamanho, 70 * tamanho, 10 * tamanho);
  
  beginShape();
  vertex(-5 * tamanho, 26 * tamanho);
  vertex(5 * tamanho, 26 * tamanho);
  vertex(15 * tamanho, 36 * tamanho);
  vertex(-15 * tamanho, 36 * tamanho);
  endShape(CLOSE);
  
  // Asas da nave
  fill(255, 0, 0);
  beginShape();
  vertex(-22 * tamanho, -10 * tamanho);
  vertex(-48 * tamanho, 25 * tamanho);
  vertex(-10 * tamanho, 2 * tamanho);
  endShape(CLOSE);

  beginShape();
  vertex(22 * tamanho, -10 * tamanho);
  vertex(48 * tamanho, 25 * tamanho);
  vertex(10 * tamanho, 2 * tamanho);
  endShape(CLOSE);
  
  rect(-12.5 * tamanho, 20 * tamanho, 25 * tamanho, 10 * tamanho);
  
  // Corpo da nave
  fill(200);
  ellipse(0, 0, 50 * tamanho, 50 * tamanho);
}

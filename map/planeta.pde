void drawPlanet() {
  
  //trajetória
  noFill();
  stroke(255,255,255);
  ellipse(width/2, height/2, 210, 210);
  
  // Desenha o planeta no centro
  noStroke();
  fill(210, 105, 30);
  ellipse(width / 2, height / 2, 100, 100);
  

  // Adiciona sombras para criar profundidade
  for (int i = 0; i < 30; i++) {
    fill(210 - i * 2, 105 - i, 30 - i / 2, 150 - i); // Gradiente de cor para sombra
    ellipse(width / 2 - i / 10, height / 2 - i / 10, 100 - i, 100 - i);
  }

  // Adiciona manchas escuras
  fill(139, 69, 19, 180); // Cor marrom escuro semi-transparente
  ellipse(width / 2 - 20, height / 2 + 10, 20, 10);
  ellipse(width / 2 + 15, height / 2 - 20, 15, 8);
  ellipse(width / 2 - 10, height / 2 - 30, 25, 12);

  // Adiciona pequenos pontos brilhantes
  fill(255, 255, 255, 200); // Cor branca semi-transparente
  ellipse(width / 2 + 5, height / 2 + 15, 5, 5);
  ellipse(width / 2 - 15, height / 2 - 10, 4, 4);
  ellipse(width / 2 + 10, height / 2 - 5, 3, 3);

}

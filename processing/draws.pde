void drawPopupWindow(int w, int h, int px, int py){
  fill(white);
  rect(px, py, w, h, 20);
}

void drawReturnMessage(int w, int h, int px, int py){
  fill(100); // Gray
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Press BACKSPACE to return", px, py + h - 35, w, 40);
}

void drawTitle(String title, color c, float x, float y, float size) {
  textAlign(CENTER, CENTER);
  textSize(size);

  // Back layer
  color backLayerColor = lerpColor(c, color(0), 0.5);
  fill(backLayerColor);
  text(title, x + 4, y + 4);

  // Middle layer 
  color middleLayerColor = lerpColor(c, color(0), 0.25);
  fill(middleLayerColor);
  text(title, x + 2, y + 2);

  // Top layer
  fill(c);
  text(title, x, y);

  // Highlight layer 
  color highlightColor = lerpColor(c, color(255), 0.3);
  fill(highlightColor);
  text(title, x - 2, y - 2);
}

void drawMenu() {
  int popupWidth = 600, popupHeight = 400;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  drawTitle("The Game", blue, width / 2, height / 4 + 25, 48);

  // Calculate the y-position for the first button
  int startY = height / 2 - buttonHeight;
  stroke(0);
  drawButton(buttonX, startY, "Login", menuButtonIndex == 1, blue);
  drawButton(buttonX, startY + buttonHeight + buttonSpacing, "Register", menuButtonIndex == 2, blue);
  drawButton(buttonX, startY + buttonHeight * 2 + buttonSpacing * 2, "Quit", menuButtonIndex == 3, blue);
}

void drawLoginPopup() {
  int popupWidth = 300, popupHeight = 260;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(blue);
  text("Login", popupX, popupY + 10, popupWidth, 30);
   
  stroke(0);

  // Draw username label and password label
  drawTextBox(popupX + 25, popupY + 50, popupButtonIndex == 1, white, popupUsername);
  drawTextBox(popupX + 25, popupY + 110, popupButtonIndex == 2, white, popupPassword);

  // Draw confirm button
  drawButton(popupX + 75, popupY + popupHeight - 70, "Confirm", popupButtonIndex == 3, blue);
  
  drawReturnMessage(popupWidth, popupHeight, popupX, popupY);
}

// Draw register popup screen
void drawRegisterPopup() {
  int popupWidth = 300, popupHeight = 310;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);

  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(blue);
  text("Register", popupX, popupY + 10, popupWidth, 30);

  stroke(0);
  // Draw username, password, and confirm password labels
  drawTextBox(popupX + 25, popupY + 50, popupButtonIndex == 1, white, popupUsername);
  drawTextBox(popupX + 25, popupY + 110, popupButtonIndex == 2, white, popupPassword);
  drawTextBox(popupX + 25, popupY + 170, popupButtonIndex == 3, white, confirmPassword);

  // Draw confirm button
  drawButton(popupX + 75, popupY + popupHeight - 70, "Confirm", popupButtonIndex == 4, blue);
  
  drawReturnMessage(popupWidth, popupHeight, popupX, popupY);
}

void drawLobby(){
  int popupWidth = 600, popupHeight = 400;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  drawTitle("Welcome, " + popupUsername + "!", blue, width / 2, height / 4 + 25, 48);
  textSize(24);
  fill(0,0,0);
  text("You are level " + curr_level + "!", width / 2, height / 4 +75);
  // Calculate the y-position for the first button
  int startY = height / 2 - buttonHeight;
  stroke(0);
  drawButton(buttonX, startY, "Start Game", menuButtonIndex == 1, blue);
  drawButton(buttonX, startY + buttonHeight  + buttonSpacing, "Tutorial", menuButtonIndex == 2, blue);
  drawButton(buttonX, startY + buttonHeight * 2 + buttonSpacing * 2, "Logout", menuButtonIndex == 3, blue);
}

void drawTutorialPopup() {
  int popupWidth = 400, popupHeight = 300;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(blue);
  text("Tutorial", popupX, popupY +10, popupWidth, 30);
  
  // Draw tutorial text
  String tutorialText = "Welcome to the Tutorial!\n\nUse AWSD keys to move around.\n\nBe the last one standing and win the game!.";
  fill(0); // Black color
  textAlign(LEFT, TOP);
  textSize(18);
  text(tutorialText, popupX + 20, popupY + 50, popupWidth - 40, popupHeight - 40);
  
  drawReturnMessage(popupWidth, popupHeight, popupX, popupY);
}

void drawErrorPopup() {
  int popupWidth = 400, popupHeight = 200;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;

  backgroundStars();
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(blue);
  text("Oops!", popupX, popupY + 10, popupWidth, 30);
  
  // Draw error text
  fill(0); // Black color
  textAlign(CENTER, CENTER);
  textSize(18);
  text(errorText, popupX, popupY + 20, popupWidth, popupHeight - 40);
  
  drawReturnMessage(popupWidth, popupHeight, popupX, popupY);
}

void drawLoadingScreen() {
  backgroundStars();
  
  // Draw popup window
  int popupWidth = 600;
  int popupHeight = 350;
  int popupX = width/2 - popupWidth/2;
  int popupY = height/2 - popupHeight/2;
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(66, 135, 245);
  text("Looking for a Match...", popupX, popupY + 10, popupWidth, 30);
  
  drawReturnMessage(popupWidth, popupHeight, popupX, popupY);
  
  //trajetória
  noFill();
  stroke(0);
  ellipse(width/2, height/2, 210, 210);
  
  drawPlanet(color(210,105,30),100, width / 2, height / 2);
  
  float x = width / 2 + cos(angle) * orbitRadius;
  float y = height / 2 + sin(angle) * orbitRadius;
  
  pushMatrix();
  translate(x, y);
  rotate(atan2(height / 2 - y, width / 2 - x));
  
   // Área do foguete
  fill(255);
  stroke(255);
  ellipse(0, 0, 80 * 0.7, 150 * 0.7);
  
  left_boost = right_boost = main_boost = true;
  drawNave(0, 0, 0, 0.7, color(255, 0, 0));
  left_boost = right_boost = main_boost = false;
  
  popMatrix();

  angle += 0.02;
  
  if (socket.available() > 0) {
     byte[] receivedData = socket.readBytes();
     int code = receivedData[0];
     if (code == 121) {
        println("Received: " + receivedData);
        numJogador = receivedData[1];
        println("SOU O JOGADOR "+receivedData[1]);
        activeScreen = "GAME";
        println("ATIVEI GAME");
     }
     else{
        println("Null Socket");
     }
  }
  if(receivedData.equals("ERROR:Lobby_found_but_full")){
     activeScreen = "LOADING";
  }
}

// Draw button function
void drawButton(int x, int y, String label, boolean focused, color buttonColor) {
  if (focused) {
    fill(lerpColor(buttonColor, color(0), 0.3));
  } else {
    fill(buttonColor);
  }
  rect(x, y, buttonWidth, buttonHeight, 20);

  // Button text
  fill(white);
  textSize(24);
  text(label, x + buttonWidth / 2, y + buttonHeight / 2);
}

void drawTextBox(int x, int y, boolean focused, color boxColor, String text) {
  if (focused) {
    fill(lerpColor(boxColor, color(0), 0.1));
  } else {
    fill(boxColor);
  }
  rect(x, y, TextBoxWidth, TextBoxHeight);

  // Display the text
  fill(0); // Black color
  textAlign(CENTER, CENTER);
  textSize(24);
  text(text, x + TextBoxWidth / 2, y + TextBoxHeight / 2);
}

void typing() {
  if ((keyCode >= 32 && keyCode <= 126) || keyCode == BACKSPACE) {
    if (popupButtonIndex == 1) {
      if (keyCode == BACKSPACE) {
        if (popupUsername.length() > 0) {
          popupUsername = popupUsername.substring(0, popupUsername.length() - 1);
        }
      } else if (popupUsername.length() < 20) {
        popupUsername += key;
      }
    } else if (popupButtonIndex == 2) {
      if (keyCode == BACKSPACE) {
        if (popupPassword.length() > 0) {
          popupPassword = popupPassword.substring(0, popupPassword.length() - 1);
        }
      } else if (popupPassword.length() < 20) {
        popupPassword += key;
      }
    } else if (popupButtonIndex == 3) {
      if (keyCode == BACKSPACE) {
        if (confirmPassword.length() > 0) {
          confirmPassword = confirmPassword.substring(0, confirmPassword.length() - 1);
        }
      } else if (confirmPassword.length() < 20) {
        confirmPassword += key;
      }
    }
  }
}

void drawPlanet(color mainColor, float size,float x,float y) {
  float r = red(mainColor);
  float g = green(mainColor);
  float b = blue(mainColor);

  // Planeta
  noStroke();
  fill(mainColor);
  ellipse(x, y, size, size);  

  // Sombras
  for (int i = 0; i < 30; i++) {
    fill(r - i * 2, g - i, b - i / 2, 150 - i);
    ellipse(x - i / 10, y - i / 10, size - i, size - i);
  }

  // Detalhes
  fill(r * 0.66, g * 0.66, b * 0.66, 180);
  ellipse(x - size * 0.2, y + size * 0.1, size * 0.2, size * 0.1);
  ellipse(x + size * 0.15, y - size * 0.2, size * 0.15, size * 0.08);
  ellipse(x - size * 0.1, y - size * 0.3, size * 0.25, size * 0.12);

  // White details
  fill(255, 255, 255, 200); 
  ellipse(x + size * 0.05, y + size * 0.15, size * 0.05, size * 0.05);
  ellipse(x - size * 0.15, y - size * 0.1, size * 0.04, size * 0.04);
  ellipse(x + size * 0.1, y - size * 0.05, size * 0.03, size * 0.03);
}
  
void drawNave(float x, float y, float angle, float tamanho, color details) {
  pushMatrix();
  translate(x, y);
  rotate(radians(angle));
  // Rotate roda consoante o referencial do processing

  stroke(0);
  
  // Janela
  fill(105, 208, 247);
  ellipse(0, -19 * tamanho, 28 * tamanho, 25 * tamanho);
  
  // Propulsores
  fill(121, 121, 121);
  rect(-35 * tamanho, 8 * tamanho, 70 * tamanho, 10 * tamanho);
  
  beginShape();
  vertex(-5 * tamanho, 26 * tamanho);
  vertex(5 * tamanho, 26 * tamanho);
  vertex(15 * tamanho, 36 * tamanho);
  vertex(-15 * tamanho, 36 * tamanho);
  endShape(CLOSE);
  
  // Asas da nave
  fill(details);
  triangle(-22 * tamanho, -10 * tamanho, -48 * tamanho, 25 * tamanho, -10 * tamanho, 2 * tamanho);
  triangle(22 * tamanho, -10 * tamanho, 48 * tamanho, 25 * tamanho, 10 * tamanho, 2 * tamanho);
  rect(-12.5 * tamanho, 20 * tamanho, 25 * tamanho, 10 * tamanho);
  
  // Corpo da nave
  fill(200);
  ellipse(0, 0, 50 * tamanho, 50 * tamanho);
  
  fill(details);
  rect(-2.5 * tamanho, -15 * tamanho, 5 * tamanho, 30 * tamanho);
  
  // Desenho dos fogos dos propulsores
  fill(boost);
  if (left_boost) triangle(-35 * tamanho, 18 * tamanho, -30 * tamanho, 35 * tamanho, -25 * tamanho, 18 * tamanho);
  
  if (right_boost) triangle(35 * tamanho, 18 * tamanho, 30 * tamanho, 35 * tamanho, 25 * tamanho, 18 * tamanho);
  
  if (main_boost) triangle(-5 * tamanho, 36 * tamanho, 0 * tamanho, 55 * tamanho, 5 * tamanho, 36 * tamanho);
  
  popMatrix();
}

void drawFuelBar(float fuel){
  color c;
  if(fuel == 100) c = color(0, 255, 0, 150);
  else if(fuel >= 80) c = color(50, 205, 50, 150);
  else if(fuel >= 60) c = color(255, 255, 0, 150);
  else if(fuel >= 40) c = color(255, 165, 0, 150);
  else if(fuel >= 20) c = color(255, 140, 0, 150);
  else c = color(255,0,0,150);
  
  fill(0);
  ellipse(40,height - 40, 60, 60);
  rect(40,height - 60 , 200, 40, 20);
  
  if(fuel <= 0) fuel = 0;
  fill(c);
  rect(65,height - 55 , 1.70 * fuel, 30, 15);
  
  pushMatrix();
  translate(40, height - 40);
  rotate(-45);
  fill(255);
  stroke(200);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("FUEL", 0, 0); 
  
  popMatrix();
}

void drawLossScreen() {
  backgroundStars();

  // Draw popup window
  int popupWidth = 600;
  int popupHeight = 350;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);

  // Draw title
  drawTitle("You Lost!", color(255,0,0), popupX + popupWidth/2,popupY + 30, 48);

  // Draw planet and details
  clip(popupX, popupY, popupWidth, popupHeight - 20);
  drawPlanet(color(210, 105, 30), 1500, width / 2, height / 2 + 800);
  
  fill(139, 69, 19, 200);
  ellipse(width / 2 - 100, height / 2 + 100, 50, 25);
  ellipse(width / 2 + 120, height / 2 + 120, 70, 35);
  fill(255, 255, 255, 200);
  ellipse(width / 2 + 80, height / 2 + 90, 10, 10);
  ellipse(width / 2 - 170, height / 2 + 140, 8, 8);
  noClip();
  
  // Draw smoke
  fill(50, 120);
  ellipse(width / 2 - 12, height / 2 - 10, 40, 50);
  fill(130, 180);
  ellipse(width / 2 - 30, height / 2 - 30, 45, 40);
  fill(170, 200);
  ellipse(width / 2 - 7, height / 2 - 62, 25, 40);
  fill(200, 250);
  ellipse(width / 2 - 35, height / 2 - 75, 10, 10);
  fill(200, 200);
  ellipse(width / 2 - 15, height / 2 - 90, 10, 10);
  
  if (numJogador == 1) 
    drawNave(width / 2, height / 2 + 35, 130, 1, color(0, 0, 255));
  else if (numJogador == 2)
    drawNave(width / 2, height / 2 + 35, 130, 1,color(255, 0, 0));
   else if (numJogador == 2)
    drawNave(width / 2, height / 2 + 35, 130, 1, color(0, 255, 0));
   else if (numJogador == 2)
    drawNave(width / 2, height / 2 + 35, 130, 1, color(255, 255, 0));
  
  // Draw crater
  stroke(139, 69, 19);
  fill(150, 75, 15);
  ellipse(width / 2 + 30, height / 2 + 50, 40, 30);
  ellipse(width / 2 - 37, height / 2 + 50, 35, 20);
  ellipse(width / 2 - 25, height / 2 + 55, 25, 20);
  ellipse(width / 2 - 2, height / 2 + 55, 40, 20);
  ellipse(width / 2 + 20, height / 2 + 60, 25, 20);
  ellipse(width / 2 + 50, height / 2 + 55, 25, 15);

  stroke(150, 75, 15);
  fill(150, 75, 15);
  rect(width / 2 - popupX - 60, height / 2 + popupY - 31, popupWidth - 1, 20, 0, 0, 50, 50);
  
  drawReturnMessage(popupWidth, popupHeight / 2 - 90, popupX, popupY);
}

void drawWinScreen(){
  backgroundStars();

  // Draw popup window
  int popupWidth = 600;
  int popupHeight = 350;
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;
  drawPopupWindow(popupWidth, popupHeight, popupX, popupY);

  // Draw title
  drawTitle("You Won!", color(0,255,0), popupX + popupWidth/2,popupY + 30, 48);
  
  // Draw planet and details
  clip(popupX, popupY, popupWidth, popupHeight - 20);
  drawPlanet(color(210, 105, 30), 1500, width / 2, height / 2 + 800);
  
  fill(139, 69, 19, 200);
  ellipse(width / 2 - 100, height / 2 + 100, 50, 25);
  ellipse(width / 2 + 120, height / 2 + 120, 70, 35);
  fill(255, 255, 255, 200);
  ellipse(width / 2 + 80, height / 2 + 90, 10, 10);
  ellipse(width / 2 - 170, height / 2 + 140, 8, 8);
  noClip();
  
  left_boost = right_boost = main_boost = true;
  if (numJogador == 1) 
    drawNave(width / 2 + 80, height / 2 - 30, 75, 1, color(0, 0, 255));
  else if (numJogador == 2)
    drawNave(width / 2 + 80, height / 2 - 30, 75, 1, color(255, 0, 0));
   else if (numJogador == 2)
    drawNave(width / 2 + 80, height / 2 - 30, 75, 1, color(0, 255, 0));
   else if (numJogador == 2)
    drawNave(width / 2 + 80, height / 2 - 30, 75, 1, color(255, 255, 0));
  left_boost = right_boost = main_boost = false;
  line(width / 2 + 40, height / 2 + 10, width / 2 - 30, height / 2 + 30);
  line(width / 2 + 10, height / 2 - 13, width / 2 - 60, height / 2 + 7);
  line(width / 2 + 30, height / 2 - 50, width / 2 - 40, height / 2 - 30);
  
  stroke(150, 75, 15);
  fill(150, 75, 15);
  rect(width / 2 - popupX - 60, height / 2 + popupY - 31, popupWidth - 1, 20, 0, 0, 50, 50);
  
  drawReturnMessage(popupWidth, popupHeight / 2 - 90, popupX, popupY);
}

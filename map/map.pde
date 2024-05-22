float angle1 = random(360);
float angle2 = random(360);
float angle3 = random(360);
float angle4 = random(360);
float centerX = 540; // Coordenada x do centro (Sol)
float centerY = 360; // Coordenada y do centro (Sol)
float velocidade1 = random(0.005,0.04);
float velocidade2 = random(0.001,0.02);
float velocidade3 = random(0.0008,0.012);
float velocidade4 = random(0.0005,0.008);

float[] starX = new float[100];
float[] starY = new float[100];
float[] starSize = new float[100];

float numEstrelas = 100;

boolean loggedIn = false;

import processing.net.*;

int buttonWidth = 150;
int buttonHeight = 40;
int buttonSpacing = 10;
int buttonX;
int buttonY;
int TextBoxWidth = 250;
int TextBoxHeight = 40;

String activeScreen = "MENU";

String title = "The Game";
int titleSize = 48;

int flickerDuration = 50; // Flicker duration in milliseconds
int lastFocusTime = 0;

String popupUsername = "Username";
String popupPassword = "Password";
String confirmPassword = "Confirm Password";
String returnText = "Press BACKSPACE to return";

boolean typing = false;

int menuButtonIndex = 2;
int popupButtonIndex = 1;

color blue = color(66, 135, 245);
color white = color(255, 255, 255);

Client socket;

void setup() {
  size(1080, 720); 
  for (int i = 0; i < numEstrelas; i++) {
    starX[i] = random(0,1080);
    starY[i] = random(0,720);
    starSize[i] = random(1, 3);
  }
  buttonX = width / 2 - buttonWidth / 2;
  buttonY = height / 2 - buttonHeight * 2;
  socket = new Client(this, "127.0.0.1", 8080);
}

void draw() {
  background(255);
  if (socket.available() > 0) {
    System.out.println(socket.readString());
  }
  if (activeScreen == "MENU") {
    drawMenu();
  } else if (activeScreen == "LOGIN_POPUP") {
    drawLoginPopup();
  } else if (activeScreen == "REGISTER_POPUP") {
    drawRegisterPopup();
  } else if (activeScreen == "TUTORIAL_POPUP") {
    drawTutorialPopup();
  } else if (activeScreen == "START_GAME"){
    drawGame();
  }
}
void drawGame() {
  background(11, 18, 77);
  
  //estrelas
  fill(255, 255, 255);
  noStroke();
  for (int i = 0; i < numEstrelas; i++) {
    ellipse(starX[i], starY[i], starSize[i], starSize[i]);
  }
  
  // Desenha o Sol
  fill(255, 204, 0); 
  noStroke();
  ellipse(centerX, centerY, 150, 150);
  
  //Planeta 1
  float x1 = centerX + cos(angle1) * 120;
  float y1 = centerY + sin(angle1) * 120;
  fill(161, 89, 8); 
  noStroke(); 
  ellipse(x1, y1, 15, 15);
  angle1 += velocidade1;
  
  //Planeta 2
  float x2 = centerX + cos(angle2) * 220;
  float y2 = centerY + sin(angle2) * 220;
  fill(88, 237, 230); 
  noStroke(); 
  ellipse(x2, y2, 25, 25);
  angle2 += velocidade2;
  
  //Planeta 3
  float x3 = centerX + cos(angle3) * 280;
  float y3 = centerY + sin(angle3) * 280;
  fill(10, 120, 10); 
  noStroke(); 
  ellipse(x3, y3, 30, 30);
  angle3 += velocidade3;
  
  //Planeta 4
  float x4 = centerX + cos(angle4) * 340;
  float y4 = centerY + sin(angle4) * 340;
  fill(119, 2, 222); 
  noStroke(); 
  ellipse(x4, y4, 36, 36);
  angle4 += velocidade4;
}

void drawMenu() {
  // Draw title
  textAlign(CENTER, CENTER); // Center align the title
  textSize(titleSize);
  fill(66, 135, 245); // Blue color
  text(title, width / 2, height / 4 - 25);

  // Calculate the y-position for the first button
  int startY = height / 2 - buttonHeight * 2;

  // Draw buttons
  if (loggedIn == true){
    drawButton(buttonX, startY - buttonHeight-buttonSpacing, "Start Game", menuButtonIndex == 1, blue);
  }
  drawButton(buttonX, startY, "Login", menuButtonIndex == 2, blue);
  drawButton(buttonX, startY + buttonHeight + buttonSpacing, "Register", menuButtonIndex == 3, blue);
  drawButton(buttonX, startY + buttonHeight * 2 + buttonSpacing * 2, "Tutorial", menuButtonIndex == 4, blue);
  drawButton(buttonX, startY + buttonHeight * 3 + buttonSpacing * 3, "Quit", menuButtonIndex == 5, blue);
}

void drawLoginPopup() {
  // Draw semi-transparent background
  fill(0, 100); // Semi-transparent black
  rect(0, 0, width, height);

  // Draw popup window
  int popupWidth = 300;
  int popupHeight = 260; // Increased height
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;
  fill(255); // White color
  rect(popupX, popupY, popupWidth, popupHeight, 20);

  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(0); // Black color
  text("Login", popupX, popupY - 30, popupWidth, 30);

  // Draw username label and password label
  drawTextBox(popupX + 25, popupY + 20, popupButtonIndex == 1, white, popupUsername);
  drawTextBox(popupX + 25, popupY + 80, popupButtonIndex == 2, white, popupPassword);

  // Draw confirm button
  drawButton(popupX + 75, popupY + popupHeight - 70, "Confirm", popupButtonIndex == 3, blue);
  
  // Draw instruction to return
  fill(100); // Gray color
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Press BACKSPACE to return", popupX, popupY + popupHeight - 35, popupWidth, 40);
}

// Draw register popup screen
void drawRegisterPopup() {
  // Draw semi-transparent background
  fill(0, 100); // Semi-transparent black
  rect(0, 0, width, height);

  // Draw popup window
  int popupWidth = 300;
  int popupHeight = 310; // Increased height
  int popupX = width / 2 - popupWidth / 2;
  int popupY = height / 2 - popupHeight / 2;
  fill(255); // White color
  rect(popupX, popupY, popupWidth, popupHeight, 20);

  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(0); // Black color
  text("Register", popupX, popupY - 30, popupWidth, 30);

  // Draw username, password, and confirm password labels
  drawTextBox(popupX + 25, popupY + 20, popupButtonIndex == 1, white, popupUsername);
  drawTextBox(popupX + 25, popupY + 80, popupButtonIndex == 2, white, popupPassword);
  drawTextBox(popupX + 25, popupY + 140, popupButtonIndex == 3, white, confirmPassword);

  // Draw confirm button
  drawButton(popupX + 75, popupY + popupHeight - 70, "Confirm", popupButtonIndex == 4, blue);
  
  // Draw instruction to return
  fill(100); // Gray color
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Press BACKSPACE to return", popupX, popupY + popupHeight - 35, popupWidth, 40);
}


void drawTutorialPopup() {
  // Draw semi-transparent background
  fill(0, 150); // Semi-transparent black
  rect(0, 0, width, height);
  
  // Draw popup window
  int popupWidth = 400;
  int popupHeight = 300;
  int popupX = width/2 - popupWidth/2;
  int popupY = height/2 - popupHeight/2;
  fill(255); // White color
  rect(popupX, popupY, popupWidth, popupHeight, 20);
  
  // Draw title
  textAlign(CENTER, CENTER);
  textSize(24);
  fill(0); // Black color
  text("Tutorial", popupX, popupY - 30, popupWidth, 30);
  
  // Draw tutorial text
  String tutorialText = "Welcome to the Tutorial!\n\nUse AWSD keys to move around.\n\nBe the last one standing and win the game!.";
  fill(0); // Black color
  textAlign(LEFT, TOP);
  textSize(18);
  text(tutorialText, popupX + 20, popupY + 20, popupWidth - 40, popupHeight - 40);
  
  // Draw instruction to return
  fill(100); // Gray color
  textAlign(CENTER, CENTER);
  text(returnText, popupX, popupY + popupHeight - 40, popupWidth, 40);
}

// Draw button function
void drawButton(int x, int y, String label, boolean focused, color buttonColor) {
  if (focused) {
    fill(lerpColor(buttonColor, color(0), 0.3));
    if (millis() - lastFocusTime > flickerDuration) {
      focused = false;
      lastFocusTime = millis();
    }
  } else {
    fill(buttonColor);
  }
  rect(x, y, buttonWidth, buttonHeight, 20);

  // Button text
  fill(255); // White color
  textSize(24);
  text(label, x + buttonWidth / 2, y + buttonHeight / 2);
}

void drawTextBox(int x, int y, boolean focused, color boxColor, String text) {
  if (focused) {
    fill(lerpColor(boxColor, color(0), 0.1));
    if (millis() - lastFocusTime > flickerDuration) {
      focused = false;
      lastFocusTime = millis();
    }
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

void keyPressed() {
  if (activeScreen == "START_GAME"){
    if(keyCode == UP)
      println("Started game");
  }
  if (activeScreen == "MENU") {
    if (keyCode == UP || key == 'w') {
      if(loggedIn){
        menuButtonIndex = max(1, menuButtonIndex - 1);
      }
      else{
        menuButtonIndex = max(2, menuButtonIndex - 1);
      }
      lastFocusTime = millis();
    } else if (keyCode == DOWN || key == 's') {
      menuButtonIndex = min(5, menuButtonIndex + 1);
      lastFocusTime = millis();
    }
    println(menuButtonIndex);
  } else if (activeScreen == "LOGIN_POPUP") {
    if (typing) {
      typing();
    } else {
      if (key == BACKSPACE) {
        activeScreen = "MENU"; // Navigate back to the menu screen
      }
      if (keyCode == UP || key == 'w') {
        popupButtonIndex = max(1, popupButtonIndex - 1);
        lastFocusTime = millis();
      } else if (keyCode == DOWN || key == 's') {
        popupButtonIndex = min(3, popupButtonIndex + 1);
        lastFocusTime = millis();
      }
    }
  } else if (activeScreen == "REGISTER_POPUP") {
    if (typing) {
      typing();
    } else {
      if (key == BACKSPACE) {
        activeScreen = "MENU"; // Navigate back to the menu screen
      }
      if (keyCode == UP || key == 'w') {
        popupButtonIndex = max(1, popupButtonIndex - 1);
        lastFocusTime = millis();
      } else if (keyCode == DOWN || key == 's') {
        popupButtonIndex = min(4, popupButtonIndex + 1);
        lastFocusTime = millis();
      }
    }
  } else if (activeScreen == "TUTORIAL_POPUP") {
    // Check for custom back key press
    if (key == BACKSPACE) {
      activeScreen = "MENU"; // Navigate back to the menu screen
    }
  }
}

// Check if Enter or Space keys are pressed
void keyReleased() {
  if (activeScreen == "MENU") {
    if (key == ENTER || key == ' ') {
      switch (menuButtonIndex) {
        case 1:
          activeScreen = "START_GAME";
        case 2:
          activeScreen = "LOGIN_POPUP";
          break;
        case 3:
          activeScreen = "REGISTER_POPUP";
          break;
        case 4:
          activeScreen = "TUTORIAL_POPUP";
          break;
        case 5:
          exit();
          break;
      }
    }
  } else if (activeScreen == "LOGIN_POPUP") {
    if (key == ENTER || key == ' ') {
      switch (popupButtonIndex) {
        case 1:
          typing = !typing;
          println(popupUsername);
          break;
        case 2:
          typing = !typing;
          println(popupPassword);
          break;
        case 3:
          println("Confirm pressed!");
          println("Socket lançado: " +"00 "+popupUsername + " " + popupPassword);
          socket.write("00 "+popupUsername + " " + popupPassword);
          loggedIn = true;
      }
    }
  } else if (activeScreen == "REGISTER_POPUP") {
    if (key == ENTER || key == ' ') {
      switch (popupButtonIndex) {
        case 1:
          typing = !typing;
          println(popupUsername);
          break;
        case 2:
          typing = !typing;
          println(popupPassword);
          break;
        case 3:
          typing = !typing;
          println(confirmPassword);
          break;
        case 4:
          println("Confirm pressed!");
          println("Socket lançado: " +"02 "+popupUsername + " " + popupPassword);
          socket.write("02 "+popupUsername + " " + popupPassword);
          loggedIn = true;
          break;
      }
    }
  }
}

void typing() {
  if ((keyCode >= 32 && keyCode <= 126) || keyCode == BACKSPACE) {
    if (popupButtonIndex == 1) {
      if (popupUsername.equals("Username")) popupUsername = "";
      if (keyCode == BACKSPACE) {
        if (popupUsername.length() > 0) {
          popupUsername = popupUsername.substring(0, popupUsername.length() - 1);
        }
      } else if (popupUsername.length() < 20) {
        popupUsername += key;
      }
    } else if (popupButtonIndex == 2) {
      if (popupPassword.equals("Password")) popupPassword = "";
      if (keyCode == BACKSPACE) {
        if (popupPassword.length() > 0) {
          popupPassword = popupPassword.substring(0, popupPassword.length() - 1);
        }
      } else if (popupPassword.length() < 20) {
        popupPassword += key;
      }
    } else if (popupButtonIndex == 3) {
      if (confirmPassword.equals("Confirm Password")) confirmPassword = "";
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

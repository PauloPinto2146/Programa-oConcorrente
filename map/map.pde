float angle1;
float angle2;
float angle3;
float angle4;
float centerX = 540; // Coordenada x do centro (Sol)
float centerY = 360; // Coordenada y do centro (Sol)
float velocidade1,velocidade2,velocidade3, velocidade4;

float x1,x2,x3,x4;
float y1,y2,y3,y4;

int curr_level;

float[] starX = new float[100];
float[] starY = new float[100];
float[] starSize = new float[100];

float numEstrelas = 100;

boolean loggedIn = false;
boolean waitingForLobby = false;
String receivedData = ""; 

import processing.net.*;

int buttonWidth = 150;
int buttonHeight = 40;
int buttonSpacing = 10;
int buttonX;
int buttonY;
int TextBoxWidth = 250;
int TextBoxHeight = 40;

String activeScreen = "MENU";

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
  if (socket.active()) {
    println("Connected to server");
  } else {
    println("Failed to connect to server");
  }
}

void draw() {
  background(255);
  if (activeScreen == "MENU") {
    drawMenu();
  } else if (activeScreen == "LOGIN_POPUP") {
    drawLoginPopup();
  } else if (activeScreen == "REGISTER_POPUP") {
    drawRegisterPopup();
  } else if (activeScreen == "TUTORIAL_POPUP") {
    drawTutorialPopup();
  } else if (activeScreen == "LOBBY") {
    drawLobby();
  } else if (activeScreen == "START_GAME"){
    drawGame();
  }
}
void drawGame() {
  background(11, 18, 77);
  
  if (socket.available() > 0) {
    System.out.println(socket.readString());
  } 
  
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
  x1 = centerX + cos(angle1) * 120;
  y1 = centerY + sin(angle1) * 120;
  fill(161, 89, 8); 
  noStroke(); 
  ellipse(x1, y1, 15, 15);
  angle1 += velocidade1;
  
  //Planeta 2
  x2 = centerX + cos(angle2) * 220;
  y2 = centerY + sin(angle2) * 220;
  fill(88, 237, 230); 
  noStroke(); 
  ellipse(x2, y2, 25, 25);
  angle2 += velocidade2;
  
  //Planeta 3
  x3 = centerX + cos(angle3) * 280;
  y3= centerY + sin(angle3) * 280;
  fill(10, 120, 10); 
  noStroke(); 
  ellipse(x3, y3, 30, 30);
  angle3 += velocidade3;
  
  //Planeta 4
  x4 = centerX + cos(angle4) * 340;
  y4 = centerY + sin(angle4) * 340;
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
  text("The Game", width / 2, height / 4 - 25);

  // Calculate the y-position for the first button
  int startY = height / 2 - buttonHeight * 2;

  drawButton(buttonX, startY, "Login", menuButtonIndex == 1, blue);
  drawButton(buttonX, startY + buttonHeight + buttonSpacing, "Register", menuButtonIndex == 2, blue);
  drawButton(buttonX, startY + buttonHeight * 2 + buttonSpacing * 2, "Quit", menuButtonIndex == 3, blue);
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

void drawLobby(){
  //nivel do jogador
  textSize(16);
  fill(0); // Preto
  text(popupUsername + " - Nível: " + curr_level, 50, 40);
  //titulo
  textAlign(CENTER, CENTER); // Center align the title
  textSize(titleSize);
  fill(66, 135, 245); // Blue color
  text("Lobby", width / 2, height / 4 - 25);

  // Calculate the y-position for the first button
  int startY = height / 2 - buttonHeight * 2;
  
  drawButton(buttonX, startY, "Start Game", menuButtonIndex == 1, blue);
  drawButton(buttonX, startY + buttonHeight  + buttonSpacing, "Tutorial", menuButtonIndex == 2, blue);
  drawButton(buttonX, startY + buttonHeight * 2 + buttonSpacing * 2, "Logout", menuButtonIndex == 3, blue);
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
    if(keyCode == UP || key == 'w'){
      println("Started game");
    }
  }
  if (activeScreen == "MENU") {
    if (keyCode == UP || key == 'w') {
      menuButtonIndex = max(1, menuButtonIndex - 1);
      lastFocusTime = millis();
    } else if (keyCode == DOWN || key == 's') {
      menuButtonIndex = min(3, menuButtonIndex + 1);
      lastFocusTime = millis();
    }
    println(menuButtonIndex);
  } else if (activeScreen == "LOGIN_POPUP") {
    if (typing) {
      typing();
    } else {
      if (key == BACKSPACE) {
        popupUsername = "Username";
        popupPassword = "Password";
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
        popupUsername = "Username";
        popupPassword = "Password";
        confirmPassword = "Confirm Password";
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
  } if (activeScreen == "LOBBY") {
      if (keyCode == UP || key == 'w') {
        menuButtonIndex = max(1, menuButtonIndex - 1);
        lastFocusTime = millis();
      } else if (keyCode == DOWN || key == 's') {
        menuButtonIndex = min(3, menuButtonIndex + 1);
        lastFocusTime = millis();
      }
  } else if (activeScreen == "TUTORIAL_POPUP") {
    if (key == BACKSPACE) {
      activeScreen = "LOBBY";
    }
  }
}

// Check if Enter or Space keys are pressed
void keyReleased() {
  if (activeScreen == "MENU") {
    if (key == ENTER || key == ' ') {
      switch (menuButtonIndex) {
        case 1:
          activeScreen = "LOGIN_POPUP";
          break;
        case 2:
          activeScreen = "REGISTER_POPUP";
          break;
        case 3:
          exit();
          break;
      }
    }
  } else if (activeScreen == "LOGIN_POPUP") {
    if (key == ENTER || key == ' ') {
      switch (popupButtonIndex) {
        case 1:
          typing = !typing;
          if(popupUsername == "Username") popupUsername = "";
          println(popupUsername);
          break;
        case 2:
          typing = !typing;
          if(popupPassword == "Password") popupPassword = "";
          println(popupPassword);
          break;
        case 3:
          println("Confirm pressed!");
          println("Socket lançado: " +"00 "+popupUsername + " " + popupPassword);
          socket.write("00 "+popupUsername + " " + popupPassword);
          delay(30);
          if (socket.available() > 0) {
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
              }
            else{
              println("Null Socket");
            }
          }
          if (receivedData.startsWith("Logged_in,")) {
            String[] parts = receivedData.split(", ");
            if (parts.length == 2) {
            try {
              curr_level = Integer.parseInt(parts[1]);
              loggedIn = true;
              activeScreen = "LOBBY";
            } catch (NumberFormatException e) {
              println("Erro ao converter o nível: " + e.getMessage());
              }
            }
          }
          if(receivedData.equals("Error 00")){
            activeScreen = "MENU";
          }
          break;
      }
    }
  } else if (activeScreen == "REGISTER_POPUP") {
    if (key == ENTER || key == ' ') {
      switch (popupButtonIndex) {
        case 1:
          typing = !typing;
          if(popupUsername == "Username") popupUsername = "";
          println(popupUsername);
          break;
        case 2:
          typing = !typing;
          if(popupPassword == "Password") popupPassword = "";
          println(popupPassword);
          break;
        case 3:
          typing = !typing;
          if(confirmPassword == "Confirm Password") confirmPassword = "";
          println(confirmPassword);
          break;
        case 4:
          println("Confirm pressed!");
          println("Socket lançado: " +"02 "+popupUsername + " " + popupPassword);
          socket.write("02 "+popupUsername + " " + popupPassword);
          delay(30);
          if (socket.available() > 0) {
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
              }
            else{
              println("Null Socket");
            }
          }
          println(receivedData);
          if (receivedData.equals("created_Account")){
            loggedIn = true;
            println("DEI REGISTER");
            activeScreen = "LOBBY";
          }
          if(receivedData.equals("Error 01")){
            activeScreen = "MENU";
            println("Couldn't create account");
            loggedIn = false;
          }
          break;
      }
    }
  } else if (activeScreen == "LOBBY") {
    if (key == ENTER || key == ' ') {
      switch (menuButtonIndex) {
        case 1:
          activeScreen = "START_GAME";
          socket.write("10"+ " "+ popupUsername);
          if (socket.available() > 0) {
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
              }
            else{
              println("Null Socket");
            }
          }
          if (receivedData == "firstInLobby"){
            waitingForLobby = true;
            //Adicionar ecrã de espera
            //No ecrã de espera receber socket "stopWaiting" que informa ao jogador que a partida está a começar e coloca activeScreen a START_GAME
            //Tem opção de cancelar a procura de partida, mas mal receba socket que está disponível um jogo não pode mais cancelar
          }
          if (receivedData == "startinGame"){
            activeScreen = "START_GAME";
            //Entra diretamente no jogo se este estiver disponivel
          }
          break;
        case 2:
          activeScreen = "TUTORIAL_POPUP";
          break;
        case 3:
          socket.write("01 " + popupUsername);
          delay(30);
          if(socket.available()>0){
            String data = socket.readString();
            if (data != null) {
              receivedData = data.trim();
              println("Received: " + receivedData);
              }
            else{
              println("Null Socket");
            }
          }
          if(receivedData.equals("logged out sucessfully")){
            popupUsername = "Username";
            popupPassword = "Password";
            confirmPassword = "Confirm Password";
            activeScreen = "MENU";
          }
          if(receivedData.equals("ERROR:Invalid_Username")){
            activeScreen = "LOBBY";
          }
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
